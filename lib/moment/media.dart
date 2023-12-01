import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videolink;
  final bool enlarge;
  final bool fullscreen;
  const VideoPlayerScreen(
      {super.key,
      required this.videolink,
      required this.enlarge,
      required this.fullscreen});

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
              alignment: Alignment.topLeft,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                          child: VideoPlayer(_controller),
                        ),
                        Visibility(
                            visible: !(_controller.value.isPlaying),
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
                      visible: !widget.enlarge,
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
                                  child: Card(
                                      child: VideoPlayerScreen(
                                    videolink: widget.videolink,
                                    enlarge: true,
                                    fullscreen: false,
                                  )),
                                );
                              });
                        },
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.enlarge && !widget.fullscreen,
                  child: Card(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () {
                          print("pressed!");
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            }
                          });
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Center(
                                  child: Card(
                                      child: RotatedBox(
                                    quarterTurns: 3,
                                    child: VideoPlayerScreen(
                                      videolink: widget.videolink,
                                      enlarge: true,
                                      fullscreen: true,
                                    ),
                                  )),
                                );
                              });
                        },
                        color: Colors.white,
                        icon: const Icon(Icons.rotate_90_degrees_cw),
                      )),
                )
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
