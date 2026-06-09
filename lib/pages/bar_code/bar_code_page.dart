import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:camera/camera.dart';

class BarCodePage extends StatefulWidget {
  final Function(String) onUpcTaken;

  BarCodePage({required this.onUpcTaken, Key? key}) : super(key: key);

  @override
  _BarCodePageState createState() => _BarCodePageState();
}

class _BarCodePageState extends State<BarCodePage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  BarcodeScanner? _barcodeScanner;
  bool _isScanning = false;
  String _productCode = '';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _barcodeScanner = BarcodeScanner();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _barcodeScanner?.close();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController?.initialize();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _scanBarcode() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isScanning) {
      return;
    }

    _isScanning = true;

    try {
      final picture = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(picture.path);
      final barcodes = await _barcodeScanner!.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        setState(() {
          _productCode = barcodes.first.rawValue!;
          _showCustomDialog(context, _productCode);
        });
      } else {
        setState(() {
          _productCode = 'No product code found';
        });
        print('Failed to scan product code: No product code found');
      }
    } catch (e) {
      setState(() {
        _productCode = 'Failed to scan product code: $e';
      });
      print('Failed to scan product code: $e');
    }

    _isScanning = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawerScrimColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            CameraPreview(_cameraController!),
            Positioned(
              top: 12,
              left: 12,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: FadeTransition(
                      opacity: _animation,
                      child: Container(
                        width: 300,
                        height: 3,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(26.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('UPC: $_productCode',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _scanBarcode,
                      icon: Icon(Icons.camera_alt, size: 30),
                      label: Text('Escanear producto',
                          style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showCustomDialog(BuildContext context, String request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
                              backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            height: 235.0,
            width: 200.0,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.info_outline,
                  size: 50.0,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16.0),
                Column(
                  children: [
                    Text(
                      '¿Es correcto el UPC?',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      addSpacesEveryThreeCharacters(request),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 243, 65, 33),
                            Color.fromARGB(255, 206, 45, 45)
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .transparent, // Use transparent as the background color
                          shadowColor: Colors.transparent, // Remove shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          // Acción al presionar Editar
                          setState(() {
                            _productCode = 'Intenta nuevamente';
                            Navigator.pop(context); // Cerrar el modal
                          });
                        },
                        child: const Text('Cerrar', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blue,
                            Color.fromARGB(255, 76, 104, 175)
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .transparent, // Use transparent as the background color
                          shadowColor: Colors.transparent, // Remove shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          widget.onUpcTaken(_productCode);
                          Navigator.pop(context);
                          
                        },
                        child: const Text('Ok', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String addSpacesEveryThreeCharacters(String input) {
    // Eliminar espacios y caracteres no alfanuméricos
    final cleanedInput = input.replaceAll(RegExp(r'\s+'), '');

    // Crear una lista de partes con longitud de 3 caracteres
    final buffer = StringBuffer();
    for (int i = 0; i < cleanedInput.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanedInput[i]);
    }

    return buffer.toString();
  }
}
