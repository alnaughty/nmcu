import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:video_player/video_player.dart';

class NomNomVideoPlayer extends StatefulWidget {
  const NomNomVideoPlayer({super.key});

  @override
  State<NomNomVideoPlayer> createState() => _NomNomVideoPlayerState();
}

class _NomNomVideoPlayerState extends State<NomNomVideoPlayer> {
  ChewieController? _chewieController;
  Future<void> initPlayer(VideoPlayerController vpController) async {
    await vpController.initialize();

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: vpController,
        autoPlay: true,
        looping: true,
        showOptions: false,
        showControls: false,
        showControlsOnInitialize: false,
      );
    });
  }

  Future<String> getVideoUrl() async {
    try {
      // Reference to the file in Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref("app_videos/NOMNOM REVISED.mp4");

      // Get the download URL
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error getting video URL: $e");
      throw e;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final String url = await getVideoUrl();
      await initPlayer(VideoPlayerController.networkUrl(url.toUri));
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _chewieController == null
          ? Container()
          : Chewie(
              controller: _chewieController!,
            ),
    );
  }
}
