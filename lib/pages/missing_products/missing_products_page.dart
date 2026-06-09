import 'dart:io';

import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/CapturarFaltanteParams.dart';
import 'package:ago_app/models/faltante_response.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/location_response.dart';
import 'package:ago_app/pages/bar_code/bar_code_page.dart';
import 'package:ago_app/pages/layout_missing_products/layout_missing_products_page.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/show_general_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class MissingProductsPage extends StatefulWidget {
  static String routeName = "missing_products_page";

  final GetIssuesParams? params;
  // final String? categoria;
  const MissingProductsPage({
    super.key, 
    this.params, 
    // this.categoria
  });

  @override
  State<MissingProductsPage> createState() => _MissingProductsPageState();
}

class _MissingProductsPageState extends State<MissingProductsPage>
    with TickerProviderStateMixin {
  // Asegúrate de usar TickerProviderStateMixin

  UbicacionResponse? resultadoSeleccionado;
  List<UbicacionResponse> listLocations = [];

  void _mostrarModalSeleccion(index, String upc) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // 🔒 No se puede cerrar tocando fuera
      builder: (context) {
        return AlertDialog(
                   backgroundColor: const Color.fromARGB(255, 255, 255, 255), // 👈 Fondo del diálogo

          title: const Text('¿Dónde encontró el producto?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var opcion in listLocations)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (opcion.idUbicacion == 0) {
                        Navigator.of(context).pop(); // Cierra el diálogo
                      } else if (opcion.ubicacion == "Inventario Fantasma") {
                        print(
                            "evento: ${widget.params!.evento}, sku: ${upc},idTienda: ${widget.params!.idTienda},categoria: ${widget.params!.idCategoria},idBitacora: ${widget.params!.idBitacora}, idUbicacion: ${opcion.idUbicacion}");

                        _riBloc?.add(EventCapturarFaltante(
                            request: CapturarFaltanteParams(
                                evento: widget.params!.evento,
                                sku: upc,
                                idTienda: widget.params!.idTienda,
                                categoria: widget.params!.idCategoria,
                                idBitacora: widget.params!.idBitacora,
                                idUbicacion: opcion.idUbicacion)));
                      } else {
                        Navigator.of(context).pop(); // Cierra el diálogo
                        _navigateToCamera(index, opcion.idUbicacion);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                            double.infinity, 50), // Ancho completo, altura 50
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        backgroundColor:
                            opcion.idUbicacion == 0 ? Colors.red : Colors.blue),
                    child: Text(
                      opcion.ubicacion,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<FaltanteResponse> listMissingProducts = [];
  List<FaltanteResponse> filteredTeoricos = [];
  List<FaltanteResponse> filteredNoTeoricos = [];

  List<FaltanteResponse> filteredProducts = [];
  RIBloc? _riBloc;
  TextEditingController _searchController = TextEditingController();

  // Variable para almacenar el código escaneado
  bool _isLoading = false; // Variable para manejar el estado de carga

  Future<void> _navigateToCamera(index, int idUbicacion) async {
    _isLoading = true;

    final String? image = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarCodePage(
          onUpcTaken: (upc) {
            setState(() {
              // filteredProducts[index].upc = upc;
              // filteredProducts[index].escaneado = true;
              //print("Incidencia: ${filteredProducts[index].upc}, $upc");
              // if (filteredProducts[index].upc.toString() != upc) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text(
              //         "El UPC faltante no coincide con el escaneado",
              //         style: TextStyle(
              //             color: Color.fromARGB(
              //                 255, 255, 255, 255)), // Texto blanco
              //       ),
              //       backgroundColor:
              //           Color.fromARGB(255, 208, 13, 13), // Fondo verde
              //     ),
              //   );
              //   Navigator.pop(context);
              //   return;
              // } else {
              _riBloc?.add(EventCapturarFaltante(
                  request: CapturarFaltanteParams(
                      evento: widget.params!.evento,
                      sku: upc,
                      idTienda: widget.params!.idTienda,
                      categoria: widget.params!.idCategoria,
                      idBitacora: widget.params!.idBitacora,
                      idUbicacion: idUbicacion)));

              // // }
              _isLoading = false;
            });
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    print(
        "evento: ${widget.params!.evento}, idCategoria: ${widget.params!.idCategoria}, idTienda: ${widget.params!.idTienda}, idBitacora: ${widget.params!.idBitacora}");

    _riBloc = BlocProvider.of<RIBloc>(context);
    _riBloc?.add(EventProductosFaltantes(
        params: GetIssuesParams(
            evento: widget.params!.evento,
            idCategoria: widget.params!.idCategoria,
            idTienda: widget.params!.idTienda,
            idBitacora: widget.params!.idBitacora)));
    _riBloc?.add(EventGetLocations());

    _tabController = TabController(length: 2, vsync: this); // Definir 2 tabs
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredProducts = listMissingProducts.where((producto) {
        return producto.nombreProd!.toLowerCase().contains(query);
      }).toList();

      print(filteredProducts.length);
    });
  }

  late TabController _tabController; // Controlador de las tabs

  Future<void> _refresh() async {
    // Aquí se actualizan los productos. Podrías llamar a tu Bloc para volver a cargar los datos.
    _riBloc?.add(EventProductosFaltantes(
        params: GetIssuesParams(
            evento: widget.params!.evento,
            idCategoria: widget.params!.idCategoria,
            idTienda: widget.params!.idTienda,
            idBitacora: widget.params!.idBitacora)));
  }

  @override
  void dispose() {
    listMissingProducts = [];
    _searchController.dispose();
    imageCache.clear(); // Limpiar caché de imágenes en memoria
    imageCache
        .clearLiveImages(); // Limpiar imágenes que están siendo utilizadas
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black
          ),
          centerTitle: true,
          title: Text(
            'Productos faltantes',
            textAlign: TextAlign.right,

            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              
            ),
          ),
          actions: [
            if (listMissingProducts.isNotEmpty)
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () async {
                  try {
                    await exportAndShareExcel(listMissingProducts, context);
                  } catch (e, st) {
                    debugPrint('exportAndShareExcel ERROR: $e\n$st');
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Error al exportar'),
                          content: SingleChildScrollView(
                            child: SelectableText('$e\n\n$st'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
              ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80), 
            child: Container(
              color: Colors.white,
              child: Column(
                children: [                 
                  // _ReviewSelection(
                  //   categoria: widget.categoria == null ? '' : widget.categoria!, 
                  //   event: widget.params!.evento
                  // ),
                
                  SizedBox(height: 15,),
                    
                  Padding(
                    padding: EdgeInsetsGeometry.directional(
                      start: 10,
                      end: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xfF7F7F7FF),
                          borderRadius: BorderRadius.circular(8),
                      ),
                      child: 
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(
                            child: SizedBox.expand(
                              child: Center(
                                child: Text(
                                  "Anaquel (${filteredTeoricos.length})",
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                          Tab(
                            child: SizedBox.expand(
                              child: Center(
                                child: Text(
                                  "Agotados (${filteredNoTeoricos.length})",
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                          // Tab(
                          //   text:
                          //       "Anaquel (${filteredTeoricos.length})", // Mostrar el total en el título
                          // ),
                          // Tab(
                          //   text:
                          //       "Agotados (${filteredNoTeoricos.length})", // Mostrar el total en el título
                          // ),
                        ],
                        isScrollable: false, 
                        indicatorColor: Colors.transparent,
                        dividerHeight: 0,
                        indicator: BoxDecoration(
                          color: Color(0xff379ae6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          elevation: 1,
          backgroundColor: Colors.white,
        ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<RIBloc, RIState>(
                listener: (context, state) {
                  if (state is ErrorProductosFaltantes) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.messageError!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }

                  if (state is SuccessGetLocations) {
                    setState(() {
                      listLocations = state.response;
                      listLocations.add(UbicacionResponse(
                          idUbicacion: 0, ubicacion: "Cerrar"));
                    });
                  }

                  if (state is ErrorGetLocations) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.messageError!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }

                  if (state is ErrorCapturarFaltante) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.messageError!),
                        backgroundColor: Colors.red,
                      ),
                    );

                    print(state.messageError);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }

                  if (state is SuccessResumenIndicadores) {
                    _riBloc?.add(EventProductosFaltantes(
                        params: GetIssuesParams(
                            evento: widget.params!.evento,
                            idCategoria: widget.params!.idCategoria,
                            idTienda: widget.params!.idTienda,
                            idBitacora: widget.params!.idBitacora)));
                    _searchController.addListener(_onSearchChanged);
                  }

                  if (state is IsLoadingProductosFaltantes){
                    showGeneralLoading(context);
                  }

                  if (state is SuccessProductosFaltantes) {
                    Navigator.pop(context);
                    setState(() {
                      listMissingProducts = state.productosFaltantes;
                      filteredNoTeoricos = listMissingProducts
                          .where((product) => product.esTeorico == true)
                          .toList();
                      filteredTeoricos = listMissingProducts
                          .where((product) => product.esTeorico == false)
                          .toList();
                    });
                  }

                  if (state is SuccessCapturarFaltante) {
                    // filteredProducts.removeAt(index);

                    if (!state.response.estatus) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${state.response.respuesta}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      Navigator.pop(context);
                      return;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${state.response.respuesta} '),
                          backgroundColor: Color.fromARGB(255, 10, 150, 5),
                          duration: Duration(
                              seconds: 5), // Ajusta el tiempo de duración aquí
                        ),
                      );

                      _riBloc?.add(EventResumenIndicadores(
                          params: GetIssuesParams(
                              evento: widget.params!.evento,
                              idCategoria: widget.params!.idCategoria,
                              idTienda: widget.params!.idTienda,
                              idBitacora: widget.params!.idBitacora)));

                      _searchController.text = "";
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  }

                  if (state is IsLoadingCapturarFaltante) {
                    showGeneralLoading(context);
                  }

                },
                builder: (context, state) {
                  if (state is IsLoadingProductosFaltantes ||
                      state is IsLoadingCapturarFaltante) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SuccessProductosFaltantes) {
                    return TabBarView(
                      // Cambiar TabBarView según la selección
                      controller: _tabController,
                      children: [
                        // Primer tab (productos teóricos)
                        RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            itemCount: filteredTeoricos.length,
                            itemBuilder: (context, index) {
                              return itemMissingPage(
                                  filteredTeoricos[index], index);
                            },
                          ),
                        ),
                        // Segundo tab (productos no teóricos)
                        RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            itemCount: filteredNoTeoricos.length,
                            itemBuilder: (context, index) {
                              return itemMissingPage(
                                  filteredNoTeoricos[index], index);
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return TabBarView(
                      // Cambiar TabBarView según la selección
                      controller: _tabController,
                      children: [
                        // Segundo tab (podrías poner una lista diferente aquí si es necesario)
                        RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            itemCount: filteredTeoricos.length,
                            itemBuilder: (context, index) {
                              return itemMissingPage(
                                  filteredTeoricos[index], index);
                            },
                          ),
                        ),

                        // Primer tab
                        RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            itemCount: filteredNoTeoricos.length,
                            itemBuilder: (context, index) {
                              return itemMissingPage(
                                  filteredNoTeoricos[index], index);
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemMissingPage(FaltanteResponse producto, int index) {
    return Padding(
  padding: const EdgeInsets.only(left: 5, right: 5),
  child: GestureDetector(
    onLongPress: () async {
      // await _navigateToCamera(index);
      if (!producto.esTeorico) {
        _mostrarModalSeleccion(index, producto.sku!);
      }
    },
    child: Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xffEBEBEAFF),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(5),
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            _CardHeader(
              context: context,
              urlImage: producto.rutaPublica ?? 'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
              nombreProd: producto.nombreProd!,
              upc: producto.upc!,
              sku: producto.sku!,
            ),
    
            _CardBody(
              eventosFaltantes: producto.vecesFaltante,
              maxEventosFaltantes: producto.eventosMaximoFaltante,
              unidades: producto.existencia,
              fechaUltimaRecepcion: producto.fechaAlmacen!,
            ),
    
            Container(            
              margin: EdgeInsets.symmetric(vertical: 2.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              width: MediaQuery.of(context).size.width - 32,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shadowColor: Colors.transparent, // Remove shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(                // 👈 Contorno rojo
                      color: Color(0xff646ae8),
                      width: 1,
                    ),
                  ),
                ),
                onPressed: () {
                  //  if (!producto.conUbicacion){
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(
                  //       content: Text("El producto no cuenta con planogramas disponibles"),
                  //       backgroundColor: const Color.fromARGB(255, 16, 16, 16),
                  //     ),
                  //   );
                  //   return;
                  //  }

                  print("IMAGEN: ${producto.rutaPublica}");
    
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        LayoutMissingProductsPage(
                      evento: widget.params!.evento,
                      idCategoria: widget.params!.idCategoria,
                      tienda: widget.params!.idTienda,
                      bitacora: widget.params!.idBitacora,
                      params: producto,
                    ),
                  ));
                   
                },
                icon: Icon(Icons.location_on_outlined, color: Color(0xff646ae8),),
                label: const Text(
                  'Ver ubicación en planograma',
                  style: TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xff646ae8)
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
    
          ],
        ),
      ),
    ),
  ),
);



    // Center(
    //   child: Container(
    //     margin: const EdgeInsets.only(top: 1.0),
    //     padding: const EdgeInsets.all(10),
    //     child: Column(
    //       children: [
    //         // ClipRRect envuelve tanto la línea de color como el Card para que los bordes se redondeen correctamente
    //         ClipRRect(    
    //           borderRadius:
    //               BorderRadius.circular(15), // Aplicando redondeo a ambos
    //           child: Column(
    //             children: [
    //               // Contenedor para la línea superior con bordes redondeados
    //               Container(
    //                 height: 5, // Altura de la línea
    //                 color: !producto.esTeorico
    //                     ? Color.fromARGB(255, 227, 208, 38)
    //                     : Colors.red, // Color dinámico
    //               ),
    //               // Tarjeta con bordes redondeados
    //               Card(
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius:
    //                       BorderRadius.circular(15), // Redondeo del Card
    //                 ),
    //                 margin:
    //                     EdgeInsets.zero, // Eliminar margen adicional en el Card
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(10.0),
    //                   child: ListTile(
    //                     // Imagen al lado izquierdo
    //                     leading: InkWell(
    //                       onTap: () {
    //                         Navigator.push(
    //                           context,
    //                           MaterialPageRoute(
    //                             builder: (context) => ImagePreviewPage(
    //                               imageUrl: producto.rutaPublica ??
    //                                   'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
    //                             ),
    //                           ),
    //                         );
    //                       },
    //                       child: CachedNetworkImage(
    //                         imageUrl: producto.rutaPublica ??
    //                             'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
    //                         placeholder: (context, url) => Container(
    //                           width: 40,
    //                           height: 40,
    //                           color: Colors.grey[200],
    //                           child: Center(child: CircularProgressIndicator()),
    //                         ),
    //                         errorWidget: (context, url, error) => Container(
    //                           width: 40,
    //                           height: 40,
    //                           color: Colors.grey[200],
    //                           child: Image.network(
    //                             'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
    //                             fit: BoxFit.cover,
    //                           ),
    //                         ),
    //                         fit: BoxFit.cover,
    //                       ),
    //                     ),
    //                     // Contenido principal
    //                     title: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text(
    //                           // "${producto.upc} (${producto.sku})",
    //                           "${producto.upc}",
    //                           style: TextStyle(fontWeight: FontWeight.bold),
    //                         ),
    //                         Text(
    //                           // "${producto.upc} (${producto.sku})",
    //                           "${index + 1}",
    //                           style: TextStyle(
    //                               fontWeight: FontWeight.w200, fontSize: 12),
    //                         ),
    //                       ],
    //                     ),
    //                     subtitle: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         const SizedBox(height: 5),
    //                         Text(
    //                           producto.nombreProd,
    //                           maxLines: 2,
    //                           overflow: TextOverflow.ellipsis,
    //                         ),
    //                         const SizedBox(height: 5),
    //                         Text(producto.fcSubClase +
    //                             " (${producto.metodoResurtido})"),
    //                         const SizedBox(height: 5),
    //                         Wrap(
    //                           spacing: 8.0, // Espacio entre los contenedores
    //                           runSpacing:
    //                               4.0, // Espacio entre líneas si se envuelven
    //                           children: [
    //                             // Container(
    //                             //   margin: const EdgeInsets.all(2),
    //                             //   padding: const EdgeInsets.symmetric(
    //                             //       horizontal: 10, vertical: 5),
    //                             //   decoration: BoxDecoration(
    //                             //     color: Color.fromARGB(255, 239, 225, 134),
    //                             //     borderRadius: BorderRadius.circular(5),
    //                             //   ),
    //                             //   child: Wrap(
    //                             //     crossAxisAlignment:
    //                             //         WrapCrossAlignment.center,
    //                             //     spacing: 5,
    //                             //     children: [
    //                             //       Icon(
    //                             //         Icons.numbers,
    //                             //         color: Colors.white,
    //                             //       ),
    //                             //       ConstrainedBox(
    //                             //         constraints:
    //                             //             BoxConstraints(maxWidth: 200),
    //                             //         child: Text(
    //                             //           "Palet ${producto.numPalet}",
    //                             //           style: TextStyle(
    //                             //               color: Color.fromARGB(
    //                             //                   255, 255, 255, 255)),
    //                             //         ),
    //                             //       ),
    //                             //     ],
    //                             //   ),
    //                             // ),
    //                             Container(
    //                               margin: const EdgeInsets.all(2),
    //                               padding: const EdgeInsets.symmetric(
    //                                   horizontal: 10, vertical: 5),
    //                               decoration: BoxDecoration(
    //                                 color: !producto.esTeorico
    //                                     ? Color.fromARGB(255, 227, 208, 38)
    //                                     : Colors.red, // Color dinámico
    //                               ),
    //                               child: Wrap(
    //                                 crossAxisAlignment:
    //                                     WrapCrossAlignment.center,
    //                                 spacing: 5,
    //                                 children: [
    //                                   Icon(
    //                                     Icons.maps_home_work_outlined,
    //                                     color: Colors.white,
    //                                   ),
    //                                   ConstrainedBox(
    //                                     constraints:
    //                                         BoxConstraints(maxWidth: 200),
    //                                     child: Text(
    //                                       "Existencias: ${producto.existencia}",
    //                                       style: TextStyle(color: Colors.white),
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                         const SizedBox(width: 10),
    //                         Container(
    //                           margin: const EdgeInsets.all(2),
    //                           padding: const EdgeInsets.symmetric(
    //                               horizontal: 10, vertical: 5),
    //                           decoration: BoxDecoration(
    //                             color: Color.fromARGB(255, 229, 122, 114),
    //                             borderRadius: BorderRadius.circular(5),
    //                           ),
    //                           child: Wrap(
    //                             crossAxisAlignment: WrapCrossAlignment.center,
    //                             spacing: 5, // Espacio entre el ícono y el texto
    //                             children: [
    //                               Icon(
    //                                 Icons
    //                                     .motion_photos_on_rounded, // Cambia el ícono según tus necesidades
    //                                 color: Colors.white,
    //                               ),
    //                               ConstrainedBox(
    //                                 constraints: BoxConstraints(
    //                                     maxWidth:
    //                                         200), // Ajusta el ancho máximo aquí
    //                                 child: Text(
    //                                   producto.vecesFaltante.toString() +
    //                                       " veces faltante en los últimos 15 días",
    //                                   style: TextStyle(color: Colors.white),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                         const SizedBox(width: 10),
    //                         InkWell(
    //                           onTap: () {
    //                             if (producto.conUbicacion) {
    //                               Navigator.of(context).push(MaterialPageRoute(
    //                                 builder: (context) =>
    //                                     LayoutMissingProductsPage(
    //                                   evento: widget.params!.evento,
    //                                   idCategoria: widget.params!.idCategoria,
    //                                   tienda: widget.params!.idTienda,
    //                                   bitacora: widget.params!.idBitacora,
    //                                   params: producto,
    //                                 ),
    //                               ));
    //                             }

    //                             FocusScope.of(context).unfocus();
    //                           },
    //                           child: Container(
    //                             margin: const EdgeInsets.all(2),
    //                             padding: const EdgeInsets.symmetric(
    //                                 horizontal: 10, vertical: 5),
    //                             decoration: BoxDecoration(
    //                               color: producto.conUbicacion
    //                                   ? Color.fromARGB(255, 114, 154, 229)
    //                                   : Color.fromARGB(255, 90, 173, 225),
    //                               borderRadius: BorderRadius.circular(5),
    //                             ),
    //                             child: Row(
    //                               children: [
    //                                 Icon(
    //                                   producto.conUbicacion
    //                                       ? Icons.ads_click
    //                                       : Icons
    //                                           .lock, // Cambia el icorno según tus necesidades
    //                                   color: Colors.white,
    //                                 ),
    //                                 const SizedBox(
    //                                     width:
    //                                         5), // Espacio entre el icono y el texto
    //                                 Text(
    //                                   producto.conUbicacion
    //                                       ? "Ver Ubicación planograma "
    //                                       : "No en planograma",
    //                                   style: TextStyle(color: Colors.white),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                         ),
    //                         const SizedBox(
    //                           width: 10,
    //                         ),
    //                         Container(
    //                           margin: const EdgeInsets.all(2),
    //                           padding: const EdgeInsets.symmetric(
    //                               horizontal: 10, vertical: 5),
    //                           decoration: BoxDecoration(
    //                             color: Color.fromARGB(255, 27, 130, 48),
    //                             borderRadius: BorderRadius.circular(5),
    //                           ),
    //                           child: Wrap(
    //                             crossAxisAlignment: WrapCrossAlignment.center,
    //                             spacing: 5,
    //                             children: [
    //                               Icon(
    //                                 Icons.maps_home_work_outlined,
    //                                 color: Colors.white,
    //                               ),
    //                               ConstrainedBox(
    //                                 constraints: BoxConstraints(maxWidth: 200),
    //                                 child: Text(
    //                                   "Fecha de último recibo: ${producto.fechaAlmacen}",
    //                                   style: TextStyle(color: Colors.white),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     onTap: () {
    //                       FocusScope.of(context).unfocus();
    //                     },
    //                     onLongPress: () async {
    //                       // await _navigateToCamera(index);
    //                       if (!producto.esTeorico) {
    //                         _mostrarModalSeleccion(index, producto.sku);
    //                       }
    //                     },
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

 Future<void> exportAndShareExcel(List<FaltanteResponse> list, BuildContext context) async {
    // 1. Crear Excel
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // 2. Encabezados
    sheetObject.appendRow([
      TextCellValue("Categoría"),
      TextCellValue("Subclase"),
      TextCellValue("SKU"),
      TextCellValue("UPC"),
      TextCellValue("Nombre Producto"),
      TextCellValue("Método Resurtido"),
      TextCellValue("Existencias"),
      TextCellValue("Es Teórico"),
      TextCellValue("Veces Faltante"),
      TextCellValue("Fecha de último recibo"),
      TextCellValue("Proveedor"),
    ]);

    // 3. Datos
   for (final item in list) {
      sheetObject.appendRow([
        TextCellValue(item.fcCategoriaPln ?? ""),
        TextCellValue(item.fcSubClase ?? ""),
        TextCellValue(item.sku ?? ""),
        TextCellValue(item.upc ?? ""),
        TextCellValue(item.nombreProd ?? ""),
        TextCellValue(item.metodoResurtido ?? ""),
        IntCellValue(item.existencia),
        TextCellValue(item.esTeorico ? "Sí" : "No"),
        IntCellValue(item.vecesFaltante),
        TextCellValue(item.fechaAlmacen ?? ""),
        TextCellValue(item.proveedor ?? ""),
      ]);
    }

    // 4. Guardar temporalmente
    Directory directory = await getTemporaryDirectory();
    String filePath = "${directory.path}/faltantes.xlsx";
    File(filePath).writeAsBytesSync(excel.save()!);

    // 5. Compartir
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Archivo Excel de Faltantes',
    );
  }
}

class _CardBody extends StatelessWidget {
  final int eventosFaltantes;
  final int maxEventosFaltantes;
  final int unidades;
  final String fechaUltimaRecepcion;

  const _CardBody({
    required this.eventosFaltantes, 
    required this.maxEventosFaltantes, 
    required this.unidades, 
    required this.fechaUltimaRecepcion
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Elemento 1 (32%) con ícono + texto a la derecha
            Expanded(
              flex: 32,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/eventos-faltante-icono.png',
                      height: 15,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Eventos\nfaltantes:",
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Elemento 2 (18%)
            Expanded(
              flex: 18,
              child: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.centerLeft,
                child: Text(
                  "${eventosFaltantes}/${maxEventosFaltantes}\neventos",
                  style: TextStyle(
                    color: Color(0xffe8618c),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Elemento 3 (32%)
            Expanded(
              flex: 32,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/existencia-tienda-icono.png',
                      height: 15,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Existencia\nen tienda:",
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Elemento 4 (18%)
            Expanded(
              flex: 18,
              child: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.centerLeft,
                child: Text(
                  "${unidades}\nunidades",
                  style: TextStyle(
                    color: Color(0xff15a349),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Row nuevo (40% y 60%)
        Row(
          children: [
            Expanded(
              flex: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/ultima-recepcion-icono.png',
                      height: 15,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Última recepción:",
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                alignment: Alignment.centerLeft,
                child: Text(
                  fechaUltimaRecepcion.substring(0,10),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class _CardHeader extends StatelessWidget {
  
    final String urlImage;
    final String nombreProd;
    final String upc;
    final String sku;

  const _CardHeader({
    required this.context, 
    required this.urlImage, 
    required this.nombreProd, 
    required this.upc, 
    required this.sku,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        // Imagen 30% con tamaño fijo más pequeño
        Expanded(
          flex: 3,
          child: Center(
            child: SizedBox(
              width: 60,  // 👈 ancho fijo
              height: 60, // 👈 alto fijo
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewPage(
                        imageUrl: urlImage,
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: urlImage,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.network(
                    'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
                    fit: BoxFit.contain,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
    
        // Texto 70%
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreProd ?? 'Nombre no disponible',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'UPC: ${upc ?? 'Sin descripción'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${sku ?? 'Sin descripción'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Imagen del producto',
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
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(), // Placeholder de carga
          ),
          errorWidget: (context, url, error) => Container(
            width: 40,
            height: 40,
            color: Colors.grey[200],
            child: Image.network(
              'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
              fit: BoxFit.cover,
            ),
          ),
          imageBuilder: (context, imageProvider) => PhotoView(
            imageProvider: imageProvider,
          ),
        ),
      ),
    );
  }
}

class _ReviewSelection extends StatelessWidget {
  const _ReviewSelection({    
    required this.categoria,
    required this.event,
  });

  final int event;
  final String categoria;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.all(10),
      decoration: BoxDecoration(
        color: Color(0xff379ae6),
        borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Categoría:  ${categoria}', 
            style: TextStyle(
              color: Colors.white,
              fontSize: 15, 
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            'Evento: ${event}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}
