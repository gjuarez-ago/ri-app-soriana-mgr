import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/furniture_segm_response.dart';
import 'package:ago_app/models/view_detail_tramo.dart';
import 'package:ago_app/pages/view_products/view_products_page.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/show_general_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

class ViewFurniturePage extends StatefulWidget {

  final ViewDetailTramo? params;
  const ViewFurniturePage({Key? key, this.params}) : super(key: key);
  static String routeName = "view_furniture_page";

  @override
  _ViewFurniturePageState createState() => _ViewFurniturePageState();
}

class _ViewFurniturePageState extends State<ViewFurniturePage> {
 
  RIBloc? _riBloc; // Declaración del BLoC
  FurnitureSegmentResponse? response;
  late ViewDetailTramo params;
  bool _isParamsInitialized = false;

 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isParamsInitialized) {
      // Si widget.params es null, toma los argumentos de la ruta
      if (widget.params == null) {
        final routeArgs = ModalRoute.of(context)!.settings.arguments as ViewDetailTramo?;
        params = routeArgs!;
      } else {
        params = widget.params!;
      }

      _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
      _riBloc?.add(EventGetResumeTramo(idReconocimiento: params.idReconocimiento, tramo: params.tramo!));

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

        if (state is ErrorGetResumeTramo) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(state.messageError!)
            ),
          );
          Navigator.pop(context);
        } else if (state is SuccessGetResumeTramo) {
          
          setState(() {
            response = state.response;
          });
          
          Navigator.pop(context);

        } else if (state is IsLoadingGetResumeTramo) {
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
          body: response == null
          ? const SizedBox(
              height: 400,
              child: Center(child: CircularProgressIndicator())
            ) 
          : SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (response!.imagen != null &&
                          response!.imagen!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewImagePage(imageUrl: response!.imagen!),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 500,
                        width: double.infinity,
                        child:
                        
                         Stack(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.green,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${response!.correctas}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Productos encontrados',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: const Color.fromARGB(255, 218, 186, 4),
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${response!.incidencias}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Productos no encontrados',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 250, 250, 250)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Color.fromARGB(255, 76, 104, 175)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                       
                          // if (response!.estatusTramo == 2) {
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) =>
                          //         CaptureProductPage(params: params),
                          //   ));
                          // }
            
                          if (response!.estatusTramo == 1 || response!.estatusTramo == 2) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ViewProductsPage(params: params),
                            ));
                          }
            
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text((response!.estatusTramo == 1 || response!.estatusTramo == 2)
                                ? 'Listado de productos'
                                : 'Sin productos',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
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
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
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
              colors: [  Constants.appBarStartColor,
                  Constants.appBarEndColor,],
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
  }}

   ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      // Usa CachedNetworkImageProvider para manejar la caché
      return CachedNetworkImageProvider(imageUrl);
    } else {
      // Imagen de reserva si la URL es vacía
      return AssetImage('assets/images/example1.jpeg');
    }
  }