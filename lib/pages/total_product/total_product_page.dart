import 'package:ago_app/bloc/ri/bloc.dart';
import 'package:ago_app/models/detalle_nivel_response.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/muebles_categoria_response.dart';
import 'package:ago_app/models/tramos_mueble_response.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';


class TotalProductPage extends StatefulWidget {


  final GetIssuesParams? params;
  final int? origin;

  static String routeName = "total_product_page";

  const TotalProductPage({super.key, this.params,  this.origin});

  @override
  State<TotalProductPage> createState() => _TotalProductPageState();
}

class _TotalProductPageState extends State<TotalProductPage> {
  RIBloc? _riBloc;

  bool _isCategoryEnabled = false;

  List<MueblesCategoriaResponse> listMueblesCategorias = [];
  List<TramosMuebleResponse> listTramosMuebles = [];

  TramosMuebleResponse? _selectedCategory;
  MueblesCategoriaResponse? _selectedStore;
  List<DropdownMenuItem<String>> items = [];

  int? _selectNivel = 1;

  List<DetalleNivelResponse> listDetalleNivel = [];

  @override
  void initState() {
    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    _riBloc?.add(EventGetMueblesCategoria(
        request: GetIssuesParams(
            evento: widget.params!.evento,
            idCategoria: widget.params!.idCategoria,
            idTienda: widget.params!.idTienda,
            idBitacora: widget.params!.idBitacora), esSupercito: widget.origin == 1 ? true : false));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [blocListeners(context)],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Total producto',
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //Spinner Eventos
                
                  BlocBuilder<RIBloc, RIState>(
                    builder: (context, state) {
                      if (state is IsLoadingGetMueblesCategoria) {
                        return const Center(
                            child: Text(
                          'Cargando muebles...',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ));
                      } else if (state is ErrorGetMueblesCategoria) {
                        return Center(
                            child: Text(
                          state.messageError ?? 'Error al cargar los muebles',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ));
                      } else if (state is SuccessGetMueblesCategoria) {
                        listMueblesCategorias = state.response;
                
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            // listMueblesCategorias = [];
                          });
                        });
                
                        return DropdownButtonFormField<MueblesCategoriaResponse>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Selecciona un mueble',
                            border: OutlineInputBorder(),
                          ),
                                dropdownColor: Colors
                              .white, // 👈 fondo blanco del menú desplegable

                          items: listMueblesCategorias.isEmpty
                              ? [
                                  const DropdownMenuItem<
                                      MueblesCategoriaResponse>(
                                    value: null,
                                    child: Text(
                                      'No hay muebles disponibles',
                                    ),
                                  )
                                ]
                              : listMueblesCategorias
                                  .map((MueblesCategoriaResponse store) {
                                  return DropdownMenuItem<
                                      MueblesCategoriaResponse>(
                                    value: store,
                                    child: Text(
                                      "${store.nombreRealograma} (${store.idRealograma})",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStore = value;
                              _isCategoryEnabled = value != null;
                              _selectedCategory = null;
                
                              // listEvents = [];
                
                              if (value != null) {
                                _riBloc?.add(EventGetTramosMueble(
                                    idRealograma: _selectedStore!.idRealograma,
                                    idReconocimiento:
                                        _selectedStore!.idReconocimiento, esSupercito: widget.origin == 1 ? true : false));
                              }
                            });
                          },
                          value: _selectedStore,
                        );
                      } else {
                        return DropdownButtonFormField<MueblesCategoriaResponse>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Selecciona un mueble',
                            border: OutlineInputBorder(),
                          ),
                            dropdownColor: Colors
                              .white, // 👈 fondo blanco del menú desplegable

                          items: listMueblesCategorias.isEmpty
                              ? [
                                  const DropdownMenuItem<
                                      MueblesCategoriaResponse>(
                                        
                                    value: null,
                                    child: Text('No hay muebles disponibles'),
                                  )
                                ]
                              : listMueblesCategorias
                                  .map((MueblesCategoriaResponse store) {
                                  return DropdownMenuItem<
                                      MueblesCategoriaResponse>(
                                    value: store,
                                    child: Text(
                                      "${store.nombreRealograma} (${store.idRealograma})",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStore = value;
                              _isCategoryEnabled = value != null;
                              _selectedCategory = null;
                
                              // listEvents = [];
                              if (value != null) {
                                _riBloc?.add(EventGetTramosMueble(
                                    idRealograma: _selectedStore!.idRealograma,
                                    idReconocimiento:
                                        _selectedStore!.idReconocimiento,  esSupercito: widget.origin == 1 ? true : false));
                              }
                            });
                          },
                          value: _selectedStore,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                
                  // Combo de Categorías
                  BlocBuilder<RIBloc, RIState>(
                    builder: (context, state) {
                      if (state is IsLoadingGetTramosMueble) {
                        return const Center(child: Text('Cargando tramos...'));
                      } else if (state is ErrorGetTramosMueble) {
                        return Center(
                            child: Text(state.messageError ??
                                'Error al cargar los tramos'));
                      } else if (state is SuccessGetTramosMueble) {
                        print(listTramosMuebles.length);
                        listTramosMuebles = state.response;
                        return DropdownButtonFormField<TramosMuebleResponse>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Selecciona un tramo',
                            border: OutlineInputBorder(),
                          ),
                                dropdownColor: Colors
                              .white, // 👈 fondo blanco del menú desplegable

                          items: listTramosMuebles.isEmpty
                              ? [
                                  const DropdownMenuItem<TramosMuebleResponse>(
                                    value: null,
                                    child: Text('No hay tramos disponibles'),
                                  )
                                ]
                              : listTramosMuebles
                                  .map((TramosMuebleResponse category) {
                                  return DropdownMenuItem<TramosMuebleResponse>(
                                    value: category,
                                    child: Text(
                                      "Tramo ${category.tramo}",
                                    ),
                                  );
                                }).toList(),
                          onChanged: _isCategoryEnabled
                              ? (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                    // listEvents = [];
                                    if (value != null) {
                                      // print("${_selectedCategory} ${_selectedStore!.claveTienda}");
                
                                      //    GetIssuesParams params = GetIssuesParams(
                                      //   evento: _selectedStore!.evento,
                                      //   idCategoria: _selectedCategory.toString(),
                                      //   idTienda: _selectedStore!.claveTienda);
                                      _riBloc?.add(EventGetImagenTramo(
                                          nivel: _selectNivel!,
                                          idReconocimiento:
                                              _selectedStore!.idReconocimiento,
                                          idRealograma:
                                              _selectedStore!.idRealograma,
                                          tramo: _selectedCategory!.tramo,  esSupercito: widget.origin == 1 ? true : false));
                                    }
                                  });
                                }
                              : null,
                          value: _selectedCategory,
                          disabledHint: Text('Selecciona un mueble primero'),
                        );
                      } else {
                        return DropdownButtonFormField<TramosMuebleResponse>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Selecciona un tramo',
                            border: OutlineInputBorder(),
                          ),
                                dropdownColor: Colors
                              .white, // 👈 fondo blanco del menú desplegable

                          items: listTramosMuebles.isEmpty
                              ? [
                                  DropdownMenuItem<TramosMuebleResponse>(
                                    value: null,
                                    child: Text('No hay tramos disponibles'),
                                  )
                                ]
                              : listTramosMuebles
                                  .map((TramosMuebleResponse category) {
                                  return DropdownMenuItem<TramosMuebleResponse>(
                                    value: category,
                                    child: Text(
                                      "Tramo ${category.tramo}",
                                    ),
                                  );
                                }).toList(),
                          onChanged: _isCategoryEnabled
                              ? (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                    // listEvents = [];
                                    if (value != null) {
                                      _riBloc?.add(EventGetImagenTramo(
                                          nivel: _selectNivel!,
                                          idReconocimiento:
                                              _selectedStore!.idReconocimiento,
                                          idRealograma:
                                              _selectedStore!.idRealograma,
                                          tramo: _selectedCategory!.tramo,  esSupercito: widget.origin == 1 ? true : false));
                                    }
                                  });
                                }
                              : null,
                          value: _selectedCategory,
                          disabledHint:
                              const Text('Selecciona un mueble primero'),
                        );
                      }
                    },
                  ),
                
                  Column(
                    children: [
                      BlocBuilder<RIBloc, RIState>(
                        builder: (context, state) {
                          if (state is IsLoadingGetImagenTramo) {
                            return Container(
                              margin: EdgeInsets.only(top: 120.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                
                          if (state is SuccessGetImagenTramo) {
                            return Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 20.0),
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Card(
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewImagePage(
                                                        imageUrl: state
                                                            .response.imageUrl),
                                              ),
                                            );
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.4,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                    image: _getImageProvider(
                                                        state.response.imageUrl),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewImagePage(
                                                              imageUrl: state
                                                                  .response
                                                                  .imageUrl),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.remove_red_eye,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  size: 50,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 8.0),
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            'Tramo ${_selectedCategory?.tramo ?? ''}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    labelText: _selectedCategory == null
                                        ? 'Selecciona un tramo'
                                        : "Selecciona un nivel",
                                    border: const OutlineInputBorder(),
                                  ),
                                        dropdownColor: Colors
                              .white, // 👈 fondo blanco del menú desplegable

                                  items: _buildDropdownItems(
                                      _selectedCategory == null
                                          ? 0
                                          : _selectedCategory!.niveles),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectNivel = value;
                
                                      _riBloc?.add(EventGetImagenTramo(
                                          nivel: value!,
                                          idReconocimiento:
                                              _selectedStore!.idReconocimiento,
                                          idRealograma:
                                              _selectedStore!.idRealograma,
                                          tramo: _selectedCategory!.tramo,  esSupercito: widget.origin == 1 ? true : false));
                                    });
                                  },
                                  value: _selectNivel,
                                ),
                                const SizedBox(height: 16),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Secuencia')),
                                      DataColumn(label: Text('UPC')),
                                      DataColumn(label: Text('Descripción')),
                                    ],
                                    rows: state.response.detalleNivel
                                        .map((detalle) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                              Text(detalle.secuencia.toString())),
                                          DataCell(Text(detalle.upc ??
                                              'Sin nombre')),
                                          DataCell(Text(detalle.prodName ??
                                              'Sin nombre')),
                                          // Reemplaza 'detalle.nivel' por el campo correcto
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          }
                
                          return Text("");
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> _buildDropdownItems(int itemCount) {
    if (itemCount <= 0) {
      return [];
    }

    return List<DropdownMenuItem<int>>.generate(itemCount, (index) {
      return DropdownMenuItem<int>(
        value: index + 1,
        child: Text('Nivel ${index + 1}'),
      );
    });
  }

  BlocListener blocListeners(BuildContext context) {
    return BlocListener<RIBloc, RIState>(listener: (context, state) {
      if (state is IsLoadingGetMueblesCategoria ||
          state is IsLoadingGetImagenTramo ||
          state is IsLoadingGetDetalleNivel) {
        // showGeneralLoading(context);
      }

      if (state is SuccessGetMueblesCategoria) {
        setState(() {
          // Navigator.pop(context);
        });
      }

      if (state is SuccessGetImagenTramo) {
        setState(() {
          // _riBloc?.add(EventGetDetalleNivel(request: DetalleNivelParams(idRealograma: _selectedStore!.idRealograma, nivel: _selectNivel!, tramo: _selectedCategory!.tramo)));
          // Navigator.pop(context);
        });
      }

      if (state is SuccessGetDetalleNivel) {
        setState(() {
          listDetalleNivel = state.response;
          // Navigator.pop(context);
        });
      }

      if (state is ErrorGetMueblesCategoria || state is ErrorGetImagenTramo) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              state.messageError!,
              style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0)), // Texto blanco
            ),
            backgroundColor:
                const Color.fromARGB(255, 244, 36, 36), // Fondo verde
          ),
        );
        Navigator.pop(context);
      }
    });
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
