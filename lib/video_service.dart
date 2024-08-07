import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_video_player_test/video_model.dart';

class VideoService {
  Future<List<Video>> fetchVideos() async {
    final String response = await rootBundle.loadString('assets/videos.json');
    final List<dynamic> data = json.decode(response);
    return data.map((videoJson) => Video.fromJson(videoJson)).toList();
  }
}
