import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.onCapture});
  final ValueChanged<XFile> onCapture;
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription> _cameras = [];
  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (mounted) setState(() {});
    // _toggleCameraLens()
    await initializeCamera(
      _cameras.firstWhere((e) => e.lensDirection == CameraLensDirection.front),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCamera();
    });
    super.initState();
    // initializeCamera();
  }

  Future<void> initializeCamera(CameraDescription desc) async {
    controller = CameraController(desc, ResolutionPreset.high);

    // Ensure that the camera is initialized
    await controller!.initialize();

    if (!mounted) return;
    setState(() {});
  }

  void _toggleCameraLens() {
    if (controller == null) return;
    // get current lens direction (front / rear)
    final lensDirection = controller!.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = _cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = _cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }

    initializeCamera(newDescription);
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (!controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(title: Text('Camera')),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: CameraPreview(
                controller!,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                          foregroundColor: WidgetStatePropertyAll(
                            Colors.black,
                          ),
                          padding: WidgetStatePropertyAll(
                              const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20))),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      label: Text("Back"),
                      icon: Icon(Icons.keyboard_backspace_outlined),
                    ),
                    IconButton.filled(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.white,
                            ),
                            padding: WidgetStatePropertyAll(
                                const EdgeInsets.all(25))),
                        onPressed: () async {
                          final image = await controller!.takePicture();
                          // Use the captured image
                          widget.onCapture(image);
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black,
                        )),
                    SizedBox(
                      height: 55,
                      width: 55,
                      child: MaterialButton(
                        onPressed: () {
                          _toggleCameraLens();
                        },
                        height: 55,
                        padding: const EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        child: Icon(
                          Icons.settings_backup_restore_sharp,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                )),
              ),
            ),
            // Positioned(
            //     right: size.width * .2,
            //     bottom: 20,
            //     child: SafeArea(
            //       top: false,
            //       child: IconButton(
            //           onPressed: () {},
            //           icon: Icon(
            //             Icons.flip_camera_ios,
            //             color: Colors.white,
            //             size: 40,
            //           )),
            //     ))
          ],
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: SafeArea(
      //   child: FloatingActionButton(
      //     onPressed: () async {
      // final image = await controller!.takePicture();
      // // Use the captured image
      // widget.onCapture(image);
      //     },
      //     child: const Icon(Icons.camera),
      //   ),
      // ),
    );
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }
}

class FullScreenCameraPreview extends StatelessWidget {
  final CameraController cameraController;

  const FullScreenCameraPreview({required this.cameraController});

  @override
  Widget build(BuildContext context) {
    final aspectRatio = cameraController.value.aspectRatio;

    return OverflowBox(
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: aspectRatio > 1 ? aspectRatio : 1 / aspectRatio,
          height: aspectRatio > 1 ? 1 / aspectRatio : aspectRatio,
          child: CameraPreview(cameraController),
        ),
      ),
    );
  }
}
