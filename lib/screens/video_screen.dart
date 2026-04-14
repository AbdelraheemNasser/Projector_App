import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  String? _videoPath;
  VideoPlayerController? _controller;
  bool _isConnected = false;
  static const platform = MethodChannel('com.videocaster/display');

  @override
  void initState() {
    super.initState();
    _setupDisplayListener();
  }

  void _setupDisplayListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onDisplayConnected') {
        setState(() => _isConnected = true);
        // Just show connected status, don't auto-play fullscreen
      } else if (call.method == 'onDisplayDisconnected') {
        setState(() => _isConnected = false);
      }
    });
  }

  void _playFullScreen() {
    if (_controller != null && _controller!.value.isInitialized) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenPlayer(controller: _controller!),
        ),
      );
    }
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        _videoPath = result.files.single.path;
      });
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    if (_videoPath != null) {
      _controller?.dispose();
      _controller = VideoPlayerController.file(File(_videoPath!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<void> _startCasting() async {
    try {
      await platform.invokeMethod('startCasting');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'عرض المحاضرات',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_videoPath == null)
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF00D4FF).withOpacity(0.3),
                                  Color(0xFF7B2FF7).withOpacity(0.3)
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.video_library,
                              size: 80,
                              color: Colors.white54,
                            ),
                          )
                        else if (_controller != null && _controller!.value.isInitialized)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF7B2FF7).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF00D4FF), Color(0xFF7B2FF7)],
                              ),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        SizedBox(height: 20),
                        Text(
                          _videoPath == null ? 'لم يتم اختيار فيديو' : 'الفيديو جاهز',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        if (_controller != null && _controller!.value.isInitialized) ...[
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _controller!.seekTo(
                                    _controller!.value.position - Duration(seconds: 10),
                                  );
                                },
                                icon: Icon(Icons.replay_10, color: Color(0xFF00D4FF), size: 40),
                              ),
                              SizedBox(width: 20),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF00D4FF), Color(0xFF7B2FF7)],
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: _togglePlayPause,
                                  icon: Icon(
                                    _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              IconButton(
                                onPressed: () {
                                  _controller!.seekTo(
                                    _controller!.value.position + Duration(seconds: 10),
                                  );
                                },
                                icon: Icon(Icons.forward_10, color: Color(0xFF00D4FF), size: 40),
                              ),
                              SizedBox(width: 20),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFE94560), Color(0xFF7B2FF7)],
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: _playFullScreen,
                                  icon: Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: VideoProgressIndicator(
                              _controller!,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Color(0xFF00D4FF),
                                bufferedColor: Colors.white24,
                                backgroundColor: Colors.white12,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 40),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF00D4FF), Color(0xFF7B2FF7)],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF00D4FF).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _pickVideo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  icon: Icon(Icons.folder_open, color: Colors.white),
                                  label: Text(
                                    'اختيار فيديو',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  gradient: _videoPath != null
                                      ? LinearGradient(
                                          colors: [Color(0xFF7B2FF7), Color(0xFFE94560)],
                                        )
                                      : null,
                                  color: _videoPath == null ? Colors.grey : null,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: _videoPath != null
                                      ? [
                                          BoxShadow(
                                            color: Color(0xFF7B2FF7).withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: Offset(0, 10),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _videoPath != null ? _startCasting : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  icon: Icon(Icons.cast, color: Colors.white),
                                  label: Text(
                                    'بدء العرض',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isConnected)
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                'متصل بالشاشة',
                                style: TextStyle(color: Colors.green, fontSize: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class FullScreenPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenPlayer({super.key, required this.controller});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Lock to landscape only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    widget.controller.play();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: VideoPlayer(widget.controller),
        ),
      ),
    );
  }
}
