import 'package:flutter_video_player_test/video_model.dart';
import 'package:flutter_video_player_test/video_service.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  final VideoService videoService = VideoService();
  var videos = <Video>[].obs;
  var controllers = <VideoPlayerController?>[].obs;
  var isPlaying = <bool>[].obs;
  var currentPageIndex = 0.obs;

  final int preloadCount = 5;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  void fetchVideos() async {
    videos.value = await videoService.fetchVideos();
    controllers.value = List.generate(videos.length, (_) => null);
    isPlaying.value = List.generate(videos.length, (_) => false);
    preloadVideos(currentPageIndex.value);
  }

  void preloadVideos(int centerIndex) {
    final start = (centerIndex - preloadCount).clamp(0, videos.length - 1);
    final end = (centerIndex + preloadCount).clamp(0, videos.length - 1);

    for (int i = start; i <= end; i++) {
      if (controllers[i] == null) {
        controllers[i] =
            VideoPlayerController.networkUrl(Uri.parse(videos[i].url))
              ..initialize().then((_) {
                // Play the video if it's the current page
                if (i == currentPageIndex.value) {
                  playVideo(i);
                }
                update(); // Update the state
              });
      }
    }

    for (int i = 0; i < controllers.length; i++) {
      if (i < start || i > end) {
        controllers[i]?.dispose();
        controllers[i] = null;
        isPlaying[i] = false; // Ensure state is updated
      }
    }
  }

  void playVideo(int index) {
    if (controllers[index] != null && !isPlaying[index]) {
      controllers[index]!.play();
      isPlaying[index] = true;
      update();
    }
  }

  void pauseVideo(int index) {
    if (controllers[index] != null && isPlaying[index]) {
      controllers[index]!.pause();
      isPlaying[index] = false;
      update();
    }
  }

  void onPageChanged(int index) {
    pauseVideo(currentPageIndex.value);
    currentPageIndex.value = index;
    playVideo(index);
    preloadVideos(index);
  }

  @override
  void onClose() {
    for (var controller in controllers) {
      controller?.dispose();
    }
    super.onClose();
  }
}
