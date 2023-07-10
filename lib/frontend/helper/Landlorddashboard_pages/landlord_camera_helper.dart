import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  final List<CameraDescription> cameras;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _controller;

  late Future<void> _initializeControllerFuture;
  int selectedCameraIndex = 0;

  void _onSwitchCamera() {
    selectedCameraIndex = (selectedCameraIndex + 1) % widget.cameras.length;
    _initCameraController(widget.cameras[selectedCameraIndex]);
  }

  @override
  void initState() {
    _initCameraController(widget.cameras.first);

    super.initState();
  }

  void _initCameraController(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller?.dispose();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.high);

    _initializeControllerFuture = _controller!.initialize().catchError((error) {
      print('Error initializing camera: $error');
    });

    await _initializeControllerFuture;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller!);
          } else {
            return Center(
              child: SpinKitFadingCube(
                color: Color.fromARGB(255, 30, 197, 83),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: _onSwitchCamera,
            ),
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white),
              onPressed: () async {
                try {
                  final XFile image = await _controller!.takePicture();

                  if (image != null) {
                    if (mounted) {
                      Navigator.of(context).pop(image);
                    }
                  }
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
