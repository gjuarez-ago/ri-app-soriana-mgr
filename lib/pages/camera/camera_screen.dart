import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:audioplayers/audioplayers.dart';

class CameraScreen extends StatefulWidget {
  final Function(File) onPictureTaken;

  static String routeName = "camera_page";

  CameraScreen({required this.onPictureTaken, Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription> _cameras = [];
  bool _showFlash = false;
  late AnimationController _flashController;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _initializeCameras();

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _audioPlayer = AudioPlayer();
    // Configura el origen del audio
    _audioPlayer.setSource(AssetSource('sounds/camera_shutter.mp3'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _flashController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras[0],
          ResolutionPreset.high,
        );
        _initializeControllerFuture = _controller.initialize();
        setState(() {});
      } else {
        print("No cameras available");
      }
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      // Reproduce el sonido del obturador
      await _audioPlayer.play(AssetSource("sounds/camera_shutter.mp3"));

      setState(() {
        _showFlash = true;
      });
      _flashController.forward().then((_) {
        _flashController.reverse().then((_) {
          setState(() {
            _showFlash = false;
          });
        });
      });

      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, '${DateTime.now().millisecondsSinceEpoch}.png');
      final XFile pictureFile = await _controller.takePicture();
      await pictureFile.saveTo(filePath);

      // Espera el tiempo suficiente para que el sonido termine antes de cerrar la pantalla
      await Future.delayed(const Duration(milliseconds: 300));
      widget.onPictureTaken(File(filePath));
      Navigator.pop(context); // Retornar a la pantalla anterior
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameras.isEmpty
          ? Center(child: Text('No cameras available'))
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CameraPreview(_controller),
                      ),
                      // Destello de la cámara
                      AnimatedOpacity(
                        opacity: _showFlash ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/images/preview.jpg', // Asegúrate de tener esta imagen en tu carpeta de assets
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 120.0),
                          child: Opacity(
                            opacity: 0.5,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.camera_alt, color: Colors.white, size: 40),
                                  onPressed: _takePicture,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
