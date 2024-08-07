import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends StatelessWidget {
  final VideoPlayerController? videoPlayerController;
  final bool isPlaying;

  const VideoItem({
    super.key,
    required this.videoPlayerController,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    if (videoPlayerController == null ||
        !videoPlayerController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: videoPlayerController!.value.aspectRatio,
          child: VideoPlayer(videoPlayerController!),
        ),
      ],
    );
  }
}
