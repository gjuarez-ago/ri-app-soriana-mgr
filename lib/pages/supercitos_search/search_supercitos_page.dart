import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/FurnitureSupercitosResponse.dart';
import 'package:ago_app/models/SearchModelHelpersupercitos.dart';
import 'package:ago_app/models/category_response.dart';
import 'package:ago_app/models/params_supercito.dart';
import 'package:ago_app/models/segmentsSupercitos.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/pages/supercito_stats/supercito_stats_page.dart';
import 'package:ago_app/pages/supercitos_search/widgets/supercito_capture_page.dart';
import 'package:ago_app/pages/supercitos_search/widgets/supercitos_detail_page.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/generic_pages.dart';
import 'package:ago_app/widgets/show_general_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchSupercitosPage extends StatefulWidget {
  const SearchSupercitosPage({super.key});
  static String routeName = "supercitos_page";

  @override
  State<SearchSupercitosPage> createState() => _SearchSupercitosPageState();
}

class _SearchSupercitosPageState extends State<SearchSupercitosPage> {
  RIBloc? _riBloc; // Declaración del BLoC

  CategoryResponse? _selectedCategory;
  StoreResponse? _selectedStore;
  FurnitureSupercitosResponse? _selectedFurniture;

  bool _isFurnitureEnabled = false;
  int? tramoMasCercano;
  int? tramoMasCercanoDelete;
  bool _isStoreEnabled = false; // Habilitado después de seleccionar categoría

  SegmentsSupercitos? tramoSelected;
  var numberIncidents;

  List<CategoryResponse> listCategories = [];

  @override
  void initState() {
    super.initState();
    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    _riBloc?.add(EventGetCategorieSupercito());
  }

  List<StoreResponse> listStoreResponse = [];
  List<FurnitureSupercitosResponse> listFurnitures = [];
  List<SegmentsSupercitos> listSegments = [];

  bool isReadyToEvaluate = false;

  @override
  void dispose() {
    // _riBloc?.close(); // Cerrar el BLoC al terminar
    listStoreResponse = [];
    listFurnitures = [];
    listSegments = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        buildLoginBlocListener(context),
        blocListenerDelete(context),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Búsqueda',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 1,
          backgroundColor:
              Colors.transparent, // Fondo transparente para el degradado
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Constants.appBarStartColor,
                  Constants.appBarEndColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [
                  0.0,
                  0.7
                ], // Stops para controlar la distribución del degradado
              ),
            ),
          ),
          actions: [
            // listSegments.isNotEmpty
            //     ? IconButton(
            //         icon: const Icon(Icons.cloud_upload),
            //         onPressed: () {
            //           _showCustomPhotos(context, 1);
            //         },
            //       )
            //     : const SizedBox(),

            listSegments.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      _riBloc?.add(EventGetSegmentsSupercitos(
                          piIdRealograma: _selectedFurniture!.idRealograma));
                    },
                  )
                : const SizedBox(),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    BlocBuilder<RIBloc, RIState>(
                      builder: (context, state) {
                        if (state is IsLoadingGetCategoriesByUPC) {
                          return DropdownSearch<CategoryResponse>(
                            popupProps: PopupProps.menu(
                              showSearchBox: false,
                                menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
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
                                      menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                    showSearchBox: true,
                                  ),
                                  items: (f, cs) => listCategories,
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: 'Selecciona una categoría',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  itemAsString: (CategoryResponse store) =>
                                      store.fcCategoria,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value;
          
                                      _isStoreEnabled = value !=
                                          null; // Habilitar tienda si se selecciona categoría
                                      _selectedStore = null; // Resetear tienda
          
                                      _isFurnitureEnabled =
                                          false; // Deshabilitar muebles
                                      _selectedFurniture =
                                          null; // Resetear muebles
          
                                      listFurnitures = [];
                                      listSegments = []; // Limpiar segmentos
          
                                      if (value != null) {
                                        // value.fiIdCategoria
                                        _riBloc?.add(EventGetStoresSupercitos(
                                            category: _selectedCategory!
                                                .fiIdCategoria));
                                      }
                                    });
                                  }, // Si no está habilitado, se desactiva
                                  selectedItem: _selectedCategory,
                                )
                              : DropdownSearch<CategoryResponse>(
                                  popupProps: PopupProps.menu(
                                      menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                    showSearchBox: false,
                                  ),
                                  items: (f, cs) => [],
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: 'Selecciona una categoría...',
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
                                      menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                    showSearchBox: true,
                                  ),
                                  items: (f, cs) => listCategories,
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: 'Selecciona un categoría',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  itemAsString: (CategoryResponse store) =>
                                    store.fcCategoria,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value;
          
                                      _isStoreEnabled = value !=
                                          null; // Habilitar tienda si se selecciona categoría
                                      _selectedStore = null; // Resetear tienda
          
                                      _isFurnitureEnabled =
                                          false; // Deshabilitar muebles
                                      _selectedFurniture =
                                          null; // Resetear muebles
          
                                      listFurnitures = [];
                                      listSegments = []; // Limpiar segmentos
          
                                      if (value != null) {
                                        _riBloc?.add(EventGetStoresSupercitos(
                                            category: value
                                                .fiIdCategoria)); // Cargar tiendas para la categoría seleccionada
                                      }
                                    });
                                  }, // Si no está habilitado, se desactiva
                                  selectedItem: _selectedCategory,
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
                    SizedBox(
                      height: 20,
                    ),
                    BlocBuilder<RIBloc, RIState>(
                      builder: (context, state) {
                        if (state is IsLoadingGetStoresSupercitos) {
                          return DropdownSearch<StoreResponse>(
                            popupProps: PopupProps.menu(
                              showSearchBox: false,
                                menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
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
                                  onChanged: _isStoreEnabled
                                      ? (value) {
                                          setState(() {
                                            _selectedStore = value;
                                            _isFurnitureEnabled = value !=
                                                null; // Habilitar tienda si se selecciona tienda
                                            _selectedFurniture =
                                                null; // Resetear muebles
                                            // Deshabilitar muebles
                                            listSegments =
                                                []; // Limpiar segmentos
          
                                            if (value != null) {
                                              _riBloc?.add(
                                                  EventGetPdfPlanogramSupercitos(
                                                      store: value.claveTienda,
                                                      idBitacora: value
                                                          .idBitacora!)); // Cargar tiendas para la tienda seleccionada
                                            }
                                          });
                                        }
                                      : null, // Si no está habilitado, se desactiva
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
                                  onChanged: _isStoreEnabled
                                      ? (value) {
                                          setState(() {
                                            _selectedStore = value;
                                            _isStoreEnabled = value != null;
          
                                            _selectedFurniture =
                                                null; // Resetear muebles
          
                                            _isFurnitureEnabled =
                                                false; // Habilitar tienda si se selecciona tienda
          
                                            // Deshabilitar muebles
                                            listSegments =
                                                []; // Limpiar segmentos
          
                                            if (value != null) {
                                              _riBloc?.add(
                                                  EventGetPdfPlanogramSupercitos(
                                                      store: value.claveTienda,
                                                      idBitacora: value
                                                          .idBitacora!)); // Cargar tiendas para la tienda seleccionada
                                            }
                                          });
                                        }
                                      : null, // Si no está habilitado, se desactiva
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
                                      labelText: 'No hay tiendas disponibles',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  onChanged: null, // Dropdown deshabilitado
                                  enabled: false, // Deshabilitar interacción
                                );
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    const SizedBox(height: 16.0),
                    BlocBuilder<RIBloc, RIState>(
                      builder: (context, state) {
                        if (state is IsLoadingGetSegmentsSupercitos ||
                            state is IsLoadingGenerarIndicadores ||
                            state is IsLoadingIndicadores) {
                          return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()));
                        } else if (state is SuccessGetSegmentsSupercitos) {
                          if (state.response.isEmpty) {
                            return CenteredImageWithText(
                              assetPath:
                                  'assets/images/planet.png', // Ruta de la imagen local
                              title: 'Sin información',
                              description:
                                  'No hay datos disponibles para mostrar.',
                            );
                          }
          
                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap:
                                true, // Hace que el GridView se ajuste a su contenido
                            physics:
                                NeverScrollableScrollPhysics(), // Deshabilita el scroll del GridView
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            children: List.generate(
                              listSegments.length,
                              (index) => InkWell(
                                onTap: () {
                                  if (listSegments[index].estatusTramo == 0) {
                                    var filteredSegments = listSegments
                                        .where((segment) =>
                                            segment.estatusTramo == 3)
                                        .length;
          
                                    if (filteredSegments > 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content: Text(
                                            "Es necesario capturar todos los tramos para poder agregar un nuevo tramo.",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(255, 0, 0,
                                                    0)), // Texto blanco
                                          ),
                                          backgroundColor:
                                              Colors.amber, // Fondo verde
                                        ),
                                      );
          
                                      return;
                                    } else {
                                      _showCustomPhotos(context, 1);
                                    }
                                  }
          
                                  if (listSegments[index].estatusTramo == 4) {
                                    return;
                                  }
          
                                  if (listSegments[index].estatusTramo != 4 &&
                                      listSegments[index].estatusTramo != 0) {
                                    if (listSegments[index].estatusTramo == 3) {
                                      print(
                                          "Tramo mas cercano ${tramoMasCercano} 1");
          
                                      if (listSegments[index].tramo !=
                                              tramoMasCercano &&
                                          tramoMasCercano != 0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            content: Text(
                                              "Los tramos se deben capturar de manera consecutiva, el siguiente tramo es: #${tramoMasCercano}.",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(255, 0, 0,
                                                      0)), // Texto blanco
                                            ),
                                            backgroundColor: Color.fromARGB(255,
                                                227, 227, 227), // Fondo verde
                                          ),
                                        );
                                        return;
                                      }
                                    }
          
                                    _showBottomSheet(
                                        context, listSegments[index]);
          
                                    setState(() {
                                      tramoSelected = listSegments[index];
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 5.0,
                                      color: _getColorForStatus(
                                          listSegments[index].estatusTramo),
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                      image: _getImageProvider(
                                          listSegments[index].imagen,
                                          listSegments[index].estatusTramo),
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.3),
                                        BlendMode.dstATop,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _getIconForStatus(
                                            listSegments[index].estatusTramo),
                                        color: _getColorForStatus(
                                            listSegments[index].estatusTramo),
                                        size: 48.0,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        listSegments[index].tramo == 0
                                            ? "Agregar tramo"
                                            : "Tramo ${listSegments[index].tramo}",
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 51, 51, 51),
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else if (state is ErrorGetSegmentsSupercitos) {
                          return Center(
                              child: Text('Error: ${state.messageError}'));
                        } else {
                          return listSegments.isNotEmpty
                              ? GridView.count(
                                  shrinkWrap:
                                      true, // Hace que el GridView se ajuste a su contenido
                                  physics:
                                      NeverScrollableScrollPhysics(), // Deshabilita el scroll del GridView
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  children: List.generate(
                                    listSegments.length,
                                    (index) => InkWell(
                                      onTap: () {
                                        if (listSegments[index].estatusTramo ==
                                            0) {
                                          var filteredSegments = listSegments
                                              .where((segment) =>
                                                  segment.estatusTramo == 3)
                                              .length;
          
                                          if (filteredSegments > 0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                behavior: SnackBarBehavior.floating,
                                                content: Text(
                                                  "Es necesario capturar todos los tramos para poder agregar un nuevo tramo.",
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255,
                                                          0,
                                                          0,
                                                          0)), // Texto blanco
                                                ),
                                                backgroundColor:
                                                    Colors.amber, // Fondo verde
                                              ),
                                            );
          
                                            return;
                                          } else {
                                            _showCustomPhotos(context, 1);
                                          }
                                        }
          
                                        if (listSegments[index].estatusTramo ==
                                            4) {
                                          return;
                                        }
          
                                        if (listSegments[index].estatusTramo !=
                                                4 &&
                                            listSegments[index].estatusTramo !=
                                                0) {
                                          if (listSegments[index].estatusTramo ==
                                              3) {
                                            print(
                                                "Tramo mas cercano ${tramoMasCercano} 1");
          
                                            if (listSegments[index].tramo !=
                                                    tramoMasCercano &&
                                                tramoMasCercano != 0) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  behavior: SnackBarBehavior.floating,
                                                  content: Text(
                                                    "Los tramos se deben capturar de manera consecutiva, el siguiente tramo es: #${tramoMasCercano}.",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromARGB(
                                                            255,
                                                            0,
                                                            0,
                                                            0)), // Texto blanco
                                                  ),
                                                  backgroundColor: Color.fromARGB(
                                                      255,
                                                      227,
                                                      227,
                                                      227), // Fondo verde
                                                ),
                                              );
                                              return;
                                            }
                                          }
          
                                          _showBottomSheet(
                                              context, listSegments[index]);
                                          setState(() {
                                            tramoSelected = listSegments[index];
                                          });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 5.0,
                                            color: _getColorForStatus(
                                                listSegments[index].estatusTramo),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          image: DecorationImage(
                                            image: _getImageProvider(
                                                listSegments[index].imagen,
                                                listSegments[index].estatusTramo),
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(
                                              Colors.black.withOpacity(0.3),
                                              BlendMode.dstATop,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _getIconForStatus(
                                                  listSegments[index]
                                                      .estatusTramo),
                                              color: _getColorForStatus(
                                                  listSegments[index]
                                                      .estatusTramo),
                                              size: 48.0,
                                            ),
                                            const SizedBox(height: 8.0),
                                            Text(
                                              listSegments[index].tramo == 0
                                                  ? "Agregar tramo"
                                                  : "Tramo ${listSegments[index].tramo}",
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 51, 51, 51),
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: (listSegments.length > 0 && isReadyToEvaluate)
            ? Padding(
                padding: const EdgeInsets.only(
                    left: 8, right: 8, top: 5, bottom: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    
                    _riBloc?.add(EventCierreSupercitos(
                        idRealograma: _selectedFurniture!.idRealograma));
                        
                    print(
                        "${_selectedCategory.toString()}-${_selectedStore!.evento}- ${_selectedStore!.claveTienda}- ${_selectedStore!.idBitacora!}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
                          children: [
                            Text(
                              "Evaluar",
                              style: const TextStyle(
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
      ),
    );
  }

  bool hasStatusTramo1or2(List<SegmentsSupercitos> listSegments) {
    if (numberIncidents == 1) {
      return true;
    }

    if (numberIncidents == 2) {
      return true;
    }

    return false;
  }

  Color _getColorForStatus(int estatusTramo) {
    switch (estatusTramo) {
      case 1:
        return Colors.green; // Verde
      case 2:
        return Colors.amber; // Amarillo
      case 3:
        return Colors.grey[700]!; // Gris oscuro
      case 4:
        return Colors.blue; // Azul
      default:
        return Colors.black; // Puedes definir un color por defecto si
    }
  }

  IconData _getIconForStatus(int estatusTramo) {
    switch (estatusTramo) {
      case 0:
        return Icons.add_box_rounded;
      case 1:
        return Icons.check_circle; // Icono de advertencia
      case 2:
        return Icons.warning_amber; // Icono de tarea completada
      case 3:
        return Icons.add_a_photo; // Icono para añadir una foto
      case 4:
        return Icons.not_interested; // Icono de no interesado
      default:
        return Icons
            .question_answer; // Icono por defecto si el estado no coincide
    }
  }

  ImageProvider _getImageProvider(String? imageUrl, int status) {
    if (status == 0) {
      return AssetImage('assets/images/fondo-add.jpg');
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Usa CachedNetworkImageProvider para manejar la caché
      return CachedNetworkImageProvider(imageUrl);
    } else {
      // Imagen de reserva si la URL es null o vacía
      return AssetImage('assets/images/example1.jpeg');
    }
  }

  void _showCustomPhotos(BuildContext context, int type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
                              backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildSupercitoListTile('Tomar una foto', 1, type, context),
                const Divider(),
                _buildSupercitoListTile('Tomar 2 fotos', 2, type, context),
                const Divider(),
                // _buildSupercitoListTile('Tomar 3 fotos', 3, type, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupercitoListTile(
    String label,
    int numberSegments,
    int type,
    BuildContext context,
  ) {
    return ListTile(
      leading: const Icon(Icons.add_a_photo),
      title: Text(label),
      onTap: () {
        int tramo = (type == 1)
            ? encontrarTramoMasGrande(listSegments) + 1
            : tramoSelected!.tramo;

        SearchModelHelperSupercito model = SearchModelHelperSupercito(
          evento: _selectedStore!.evento,
          categoria: _selectedCategory!.fiIdCategoria,
          idTienda: _selectedStore!.claveTienda,
          idRealograma: _selectedFurniture!.idRealograma,
          tramo: tramo,
          mueble: _selectedFurniture.toString(),
          idBitacora: _selectedStore!.idBitacora!,
        );

        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SupercitoCapturePage(
              numberSegments: numberSegments,
              searchParams: model,
            ),
          ),
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, SegmentsSupercitos request) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              request.estatusTramo == 1 || request.estatusTramo == 2
                  ? ListTile(
                      leading: const Icon(Icons.remove_red_eye_sharp,
                          color: Colors.blue),
                      title: const Text('Ver'),
                      onTap: () {
                        ParamsSupercito params = new ParamsSupercito(
                            idRealograma: request.idRealograma,
                            tramo: request.tramo,
                            estatusTramo: request.estatusTramo,
                            imagen: request.imagen,
                            conCajas: request.conCajas,
                            sinCajas: request.sinCajas,
                            conHuecos: request.conHuecos);
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              SupercitosDetailPage(params: params),
                        ));
                      },
                    )
                  : const SizedBox(),
              request.estatusTramo == 1 || request.estatusTramo == 2
                  ? ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text('Eliminar'),
                      onTap: () {
                        Navigator.pop(context);
                        _showCustomDialog(context, request);
                      },
                    )
                  : const SizedBox(),
              request.estatusTramo == 3
                  ? ListTile(
                      leading: const Icon(Icons.edit_note_sharp),
                      title: const Text('Capturar'),
                      onTap: () {
                        Navigator.pop(context);
                        _showCustomPhotos(context, 2);
                      },
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }

  BlocListener buildLoginBlocListener(BuildContext context) {
    return BlocListener<RIBloc, RIState>(listener: (context, state) {
      if (state is IsLoadingGetSegmentsSupercitos ||
          state is IsLoadingGenerarIndicadores ||
          state is IsLoadingCierreSupercitos) {
        showGeneralLoading(context);
      }

      if (state is SuccessCierreSupercitos) {
        print("RESPUESTA ${state.response.estatus}");
        print("RS: ${state.response.respuesta}");

        if (state.response.estatus) {
          setState(() {
            _selectedFurniture = null;
            _selectedStore = null;
            _selectedCategory = null;

            // _isFurnitureEnabled = false;
            listFurnitures = [];
            isReadyToEvaluate = false;
            listSegments = [];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                "Se ha realizado correctamente el cierre de supercitos",
                style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255)), // Texto blanco
              ),
              backgroundColor: Color.fromARGB(255, 31, 167, 0), // Fondo verde
            ),
          );

          Navigator.pop(context);
          

          // _riBloc?.add(EventGetPdfPlanogramSupercitos(
          //     store: _selectedStore!.claveTienda,
          //     idBitacora: _selectedStore!.idBitacora!));
          
           Navigator.pushReplacementNamed(context, SupercitoStatsPage.routeName);

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.response.respuesta,
                style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0)), // Texto blanco
              ),
              backgroundColor: Color.fromARGB(255, 255, 242, 3), // Fondo verde
            ),
          );

          Navigator.pop(context);
          return;
        }
      }

      if (state is SuccessGetSegmentsSupercitos) {
        setState(() {
          listSegments = state.response;
          listSegments.add(SegmentsSupercitos(
              idRealograma: 0,
              tramo: 0,
              estatusTramo: 0,
              imagen: "",
              conCajas: 0,
              sinCajas: 0,
              conHuecos: 0));
          // _isSegments = hasStatusTramo1or2(listSegments);
          // var nextSegment = listSegments.;

          List<SegmentsSupercitos> filteredSegments = listSegments
              .where((segment) => segment.estatusTramo == 3)
              .toList()
            ..sort((a, b) => a.tramo.compareTo(b.tramo));

          if (filteredSegments.isNotEmpty) {
            tramoMasCercano = filteredSegments.first.tramo;
          } else {
            tramoMasCercano = 0;
          }

          isReadyToEvaluate = listSegments
              .where((segment) => segment.estatusTramo == 1)
              .isNotEmpty;

          print("Listo $isReadyToEvaluate");

          Navigator.pop(context);
        });
      }

      if (state is ErrorGetSegmentsSupercitos ||
          state is ErrorCierreSupercitos) {
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

  BlocListener blocListenerDelete(BuildContext context) {
    return BlocListener<RIBloc, RIState>(listener: (context, state) {
      if (state is IsLoadingDeleteTramoSupercitos) {
        showGeneralLoading(context);
      }

      if (state is SuccessDeleteTramoSupercitos) {
        print(state.response.respuesta);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              state.response.respuesta,
              style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255)), // Texto blanco
            ),
            backgroundColor:
                const Color.fromARGB(255, 62, 208, 13), // Fondo verde
          ),
        );

        _riBloc?.add(EventGetSegmentsSupercitos(
            piIdRealograma: _selectedFurniture!.idRealograma));
      }

      if (state is ErrorDeleteTramoSupercitos) {
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

      if (state is SuccessGetFurnitureSupercitos) {
        setState(() {
          _selectedFurniture = state.response[0];
          _riBloc?.add(EventGetSegmentsSupercitos(
              piIdRealograma: _selectedFurniture!.idRealograma));
        });
      }
    });
  }

  static int encontrarTramoMasGrande(List<SegmentsSupercitos> lista) {
    // Utilizamos map para obtener una lista de tramos y luego reduce para obtener el máximo
    return lista
        .map((segmento) => segmento.tramo)
        .reduce((max, tramo) => tramo > max ? tramo : max);
  }

  void _showCustomDialog(BuildContext context, SegmentsSupercitos request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
                              backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            height: 200.0,
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
                const Text(
                  'Al realizar esta acción se eliminará toda la información del tramo',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
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
                            Colors.blue,
                            Color.fromARGB(255, 76, 104, 175)
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
                          Navigator.pop(context); // Cerrar el modal
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 228, 160, 148),
                            Color.fromARGB(255, 206, 45, 45)
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
                          _riBloc?.add(EventDeleteTramoSupercitos(
                              idRealograma: request.idRealograma,
                              tramo: request.tramo));
                          Navigator.pop(context); // Cerrar el modal
                        },
                        child: const Text('Eliminar'),
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
}
