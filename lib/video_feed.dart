import 'package:flutter/material.dart';
import 'package:flutter_video_player_test/video_controller.dart';
import 'package:flutter_video_player_test/video_item.dart';
import 'package:get/get.dart';

class VideoFeed extends StatelessWidget {
  const VideoFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoController controller = Get.put(VideoController());

    return Obx(() {
      if (controller.videos.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: controller.videos.length,
        onPageChanged: controller.onPageChanged,
        itemBuilder: (context, index) {
          return VideoItem(
            videoPlayerController: controller.controllers[index],
            isPlaying: controller.currentPageIndex.value == index,
          );
        },
      );
    });
  }
}
