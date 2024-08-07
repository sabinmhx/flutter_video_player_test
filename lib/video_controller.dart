import 'package:flutter/material.dart';
import 'package:flutter_video_player_test/video_model.dart';
import 'package:flutter_video_player_test/video_service.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  final VideoService videoService = VideoService();
  final RxList<Video> videos = RxList(<Video>[]);
  final RxList<VideoPlayerController?> controllers =
      RxList(<VideoPlayerController?>[]);
  final RxList<bool> isPlaying = RxList(<bool>[]);
  final RxInt currentPageIndex = RxInt(0);

  final int preloadCount = 5;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    videos.value = await videoService.fetchVideos();
    controllers.value = List.generate(videos.length, (_) => null);
    isPlaying.value = List.generate(videos.length, (_) => false);
    if (videos.isNotEmpty) {
      await preloadVideos(currentPageIndex.value);
    }
  }

  Future<void> preloadVideos(int centerIndex) async {
    final start = (centerIndex - preloadCount).clamp(0, videos.length - 1);
    final end = (centerIndex + preloadCount).clamp(0, videos.length - 1);

    for (int i = start; i <= end; i++) {
      await _initializeController(i);
    }

    _disposeUnneededControllers(start, end);
    update;
  }

  Future<void> _initializeController(int index) async {
    if (controllers[index] == null) {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(videos[index].url));
      controllers[index] = controller;
      try {
        // Add a listener to update state when the video is initialized
        controller.addListener(() {
          if (controller.value.isInitialized) {
            debugPrint('Video at index $index initialized');
            if (index == currentPageIndex.value) {
              playVideo(index);
            }
          }
        });

        // Initialize the controller
        await controller.initialize();
      } catch (e) {
        debugPrint('Error initializing video at index $index: $e');
        controllers[index] = null;
      }
    }
  }

  void _disposeUnneededControllers(int start, int end) {
    for (int i = 0; i < controllers.length; i++) {
      if (i < start || i > end) {
        controllers[i]?.dispose();
        controllers[i] = null;
        isPlaying[i] = false;
      }
    }
  }

  Future<void> playVideo(int index) async {
    if (controllers[index] != null) {
      try {
        await controllers[index]!.play();
        isPlaying[index] = true;
        update;
      } catch (e) {
        debugPrint('Error playing video at index $index: $e');
      }
    }
  }

  Future<void> pauseVideo(int index) async {
    if (controllers[index] != null && isPlaying[index]) {
      await controllers[index]!.pause();
      isPlaying[index] = false;
      update;
    }
  }

  Future<void> onPageChanged(int index) async {
    await pauseVideo(currentPageIndex.value);
    currentPageIndex.value = index;
    await playVideo(index);
    await preloadVideos(index);
  }

  @override
  void onClose() {
    for (var controller in controllers) {
      controller?.dispose();
    }
    super.onClose();
  }
}
