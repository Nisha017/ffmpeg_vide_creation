import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  VideoPlayerItem({required this.videoUrl});

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {}); // Ensure the first frame is shown
      });
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? SafeArea(
            top: false,
            left: false,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    GestureDetector(
                      onTap: () {
                        _togglePlayPause();
                      },
                      child: !_isPlaying
                          ? Icon(
                              Icons.play_circle_fill,
                              size: 60,
                              color: Colors.grey.shade300,
                            )
                          : Icon(
                              Icons.pause_circle_filled,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                    ),
                  ]),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
