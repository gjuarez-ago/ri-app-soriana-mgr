import 'dart:convert';
import 'dart:io';
import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/search_model_helper.dart';
import 'package:ago_app/models/send_picture_params_v2.dart';
import 'package:ago_app/models/validate_categories.dart';
import 'package:ago_app/models/validateceros.dart';
import 'package:ago_app/pages/bar_code/bar_code_page.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/alert_dialogs.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:ago_app/utils/image_processing_arguments.dart';

class TakePicturePage extends StatefulWidget {
  final int? numberSegments;
  final SearchModelHelper? searchParams;

  const TakePicturePage({super.key, this.numberSegments, this.searchParams});

  static String routeName = "take_picture_page";

  @override
  State<TakePicturePage> createState() => _TakePicturePageState();
}

class _TakePicturePageState extends State<TakePicturePage> {
  final FileCleanupService _fileCleanup = FileCleanupService();
  final ImagePicker _picker = ImagePicker();
  String user = '';
  File? _image1;
  File? _image2;
  File? _image3;
  List<File> lsOriginal = [], lsFixed = [];
  bool _isLoading = false; // Variable para manejar el estado de carga

  RIBloc? _riBloc;
  
  bool isLoadingSendImages = false;

  late final SharedPreferences preferences;
  late bool isAdmin = false;




  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState(); // Siempre es buena práctica llamar a super.initState() al inicio
    print(widget.searchParams!.tramo);
    print(widget.searchParams!.idRealograma);
    
    _riBloc = BlocProvider.of<RIBloc>(context);

    // Mandamos a llamar las preferencias. La validación de la cámara ahora vive ahí.
    getPref();
  }

  getPref() async {
    preferences = await SharedPreferences.getInstance();
    
    // Verificamos si el widget sigue montado antes de actualizar el estado
    if (!mounted) return;

    setState(() {
      isAdmin = preferences.getBool('admin') ?? false;
      final String? rawUser = preferences.getString('usuario');
      user = (rawUser != null && rawUser.trim().isNotEmpty)
        ? rawUser.trim()
        : 'root';
    });

    // Validamos: Si NO es admin, abrimos la cámara automáticamente para la imagen 1.
    // Le pasamos isFromBottomSheet: false para evitar que haga pop() de tu pantalla completa.
    
    if (!isAdmin) {
    // Pequeño retraso para asegurar que la UI está lista
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _handlePick(ImageSource.camera, 1);
      }
    });
  }
  }

Future<void> _handlePick(ImageSource source, int imageNumber) async {
  // Forzar cámara trasera cuando sea source == ImageSource.camera
  if (source == ImageSource.camera) {
    try {
      // Primero intentamos con la cámara trasera explícitamente
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 3000,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null && mounted) {
        await _registerPicked(pickedFile, imageNumber);
      }
    } catch (e) {
      print('Error al abrir cámara trasera: $e');

      // Si falla, intentamos de nuevo pero sin forzar (usará la predeterminada del sistema)
      try {
        final pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 90,
          maxWidth: 3000,
        );

        if (pickedFile != null && mounted) {
          await _registerPicked(pickedFile, imageNumber);
        }
      } catch (e) {
        print('Error al abrir cámara: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al abrir la cámara'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  } else {
    // Para galería (solo admin)
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 3000,
    );

    if (pickedFile != null && mounted) {
      await _registerPicked(pickedFile, imageNumber);
    }
  }
}

/// Copia la imagen recién capturada del directorio volátil `tmp/` (iOS la
/// purga sin aviso) a un directorio persistente de la app, y registra esa
/// copia estable. Evita el `PathNotFoundException` al procesar/enviar.
Future<void> _registerPicked(XFile pickedFile, int imageNumber) async {
  final File file;
  try {
    file = await _persistPickedFile(pickedFile);
  } catch (e) {
    print('Error al guardar la imagen capturada: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la imagen, intenta de nuevo'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  if (!mounted) return;

  setState(() {
    lsOriginal.add(file);

    if (imageNumber == 1) _image1 = file;
    if (imageNumber == 2) _image2 = file;
    if (imageNumber == 3) _image3 = file;
  });

  WidgetsBinding.instance.addPostFrameCallback((_) => _autoSendImages());
}

Future<File> _persistPickedFile(XFile pickedFile) async {
  final Directory docsDir = await getApplicationDocumentsDirectory();
  final Directory captureDir =
      Directory(p.join(docsDir.path, 'captura_tramos'));
  if (!await captureDir.exists()) {
    await captureDir.create(recursive: true);
  }

  final String fileName =
      'cap_${DateTime.now().microsecondsSinceEpoch}_${p.basename(pickedFile.path)}';
  final String destPath = p.join(captureDir.path, fileName);

  // saveTo lee los bytes directamente del XFile (no depende de que el
  // archivo de tmp siga existiendo en disco al momento de copiar).
  await pickedFile.saveTo(destPath);
  return File(destPath);
}


  // Ahora _pickImage solo se encarga de mostrar el menú
  Future<void> _pickImage(int imageNumber) async {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => _handlePick(ImageSource.gallery, imageNumber),
                ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => _handlePick(ImageSource.camera, imageNumber),
              ),
            ],
          ),
        );
      },
    );
  }

Widget photoContainer(File? image, int imageNumber) {
  return GestureDetector(
    // Si hay imagen, el toque abre la vista previa
    onTap: image != null 
      ? () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ImagePreviewPage(image: image),
        ))
      : null,
    child: Container(
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
                // Aplicamos un oscurecimiento leve solo si hay imagen para que los botones resalten
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          // Texto de ayuda visual (Solo si hay imagen)
          if (image != null)
            const Positioned(
              top: 8,
              left: 8,
              child: Row(
                children: [
                  Icon(Icons.zoom_in, color: Colors.white70, size: 16),
                  SizedBox(width: 4),
                  Text("Tocar para ampliar", 
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          
          // Centro con los botones de acción
          Center(
            child: Wrap(
              spacing: 20, // Aumentamos el espacio entre botones ahora que hay más lugar
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // BOTÓN CÁMARA (Siempre visible)
                circularIconButton(Icons.camera_alt, Colors.blue.shade900, () {
                  _handlePick(ImageSource.camera, imageNumber);
                }),

                // BOTÓN GALERÍA (Solo Admin)
                if (isAdmin)
                  circularIconButton(Icons.folder_special, const Color.fromARGB(255, 239, 0, 0), () {
                    _handlePick(ImageSource.gallery, imageNumber);
                  }),

               
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _autoSendImages() async {
  // 1. Verificamos si ya tenemos todas las fotos necesarias según los segmentos
  bool isComplete = false;
  if (widget.numberSegments == 1 && _image1 != null) isComplete = true;
  if (widget.numberSegments == 2 && _image1 != null && _image2 != null) isComplete = true;
  if (widget.numberSegments == 3 && _image1 != null && _image2 != null && _image3 != null) isComplete = true;

  if (!isComplete || isLoadingSendImages) return;

  // 2. Iniciamos el proceso de envío
  setState(() {
    showGeneralLoading(context);
    isLoadingSendImages = true;
  });

  try {
    String? imgSup, imgMed, imgInf;

    // Procesamos solo las que existan
    if (_image1 != null) imgSup = await convertAndResizeImageToBase64(_image1!);
    if (_image2 != null) {
      if (widget.numberSegments == 2) imgInf = await convertAndResizeImageToBase64(_image2!);
      if (widget.numberSegments == 3) imgMed = await convertAndResizeImageToBase64(_image2!);
    }
    if (_image3 != null) imgInf = await convertAndResizeImageToBase64(_image3!);

    SendPictureParamsV2 params = SendPictureParamsV2(
      idRealograma: widget.searchParams!.idRealograma,
      tramo: widget.searchParams!.tramo,
      usuario: user,
      categoria: widget.searchParams!.categoria!,
      fechaCap: DateTime.now().toIso8601String(),
      segments: widget.numberSegments!,
      imagenSuperior: imgSup,
      imagenMedia: imgMed,
      imagenInferior: imgInf,
      idTienda: widget.searchParams!.idTienda,
      evento: widget.searchParams!.event,
      ambiente: Constants.enviroment,
    );

    _riBloc?.add(EventSendPictures2(params: params));
    
  } catch (e) {
    setState(() => isLoadingSendImages = false);
    // El error ya se maneja dentro de convertAndResizeImageToBase64 con un SnackBar
  }
}


Widget circularIconButton(IconData icon, Color color, VoidCallback onPressed) {
  return Container(
    width: 54, // Un poco más grandes para facilitar el toque
    height: 54,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 3),
        )
      ],
    ),
    child: IconButton(
      icon: Icon(icon, color: Colors.white, size: 26),
      onPressed: onPressed,
    ),
  );
}

  Future<void> _navigateToCamera() async {
    _isLoading = true;

    final String? image = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarCodePage(
          onUpcTaken: (upc) {
            setState(() {
              _riBloc?.add(
                EventValidateCategories(
                  request: ValidateCategories(
                    store: widget.searchParams!.idTienda,
                    category: widget.searchParams!.categoria,
                    upc: upc,
                  ),
                ),
              );

              // _riBloc?.add(
              //   EventValidateCategories(
              //     request: ValidateCategories(
              //       store: widget.searchParams!.idTienda,
              //       category: '128',
              //       upc: upc,
              //     ),
              //   ),
              // );
              // // }
              _isLoading = false;
            });
          },
        ),
      ),
    );
  }


 
 
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RIBloc, RIState>(
      listener: (context, state) {
        // Handle state changes here
        if (state is ErrorSendPictures || state is ErrorValidations) {
                   print(state.messageError); 

            setState(() {
              isLoadingSendImages = false;
            });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(state.messageError!)
            )
          );
          Navigator.pop(context);

        }

        if (state is SuccessSendPictures) {
          if (!state.response.procesado || state.response.productos == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text("Ha ocurrido un error al procesar las imágenes"),
              ),
            );
            print("RESPUESTA_${state.response.toJson()}");
            setState(() {
              isLoadingSendImages = false;
            });
            
            Navigator.pop(context);
          } else {
            _riBloc?.add(
              EventValidateZeros(
                request: ValidateCeros(
                  idRealograma: widget.searchParams!.idRealograma,
                  category: widget.searchParams!.categoria!,
                  tramo: widget.searchParams!.tramo,
                ),
              ),
            );

            print(
              "${widget.searchParams!.idRealograma}, ${widget.searchParams!.categoria!} ${widget.searchParams!.tramo}",
            );

            // _riBloc?.add(
            //   EventValidateZeros(
            //     request: ValidateCeros(
            //       idRealograma: 452312,
            //       category: '164',
            //       tramo: 5,
            //     ),
            //   ),
            // );
          }
        }

        if (state is SuccessValidationsZeros) {
          print("REPSUESTA_${state.response.toJson()}");

          if (!state.response.estatus) {
            // 0
            Future.delayed(Duration(seconds: 3), () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Se han procesado correctamente las imágenes',
                    style: TextStyle(color: Colors.white), // Texto blanco
                  ),
                  backgroundColor: Color.fromARGB(
                    255,
                    34,
                    199,
                    19,
                  ), // Fondo verde
                ),
              );

              setState(() {
                _image1 = null;
                _image2 = null;
              });

              _riBloc?.add(
                EventGetSegments(
                  idCategoria: widget.searchParams!.categoria!,
                  idRealograma: widget.searchParams!.idRealograma,
                ),
              );

              _deleteAllFilesFromLists(deleteParentDirs: true);

              Navigator.pop(context);
              Navigator.pop(context);
            });
          } else {
            // 1
            Navigator.pop(context);
            
            showDialog(
              context:
                  context, // ← Este es el context de tu widget, no del diálogo
              barrierDismissible: false,
              builder: (BuildContext context) {
                return SimpleAlertDialog(
                  
                  title: "Atención",
                  description: state.response.descripcion,
                  onAccept: () {
                    // Tu lógica de aceptar
                    setState(() {
                      _image1 = null;
                      _image2 = null;
                                            isLoadingSendImages = false;

                    });
                    _riBloc?.add(
                      EventDeleteTramo(
                        idReconocimiento: state.response.idReconocimiento,
                        tramo: widget.searchParams!.tramo,
                      ),
                    );
                    Navigator.of(context).pop();
                    _navigateToCamera();
                    
                  },

                  onClose: () {
                    // Tu lógica de cerrar
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Se han procesado correctamente las imágenes',
                          style: TextStyle(color: Colors.white), // Texto blanco
                        ),
                        backgroundColor: Color.fromARGB(
                          255,
                          34,
                          199,
                          19,
                        ), // Fondo verde
                      ),
                    );
                    _riBloc?.add(
                      EventGetSegments(
                        idCategoria: widget.searchParams!.categoria!,
                        idRealograma: widget.searchParams!.idRealograma,
                      ),
                    );
                    _deleteAllFilesFromLists(deleteParentDirs: true);
                    Navigator.pop(context);
                  },
                  acceptText: 'Capturar',
                  closeText: "Conservar foto",
                );
              },
            );
          }
        }

        if (state is IsLoadingGetResumePicture) {
          showGeneralLoading(context);
        }

        if (state is ErrorGetResumePicture) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.messageError!,
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                ), // Texto blanco
              ),
              backgroundColor: Color.fromARGB(255, 244, 36, 36), // Fondo verde
            ),
          );
          Navigator.pop(context);
        }

        if (state is SuccessValidationsCategory) {
          print("_DDDDD ${state.response.toJson()}");

          if (state.response.estatus) {
            print(
              " ID_RECONOCIMIENTO ${widget.searchParams!.idReconocimiento}",
            );
            Navigator.of(context).pop();
          } else {
            showDialog(
              context:
                  context, // ← Este es el context de tu widget, no del diálogo
              barrierDismissible: false,
              builder: (BuildContext context) {
                return SimpleAlertDialog(
                  title: "Atención",
                  description:
                      '${state.response.descripcion}. ¿Escaneamos de nueva cuenta?',
                  onAccept: () {
                    Navigator.of(context).pop();
                  },
                  onClose: () {
                    setState(() {
                      _image1 = null;
                      _image2 = null;
                    });

                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  acceptText: 'Escanear de nuevo',
                  closeText: "Cancelar",
                );
              },
            );
          }
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            bottomNavigationBar:
              (widget.numberSegments! == 1 && _image1 != null) ||
                (widget.numberSegments! == 2 &&
                  _image1 != null &&
                  _image2 != null) ||
                (widget.numberSegments! == 3 &&
                  _image1 != null &&
                  _image2 != null &&
                  _image3 != null)
              ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 25,
                  ),
                  child:ElevatedButton(
                    onPressed: isLoadingSendImages
                    ? null
                    : () async {
                      
                      setState(() {
                        showGeneralLoading(context);
                        isLoadingSendImages = true;
                      });
                      try {
                        if (widget.numberSegments == 1) {
      
                          String imagenSuperior = await convertAndResizeImageToBase64(_image1!);
            
                          SendPictureParamsV2 params = SendPictureParamsV2(
                            idRealograma: widget.searchParams!.idRealograma,
                            tramo: widget.searchParams!.tramo,
                            usuario: user,
                            categoria: widget.searchParams!.categoria!,
                            fechaCap: DateTime.now().toIso8601String(),
                            segments: 1,
                            imagenSuperior: imagenSuperior,
                            idTienda: widget.searchParams!.idTienda,
                            evento: widget.searchParams!.event,
                            ambiente: Constants.enviroment,
                          );
            
                          _riBloc?.add(EventSendPictures2(params: params));
                        }
            
                        if (widget.numberSegments == 2) {
                          String imagenSuperior = await convertAndResizeImageToBase64(_image1!);
                          String imagenInferior = await convertAndResizeImageToBase64(_image2!);
            
                          SendPictureParamsV2 params = SendPictureParamsV2(
                            idRealograma: widget.searchParams!.idRealograma,
                            tramo: widget.searchParams!.tramo,
                            usuario: user,
                            categoria: widget.searchParams!.categoria!,
                            fechaCap: DateTime.now().toIso8601String(),
                            segments: 2,
                            imagenSuperior: imagenSuperior,
                            imagenInferior: imagenInferior,
                            idTienda: widget.searchParams!.idTienda,
                            evento: widget.searchParams!.event,
                            ambiente: Constants.enviroment,
                          );
            
                          _riBloc?.add(EventSendPictures2(params: params));
                        }
            
                        if (widget.numberSegments == 3) {
                          String imagenSuperior = await convertAndResizeImageToBase64(_image1!);
                          String imagenMedia = await convertAndResizeImageToBase64(_image2!);
                          String imagenInferior = await convertAndResizeImageToBase64(_image3!);
            
                          SendPictureParamsV2 params = SendPictureParamsV2(
                            idRealograma: widget.searchParams!.idRealograma,
                            tramo: widget.searchParams!.tramo,
                            usuario: user,
                            categoria: widget.searchParams!.categoria!,
                            fechaCap: DateTime.now().toIso8601String(),
                            segments: 3,
                            imagenSuperior: imagenSuperior,
                            imagenMedia: imagenMedia,
                            imagenInferior: imagenInferior,
                            idTienda: widget.searchParams!.idTienda,
                            evento: widget.searchParams!.event,
                            ambiente: Constants.enviroment,
                          );
            
                          _riBloc?.add(EventSendPictures2(params: params));
                        }
                      } finally {
                        
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoadingSendImages
                        ? Colors.grey // 🔹 Color gris cuando está bloqueado
                        : const Color.fromARGB(255, 13, 112, 54), // Verde cuando está activo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 15.0,
                    ),
                    child: SizedBox(
                      height: kToolbarHeight,
                      width: double.infinity,
                      child: Center(
                        child: isLoadingSendImages
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Enviar imágenes",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              )
            : SafeArea(child: const SizedBox()),
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
                                          "Para un mejor procesamiento, tomar las imágenes ",
                                    ),
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
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 300,
                              height: 205.00 * widget.numberSegments!,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.blue, width: 5),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: _buildPhotoContainers(),
                                    ),
                                  ),
                                  SizedBox(height: 10),
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

  
  Future<String> convertAndResizeImageToBase64(File imageFile) async {
    try {
      final args = ImageProcessingArguments(imageFile.path, widget.numberSegments as int);
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
      if (await f.exists())
        await deleteImage(f.path, deleteParentDirs: deleteParentDirs);
    }
    lsOriginal.clear();

    for (var f in lsFixed) {
      if (await f.exists())
        await deleteImage(f.path, deleteParentDirs: deleteParentDirs);
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
  String esperaH = 'Error: Se esperaba una imagen horizontal.';
  String esperaV = 'Error: Se esperaba una imagen vertical.';
  
  final File file = File(args.imagePath);

  final String targetPath = await _getFixedPath(args.imagePath);
  img.Image? correctedImage = img.decodeImage(file.readAsBytesSync());

  if (correctedImage == null) {
    throw Exception(msgAtencion);
  }

  int width = correctedImage.width;
  int height = correctedImage.height;

  if (args.numberSegments == 2) {
    if (height > width) {
      // throw Exception(esperaH);
    }
  } else {
    if (width > height) {
      // throw Exception(esperaV);
    }
  }

  final File fixedFile = await File(targetPath).create();
  fixedFile.writeAsBytesSync(img.encodeJpg(correctedImage, quality: 90));

  final bytes = await fixedFile.readAsBytes();

  return base64Encode(bytes);
}