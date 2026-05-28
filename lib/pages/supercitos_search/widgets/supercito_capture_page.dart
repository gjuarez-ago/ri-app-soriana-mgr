import 'dart:convert';
import 'dart:io';
import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/SearchModelHelpersupercitos.dart';
import 'package:ago_app/models/send_pictures_supercitos_params.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/show_general_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:ago_app/utils/file_cleanup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:ago_app/utils/image_processing_arguments.dart';

class SupercitoCapturePage extends StatefulWidget {
  static String routeName = "supercitos_capture_page";

  const SupercitoCapturePage(
      {super.key, this.numberSegments, this.searchParams});

  final int? numberSegments;
  final SearchModelHelperSupercito? searchParams;

  @override
  State<SupercitoCapturePage> createState() => _SupercitoCapturePageState();
}

class _SupercitoCapturePageState extends State<SupercitoCapturePage> {
  final FileCleanupService _fileCleanup = FileCleanupService();
  final ImagePicker _picker = ImagePicker();

  late final SharedPreferences preferences;
  late bool isAdmin = false;

  String user = '';
  File? _image1;
  File? _image2;
  File? _image3;
  List<File> lsOriginal = [], lsFixed = [];

  RIBloc? _riBloc;

  @override
  void initState() {
    print(widget.searchParams!.tramo);
    print(widget.searchParams!.idRealograma);

    getPref();
    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    super.initState();
  }

  getPref() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = preferences.getBool('admin')!;
      user = '${preferences.getString('usuario')}';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage(int imageNumber) async {
    Future<void> _handlePick(ImageSource source) async {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          final file = File(pickedFile.path);
          lsOriginal.add(file);
          switch (imageNumber) {
            case 1:
              _image1 = file;
              break;
            case 2:
              _image2 = file;
              break;
            case 3:
              _image3 = file;
              break;
          }
        });
      }
      Navigator.of(context).pop();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // 👈 aquí fuerzas el fondo blanco
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => _handlePick(ImageSource.gallery),
                ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => _handlePick(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RIBloc, RIState>(
      listener: (context, state) {
        // Handle state changes here
        if (state is ErrorSendPicturesSupercitos) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(state.messageError!)
            ),
          );
          Navigator.pop(context);
        }

        if (state is SuccessSendPicturesSupercitos) {
          if (!state.response.procesado || state.response.niveles == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text("Ha ocurrido un error al procesar las imágenes")),
            );
            Navigator.pop(context);
            return;
          } else {
            Future.delayed(Duration(seconds: 5), () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Se han procesado correctamente las imágenes',
                    style: TextStyle(color: Colors.white), // Texto blanco
                  ),
                  backgroundColor:
                      Color.fromARGB(255, 34, 199, 19), // Fondo verde
                ),
              );

              _riBloc?.add(EventGetSegmentsSupercitos(
                  piIdRealograma: widget.searchParams!.idRealograma));

              _deleteAllFilesFromLists(deleteParentDirs: true);

              Navigator.pop(context);
              Navigator.pop(context);
            });
          }
        }


      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            bottomNavigationBar: (widget.numberSegments! == 1 &&
                        _image1 != null) ||
                    (widget.numberSegments! == 2 &&
                        _image1 != null &&
                        _image2 != null) ||
                    (widget.numberSegments! == 3 &&
                        _image1 != null &&
                        _image2 != null &&
                        _image3 != null)
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 8, bottom: 25),
                    child: ElevatedButton(
                      onPressed: () async {
                        showGeneralLoading(context);
                        if (widget.numberSegments == 1) {
                          String imagenSuperior =
                              await convertAndResizeImageToBase64(_image1!);

                          SendPicturesSupercitosParams params =
                              SendPicturesSupercitosParams(
                                  idRealograma:
                                      widget.searchParams!.idRealograma,
                                  tramo: widget.searchParams!.tramo,
                                  usuario: user,
                                  categoria: widget.searchParams!.categoria,
                                  idTienda: widget.searchParams!.idTienda,
                                  evento: widget.searchParams!.evento,
                                  fechaCap: DateTime.now().toIso8601String(),
                                  imagenInferior: imagenSuperior,
                                  segments: 1,
                                  imagenSuperior: '');

                          _riBloc?.add(
                              EventSendPicturesSupercitos(params: params));
                        }

                        if (widget.numberSegments == 2) {
                          String imagenSuperior =
                              await convertAndResizeImageToBase64(_image1!);
                          String imagenInferior =
                              await convertAndResizeImageToBase64(_image2!);

                          SendPicturesSupercitosParams params =
                              SendPicturesSupercitosParams(
                            idRealograma: widget.searchParams!.idRealograma,
                            tramo: widget.searchParams!.tramo,
                            usuario: user,
                            fechaCap: DateTime.now().toIso8601String(),
                            categoria: widget.searchParams!.categoria,
                            idTienda: widget.searchParams!.idTienda,
                            evento: widget.searchParams!.evento,
                            imagenSuperior: imagenSuperior,
                            imagenInferior: imagenInferior,
                            segments: 2,
                          );

                          _riBloc?.add(
                              EventSendPicturesSupercitos(params: params));
                        }

                        if (widget.numberSegments == 3) {
                          String imagenSuperior =
                              await convertAndResizeImageToBase64(_image1!);

                          String imagenMedia =
                              await convertAndResizeImageToBase64(_image2!);
                          String imagenInferior =
                              await convertAndResizeImageToBase64(_image3!);

                          // SendPicturesSupercitosParams params =
                          //     SendPicturesSupercitosParams(
                          //   idRealograma: widget.searchParams!.idRealograma,
                          //   tramo: widget.searchParams!.tramo,
                          //   usuario: user,
                          //   fechaCap: DateTime.now().toIso8601String(),
                          //   imagen: imagenSuperior,
                          //   segments: 3,
                          // );

                          // _riBloc
                          //     ?.add(EventSendPicturesSupercitos(params: params));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 13, 112, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 15.0,
                      ),
                      child: InkWell(
                        child: SizedBox(
                          height: kToolbarHeight,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Enviar imágenes",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            appBar: AppBar(
              title: const Text(
                'Capturar tramos',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 1,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Constants.appBarStartColor,
                      Constants.appBarEndColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 30.0,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    "Importante",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.0),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                  children: [
                                    TextSpan(
                                        text:
                                            "Para un mejor procesamiento, tomar las imágenes "),
                                    TextSpan(
                                      text: widget.numberSegments == 1
                                          ? "verticalmente"
                                          : "horizontalmente",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .orange, // Mismo estilo para ambas palabras
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 300,
                              height: 205.00 * widget.numberSegments!,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border:
                                    Border.all(color: Colors.blue, width: 5),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: _buildPhotoContainers(),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPhotoContainers() {
    List<Widget> containers = [];

    if (widget.numberSegments! >= 1) {
      containers.add(photoContainer(_image1, 1));
    }
    if (widget.numberSegments! >= 2) {
      containers.add(const SizedBox(height: 10));
      containers.add(photoContainer(_image2, 2));
    }
    if (widget.numberSegments! >= 3) {
      containers.add(const SizedBox(height: 10));
      containers.add(photoContainer(_image3, 3));
    }

    return containers;
  }

  Widget photoContainer(File? image, int imageNumber) {
    return Container(
      width: 280,
      height: 187,
      decoration: BoxDecoration(
        border: Border.all(
            color: image == null ? Colors.red : Colors.green, width: 5),
        color: Colors.white,
        image: image != null
            ? DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (image != null)
              circularIconButton(Icons.remove_red_eye, Colors.blueAccent, () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ImagePreviewPage(image: image),
                ));
              }),
            circularIconButton(Icons.add_a_photo, Colors.blue.shade900, () {
              _pickImage(imageNumber);
            }),
            if (image != null)
              circularIconButton(
                  Icons.delete, const Color.fromRGBO(229, 57, 53, 1), () {
                setState(() {
                  switch (imageNumber) {
                    case 1:
                      _image1 = null;
                      break;
                    case 2:
                      _image2 = null;
                      break;
                    case 3:
                      _image3 = null;
                      break;
                  }
                });
              }),
          ],
        ),
      ),
    );
  }

  Widget circularIconButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Future<String> convertAndResizeImageToBase64(File imageFile) async {
    try {
      final args = ImageProcessingArguments(
          imageFile.path, widget.numberSegments as int);
      final base64String = await compute(_processAndResizeImage, args);
      final fixedFile = File(await _getFixedPath(imageFile.path));
      lsFixed.add(fixedFile);

      return base64String;
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${e.toString()}')
        ),
      );
      rethrow;
    }
  }

  Future<bool> _onWillPop() async {
    await _deleteAllFilesFromLists(deleteParentDirs: true);
    return true;
  }

  Future<void> _deleteAllFilesFromLists(
      {required bool deleteParentDirs}) async {
    if (lsOriginal.isNotEmpty) {
      await _fileCleanup.shouldICleanUp(lsOriginal.first);
    }

    for (var f in lsOriginal) {
      if (await f.exists()) await deleteImage(f.path, deleteParentDirs: false);
    }
    lsOriginal.clear();

    for (var f in lsFixed) {
      if (await f.exists()) await deleteImage(f.path, deleteParentDirs: false);
    }
    lsFixed.clear();
  }
}

Future<void> deleteImage(String path, {required bool deleteParentDirs}) async {
  if (path.isEmpty) {
    debugPrint('deleteImage(): La ruta del archivo está vacía -> $path');
    return;
  }

  final file = File(path);
  final parentDir = file.parent;

  try {
    if (await file.exists()) {
      await file.delete();
      debugPrint('Archivo eliminado: ${file.path}');
    } else {
      debugPrint('No existe el fichero: ${file.absolute}');
    }

    if (!deleteParentDirs) return;

    if (p.basename(parentDir.path) == 'cache') {
      debugPrint(
          'El directorio padre es el directorio "cache", no se eliminará: ${parentDir.absolute}');
      return;
    }

    final contents = await parentDir.list().toList();
    final isEmpty = contents.isEmpty;

    if (isEmpty) {
      final dirExists = await parentDir.exists();
      if (dirExists) {
        await parentDir.delete();
        debugPrint('Directorio padre eliminado: ${parentDir.path}');
      } else {
        debugPrint('El directorio padre no existe: ${parentDir.absolute}');
      }
    } else {
      debugPrint('El directorio padre no está vacío: ${parentDir.absolute}');
    }
  } catch (e) {
    debugPrint('Error al borrar el archivo $path: $e');
  }
}

class ImagePreviewPage extends StatelessWidget {
  final File image;

  const ImagePreviewPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visualizar imagen',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 1,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constants.appBarStartColor,
                Constants.appBarEndColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.7],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: PhotoView(
            imageProvider: FileImage(image),
          ),
        ),
      ),
    );
  }
}

Future<String> _getFixedPath(String path) async {
  final File file = File(path);
  return '${file.parent.path}/fixed_${file.uri.pathSegments.last}';
}

Future<String> _processAndResizeImage(ImageProcessingArguments args) async {
  String msgAtencion = 'Atención: Retornando archivo original.';
  String esperaH = 'Error: una imagen horizontal.';
  String esperaV = 'Error: Se esperaba una imagen vertical.';

  final File file = File(args.imagePath);

  final String targetPath = await _getFixedPath(args.imagePath);
  img.Image? correctedImage = img.decodeImage(file.readAsBytesSync());

  if (correctedImage == null) {
    // throw Exception(msgAtencion);
  }

  int width = correctedImage!.width;
  int height = correctedImage.height;

  if (args.numberSegments == 2) {
    if (height > width) {
      throw Exception(esperaH);
    }
  } else {
    if (width > height) {
      throw Exception(esperaV);
    }
  }

  final File fixedFile = await File(targetPath).create();
  fixedFile.writeAsBytesSync(img.encodeJpg(correctedImage, quality: 75));

  final bytes = await fixedFile.readAsBytes();

  return base64Encode(bytes);
}
