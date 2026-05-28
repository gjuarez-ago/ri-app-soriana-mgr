import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/FurnitureSupercitosResponse.dart';
import 'package:ago_app/models/category_response.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/segmentsSupercitos.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/models/supercito_segment_eventos.dart';
import 'package:ago_app/pages/business/business_page.dart';
import 'package:ago_app/pages/supercitos_search/customer_business.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/generic_pages.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SupercitoStatsPage extends StatefulWidget {
  const SupercitoStatsPage({super.key});

  static String routeName = "supercitos_stats_page";

  @override
  State<SupercitoStatsPage> createState() => _SupercitoStatsPageState();
}

class _SupercitoStatsPageState extends State<SupercitoStatsPage> {
  RIBloc? _riBloc; // Declaración del BLoC

  StoreResponse? _selectedStore;
  CategoryResponse? _selectedFurniture;

  bool _isFurnitureEnabled = false;
  int? tramoMasCercano;
  int? tramoMasCercanoDelete;

  SegmentsSupercitos? tramoSelected;
  var numberIncidents;

  @override
  void initState() {
    super.initState();
    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    _riBloc?.add(EventGetStoresSupercitos(category: "102"));
  }

  List<StoreResponse> listStoreResponse = [];
  List<CategoryResponse> listCategories = [];

  List<SupercitoSegmentEventos> statsResponse = [];

  bool isReadyToEvaluate = false;

  @override
  void dispose() {
    // _riBloc?.close(); // Cerrar el BLoC al terminar
    listStoreResponse = [];
    listCategories = [];
    statsResponse = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Análisis supercitos',
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
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<RIBloc, RIState>(
                    builder: (context, state) {
                      if (state is IsLoadingGetStoresSupercitos) {
                        return DropdownSearch<StoreResponse>(
                          popupProps: PopupProps.menu(
                              menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                            showSearchBox: false,
                            disabledItemFn: (_) =>
                                true, // Deshabilitar interacción mientras carga
                          ),
                          items: (f, cs) => [], // No hay elementos mientras carga
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: 'Cargando tiendas...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged: null, // Deshabilitado
                          enabled:
                              false, // El widget completo está deshabilitado
                        );
                      } else if (state is ErrorGetStoresSupercitos) {
                        return Center(
                          child: Text(state.messageError ??
                              'Error al cargar los tiendas'),
                        );
                      } else if (state is SuccessGetStoresSupercitos) {
                        listStoreResponse = state.response;

                        return listStoreResponse.isNotEmpty
                            ? DropdownSearch<StoreResponse>(
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                    menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                ),
                                items: (f, cs) => listStoreResponse,
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'Selecciona una tienda',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                itemAsString: (StoreResponse store) =>
                                    store.tienda!, // Mostrar nombres en el menú
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStore = value;

                                    _isFurnitureEnabled = value !=
                                        null; // Habilitar tienda si se selecciona tienda
                                    _selectedFurniture =
                                        null; // Resetear eventos
                                    // Deshabilitar eventos

                                    statsResponse = []; // Limpiar segmentos

                                    if (value != null) {
                                      _riBloc?.add(
                                          EventGetCategorieSupercito()); // Cargar tiendas para la tienda seleccionada // Cargar tiendas para la tienda seleccionada
                                    }
                                  });
                                }, // Si no está habilitado, se desactiva
                                selectedItem: _selectedStore,
                              )
                            : DropdownSearch<StoreResponse>(
                                popupProps: PopupProps.menu(
                                  showSearchBox: false,
                                    menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                ),
                                items: (f, cs) => [],
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'No hay tiendas disponibles...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                onChanged: null, // Dropdown deshabilitado
                                enabled: false, // Deshabilitar interacción
                              );
                      } else {
                        return listStoreResponse.isNotEmpty
                            ? DropdownSearch<StoreResponse>(
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                    menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                ),
                                items: (f, cs) => listStoreResponse,
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'Selecciona una tienda',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                itemAsString: (StoreResponse store) =>
                                    store.tienda!, // Mostrar nombres en el menú
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStore = value;

                                    _isFurnitureEnabled = value !=
                                        null; // Habilitar tienda si se selecciona tienda
                                    _selectedFurniture =
                                        null; // Resetear eventos
                                    // Deshabilitar eventos

                                    statsResponse = []; // Limpiar segmentos

                                    if (value != null) {
                                      _riBloc?.add(
                                          EventGetCategorieSupercito()); // Cargar tiendas para la tienda seleccionada
                                    }
                                  });
                                }, // Si no está habilitado, se desactiva
                                selectedItem: _selectedStore,
                              )
                            : DropdownSearch<StoreResponse>(
                                popupProps: PopupProps.menu(
                                  showSearchBox: false,
                                    menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                ),
                                items: (f, cs) => [],
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'No hay tiendas disponibles...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                onChanged: null, // Dropdown deshabilitado
                                enabled: false, // Deshabilitar interacción
                              );
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  BlocBuilder<RIBloc, RIState>(
                    builder: (context, state) {
                      if (state is IsLoadingGetCategoriesByUPC) {
                        return DropdownSearch<FurnitureSupercitosResponse>(
                          popupProps: PopupProps.menu(
                              menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                            showSearchBox: false,
                            disabledItemFn: (_) =>
                                true, // Deshabilitar interacción mientras carga
                          ),
                          items: (f, cs) => [], // No hay elementos mientras carga
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: 'Cargando categorías...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged: null, // Deshabilitado
                          enabled:
                              false, // El widget completo está deshabilitado
                        );
                      } else if (state is ErrorGetCategoriesSupercito) {
                        return Center(
                          child: Text(state.messageError ??
                              'Error al cargar las categorías'),
                        );
                      } else if (state is SuccessGetCategoriesSupercito) {
                        listCategories = state.response;

                        return listCategories.isNotEmpty
                            ? DropdownSearch<CategoryResponse>(
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                    menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                ),
                                items: (f, cs) => listCategories,
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'Selecciona una categoría',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                itemAsString: (CategoryResponse store) =>
                                    "${store.fcCategoria}",
                                onChanged: _isFurnitureEnabled
                                    ? (value) {
                                        setState(() {
                                          _selectedFurniture = value;
                                          statsResponse = [];

                                          if (value != null) {
                                            _riBloc?.add(
                                                EventGetEventsSupercito(
                                                    tienda: _selectedStore!
                                                        .claveTienda,
                                                    category:
                                                        _selectedFurniture!
                                                            .fiIdCategoria));
                                          }
                                        });
                                      }
                                    : null, // Si no está habilitado, se desactiva
                                selectedItem: _selectedFurniture,
                              )
                            : DropdownSearch<CategoryResponse>(
                                popupProps: PopupProps.menu(
                                  showSearchBox: false,
                                    menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                ),
                                items: (f, cs) => [],
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'No hay categorías disponibles',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                onChanged: null, // Dropdown deshabilitado
                                enabled: false, // Deshabilitar interacción
                              );
                      } else {
                        return listCategories.isNotEmpty
                            ? DropdownSearch<CategoryResponse>(
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                    menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                ),
                                items: (f, cs) => listCategories,
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'Selecciona una categoría',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                itemAsString: (CategoryResponse store) =>
                                    "${store.fcCategoria}",
                                onChanged: _isFurnitureEnabled
                                    ? (value) {
                                        setState(() {
                                          _selectedFurniture = value;
                                          statsResponse = [];

                                          if (value != null) {
                                            _riBloc?.add(
                                                EventGetEventsSupercito(
                                                    tienda: _selectedStore!
                                                        .claveTienda,
                                                    category:
                                                        _selectedFurniture!
                                                            .fiIdCategoria));
                                          }
                                        });
                                      }
                                    : null, // Si no está habilitado, se desactiva
                                selectedItem: _selectedFurniture,
                              )
                            : DropdownSearch<CategoryResponse>(
                                popupProps: PopupProps.menu(
                                  showSearchBox: false,
                                    menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                ),
                                items: (f, cs) => [],
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'No hay categorías disponibles',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                onChanged: null, // Dropdown deshabilitado
                                enabled: false, // Deshabilitar interacción
                              );
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  BlocBuilder<RIBloc, RIState>(
                    builder: (context, state) {
                      if (state is IsLoadingGetEventsSupercito) {
                        return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()));
                      } else if (state is SuccessGetEventsSupercito) {
                        statsResponse = state.response;

                        if (statsResponse.isEmpty) {
                          return CenteredImageWithText(
                            assetPath:
                                'assets/images/planet.png', // Ruta de la imagen local
                            title: 'Sin información',
                            description:
                                'No hay datos disponibles para mostrar.',
                          );
                        }

                        return ListView.builder(
                          shrinkWrap:
                              true, // Hace que el GridView se ajuste a su contenido

                          physics:
                              NeverScrollableScrollPhysics(), // Deshabilita el scroll del GridView
                          itemCount: statsResponse.length,
                          itemBuilder: (context, index) {
                            final event = statsResponse[index];

                            return CustomBusinessCard(
                                fechaMon: event.fechaMonitoreo,
                                monitoreo: event.monitoreados,
                                faltantes: event.teoricos,
                                porCajas: event.porcCajas,
                                porsinCajas: event.porcSinCajas,
                                cumplimiento: event.cumplimientoNvo,

                                onTap: () {
                                  // SupercitoSegmentStatsDetailRequest request =
                                  //   SupercitoSegmentStatsDetailRequest(
                                  //       idTienda: _selectedStore!.claveTienda,
                                  //       idEvento: _selectedStore!.evento,
                                  //       idBitacora: _selectedStore!.idBitacora!,
                                  //       ambiente: Constants.enviroment);

                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) =>
                                  //         SupercitoStatsDetail(
                                  //             request: request),
                                  //   ),
                                  // );

                                  // Navigator.of(context).push(MaterialPageRoute(
                                  //   builder: (context) => BusinessPage(
                                  //       params: GetIssuesParams(
                                  //           evento: 1,
                                  //           idCategoria: 101.toString(),
                                  //           idTienda: 60,
                                  //           idBitacora: 6342), origin: 1),
                                  // ));


                                               Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => BusinessPage(
                                        params: GetIssuesParams(
                                            evento: event.evento,
                                            idCategoria: event.idCategoria.toString(),
                                            idTienda: event.claveTienda,
                                            
                                            idBitacora: event.idBitacora), origin: 1),
                                  ));
                                  
                                });
                          },
                        );
                      } else if (state is ErrorGetEventsSupercito) {
                        return Center(
                            child: Text('Error: ${state.messageError}'));
                      } else {
                        return statsResponse.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap:
                                    true, // Hace que el GridView se ajuste a su contenido
                                physics:
                                    NeverScrollableScrollPhysics(), // Deshabilita el scroll del GridView
                                itemCount: statsResponse.length,
                                itemBuilder: (context, index) {
                                  final event = statsResponse[index];

                                  return CustomBusinessCard(
                                      fechaMon: event.fechaMonitoreo,
                                      monitoreo: event.monitoreados,
                                      faltantes: event.teoricos,
                                      porCajas: event.porcCajas,
                                      porsinCajas: event.porcSinCajas,
                                      cumplimiento: event.cumplimientoNvo,
                                      onTap: () {
                                        // SupercitoSegmentStatsDetailRequest request =
                                        //   SupercitoSegmentStatsDetailRequest(
                                        //       idTienda: _selectedStore!.claveTienda,
                                        //       idEvento: _selectedStore!.evento,
                                        //       idBitacora: _selectedStore!.idBitacora!,
                                        //       ambiente: Constants.enviroment);

                                        // SupercitoSegmentStatsDetailRequest
                                        //     request =
                                        //     SupercitoSegmentStatsDetailRequest(
                                        //         idTienda: event.claveTienda,
                                        //         idEvento: event.evento,
                                        //         idBitacora: event.idBitacora,
                                        //         ambiente: Constants.enviroment);

                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         SupercitoStatsDetail(
                                        //             request: request),
                                        //   ),
                                        // );
                                      


                                               Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => BusinessPage(
                                        params: GetIssuesParams(
                                            evento: event.evento,
                                            idCategoria: event.idCategoria.toString(),
                                            idTienda: event.claveTienda,
                                            idBitacora: event.idBitacora), origin: 1),
                                  ));
                                            


                                      });
                                },
                              )
                            : CenteredImageWithText(
                                assetPath:
                                    'assets/images/planet.png', // Ruta de la imagen local
                                title: 'Sin información',
                                description:
                                    'No hay datos disponibles para mostrar.',
                              );
                      }
                    },
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
