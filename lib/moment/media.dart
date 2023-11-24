import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videolink;
  final bool fullscreen;
  const VideoPlayerScreen(
      {super.key, required this.videolink, required this.fullscreen});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        widget.videolink,
      ),
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    Visibility(
                        visible:
                            !(widget.fullscreen && _controller.value.isPlaying),
                        child: FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        )),
                  ],
                ),
                Visibility(
                    visible: !widget.fullscreen,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_outward),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          }
                        });

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Center(
                                child: VideoPlayerScreen(
                                  videolink: widget.videolink,
                                  fullscreen: true,
                                ),
                              );
                            });
                      },
                    )),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class Gallery extends StatelessWidget {
  final List images;
  final int curIndex;
  const Gallery({super.key, required this.images, required this.curIndex});

  @override
  Widget build(BuildContext context) {
    return PhotoViewGallery.builder(
      itemCount: images.length,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index]),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.3);
      },
      scrollPhysics: const BouncingScrollPhysics(),
      backgroundDecoration: const BoxDecoration(color: Colors.black38),
      enableRotation: false,
      pageController: PageController(initialPage: curIndex),
    );
  }
}
