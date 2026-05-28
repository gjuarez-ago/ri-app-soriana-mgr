import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/params_supercito.dart';
import 'package:ago_app/models/supercito_segment_detail.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/show_general_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

class SupercitosDetailPage extends StatefulWidget {
  const SupercitosDetailPage({super.key, this.params});

  static String routeName = "supercitos_detail_page";

  final ParamsSupercito? params;

  @override
  State<SupercitosDetailPage> createState() => _SupercitosDetailPageState();
}

class _SupercitosDetailPageState extends State<SupercitosDetailPage> {
  RIBloc? _riBloc; // Declaración del BLoC
  SupercitoSegmentDetail? response;
  late ParamsSupercito params;
  bool _isParamsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isParamsInitialized) {
      // Si widget.params es null, toma los argumentos de la ruta
      if (widget.params == null) {
        final routeArgs =
            ModalRoute.of(context)!.settings.arguments as ParamsSupercito?;
        params = routeArgs!;
      } else {
        params = widget.params!;
      }

      _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
      _riBloc?.add(EventGetDetailTramoSupercito(
          idRealograma: params.idRealograma, tramo: params.tramo));
      _isParamsInitialized = true;
    }
  }

  @override
  void dispose() {
    // _riBloc?.close(); // Cerrar el BLoC al terminar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RIBloc, RIState>(
      listener: (context, state) {
        if (state is ErrorGetDetailTramoSupercito) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(state.messageError!)
            ),
          );
          Navigator.pop(context);
        } else if (state is SuccessGetDetailTramoSupercito) {
          setState(() {
            response = state.response;
          });

          Navigator.pop(context);
        } else if (state is IsLoadingGetDetailTramoSupercito) {
          showGeneralLoading(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Resumen del tramo',
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
          body: response == null
              ? const SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (response!.imagen.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewImagePage(imageUrl: response!.imagen),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 500,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildImageFromURL(response!.imagen),
                                const Center(
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      //    Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      //   child: Row(
                      //     children: [
                      //       Expanded(
                      //         child: Container(
                      //           color: Color.fromARGB(255, 39, 169, 39),
                      //           padding: const EdgeInsets.all(16),
                      //           margin: const EdgeInsets.only(right: 8),
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.center,
                      //             children: [
                      //               Text(
                      //                 '${response!.cajaAbierta}',
                      //                 style: const TextStyle(
                      //                     color: Colors.white,
                      //                     fontSize: 24,
                      //                     fontWeight: FontWeight.bold),
                      //               ),
                      //               const SizedBox(height: 8),
                      //               const Text(
                      //                 'Caja abierta',
                      //                 textAlign: TextAlign.center,
                      //                 style: TextStyle(
                      //                     fontSize: 16,
                      //                     color: Color.fromARGB(
                      //                         255, 255, 255, 255)),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //      Expanded(
                      //         child: Container(
                      //           color: const Color.fromARGB(255, 218, 186, 4),
                      //           padding: const EdgeInsets.all(16),
                      //           margin: const EdgeInsets.only(left: 8),
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.center,
                      //             children: [
                      //               Text(
                      //                 '${response!.sinCaja}',
                      //                 style: const TextStyle(
                      //                     color: Colors.white,
                      //                     fontSize: 24,
                      //                     fontWeight: FontWeight.bold),
                      //               ),
                      //               const SizedBox(height: 8),
                      //               const Text(
                      //                 'Sin caja',
                      //                 textAlign: TextAlign.center,
                      //                 style: TextStyle(
                      //                     fontSize: 16,
                      //                     color: Color.fromARGB(
                      //                         255, 250, 250, 250)),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),

                      //     ],
                      //   ),
                      // ),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        child: Container(
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
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildImageFromURL(String? url) {
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        color: Colors.black.withOpacity(0.5),
        colorBlendMode: BlendMode.darken,
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/example1.jpeg',
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.5),
          colorBlendMode: BlendMode.darken,
        ),
      );
    } else {
      return Image.asset(
        'assets/images/example1.jpeg',
        fit: BoxFit.cover,
        color: Colors.black.withOpacity(0.5),
        colorBlendMode: BlendMode.darken,
      );
    }
  }
}

class ViewImagePage extends StatelessWidget {

  final String imageUrl;
  const ViewImagePage({Key? key, required this.imageUrl}) : super(key: key);
  static String routeName = "view_image_page";

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
            imageProvider: _getImageProvider(imageUrl),
            enableRotation: true,
          ),
        ),
      ),
    );
  }
}

ImageProvider _getImageProvider(String imageUrl) {
  if (imageUrl.isNotEmpty) {
    // Usa CachedNetworkImageProvider para manejar la caché
    return CachedNetworkImageProvider(imageUrl);
  } else {
    // Imagen de reserva si la URL es vacía
    return AssetImage('assets/images/example1.jpeg');
  }
}
