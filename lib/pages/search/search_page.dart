import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/category_response.dart';
import 'package:ago_app/models/deparments_response.dart';
import 'package:ago_app/models/furniture_response.dart';
import 'package:ago_app/models/furniture_segm_response.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/search_model_helper.dart';
import 'package:ago_app/models/search_params_request.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/models/tienda_l_request.dart';
import 'package:ago_app/models/validate_tramos_request.dart';
import 'package:ago_app/models/view_detail_tramo.dart';
import 'package:ago_app/pages/take_picture/take_picture_page.dart';
import 'package:ago_app/pages/view_furniture/view_furniture_page.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/alert_dialogs.dart';
import 'package:ago_app/widgets/generic_pages.dart';
import 'package:ago_app/widgets/show_general_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  final day;
  final SearchParamsRequest? params;

  const SearchPage({super.key, this.day, this.params});
  static String routeName = "search_page";

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  RIBloc? _riBloc; // Declaración del BLoC

  CategoryResponse? _selectedCategory;
  StoreResponse? _selectedStore;
  FurnitureResponse? _selectedFurniture;

  bool _isFurnitureEnabled = false;
  bool _isStoreEnabled = false; // Habilitado después de seleccionar categoría
  int? tramoMasCercano;
  int? tramoMasCercanoDelete;

  FurnitureSegmentResponse? tramoSelected;
  var numberIncidents;
  bool isReadyToEvaluate = false;
  bool isCheckedValidations = false;

  @override
  void initState() {
    super.initState();

    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    _riBloc?.add(EventGetCategories());
  }

  List<CategoryResponse> listCategories = [];
  List<StoreResponse> listStoreResponse = [];
  List<DeparmentsResponse> listDepartments = [];
  List<FurnitureResponse> listFurnitures = [];
  List<FurnitureSegmentResponse> listSegments = [];

  @override
  void dispose() {
    // _riBloc?.close(); // Cerrar el BLoC al terminar
    listCategories = [];
    listStoreResponse = [];
    listDepartments = [];
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
        blocListenerTramos(context),
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
          elevation: 1,
          backgroundColor:
              Colors.transparent, // Fondo transparente para el degradado
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Constants.appBarStartColor, Constants.appBarEndColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [
                  0.0,
                  0.7,
                ], // Stops para controlar la distribución del degradado
              ),
            ),
          ),
          actions: [
            listSegments.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      _riBloc?.add(
                        EventGetSegments(
                          idRealograma: _selectedFurniture!.idRealograma,
                          idCategoria: _selectedCategory!.fiIdCategoria,
                        ),
                      );
                    },
                  )
                : const SizedBox(),
          ],
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: 10.0,
                left: 10.0,
                right: 10.0,
                bottom: MediaQuery.of(context).padding.bottom + 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<RIBloc, RIState>(
                    builder: (context, state) {
                      if (state is IsLoadingGetCategory) {
                        return DropdownSearch<CategoryResponse>(
                          popupProps: PopupProps.menu(
                            menuProps: const MenuProps(
                              backgroundColor: Colors.white,
                              elevation: 2,
                            ),
                            showSearchBox: false,
                            disabledItemFn: (_) =>
                                true, // Deshabilitar interacción mientras carga
                          ),
                          items: (f, cs) =>
                              [], // No hay elementos mientras carga
                          compareFn: (a, b) =>
                              a.fiIdCategoria ==
                              b.fiIdCategoria, // 👈 Necesario para evitar el error
                          itemAsString: (CategoryResponse c) =>
                              c.fcCategoria, // 👈 cómo mostrar
                          decoratorProps: DropDownDecoratorProps(
                            decoration: const InputDecoration(
                              labelText: 'Cargando categorías...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged: null, // Deshabilitado
                          enabled:
                              false, // El widget completo está deshabilitado
                        );
                      } else if (state is ErrorGetCategory) {
                        return Center(
                          child: Text(
                            state.messageError ??
                                'Error al cargar las categorías',
                          ),
                        );
                      } else if (state is SuccessGetCategory) {
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
                                compareFn: (a, b) =>
                                    a.fiIdCategoria ==
                                    b.fiIdCategoria, // 👈 Necesario

                                itemAsString: (CategoryResponse store) =>
                                    store.fcCategoria,
                                dropdownBuilder: (context, selectedItem) {
                                  return Text(
                                    selectedItem?.fcCategoria ??
                                        'Selecciona un categoría',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;

                                    _isStoreEnabled = value !=
                                        null; // Habilitar tienda si se selecciona categoría
                                    _selectedStore = null; // Resetear tienda

                                    _selectedFurniture =
                                        null; // Resetear muebles
                                    _isFurnitureEnabled =
                                        false; // Deshabilitar muebles

                                    listSegments = []; // Limpiar segmentos

                                    if (value != null) {
                                      _riBloc?.add(
                                        EventGetStores(
                                          categoryId: value.fiIdCategoria,
                                        ),
                                      ); // Cargar tiendas para la categoría seleccionada
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
                                items: (f, cs) =>
                                    [], // No hay elementos mientras carga
                                compareFn: (a, b) =>
                                    a.fiIdCategoria ==
                                    b.fiIdCategoria, // 👈 Necesario

                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'Selecciona una categoría',
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
                                    backgroundColor: Colors.white,
                                    elevation: 2,
                                  ),
                                  showSearchBox: true,
                                ),
                                items: (f, cs) => listCategories,
                                compareFn: (a, b) =>
                                    a.fiIdCategoria ==
                                    b.fiIdCategoria, // 👈 NECESARIO
                                itemAsString: (CategoryResponse store) =>
                                    store.fcCategoria,
                                dropdownBuilder: (context, selectedItem) {
                                  return Text(
                                    selectedItem?.fcCategoria ??
                                        'Selecciona una categoría',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                },
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: const InputDecoration(
                                    labelText: 'Selecciona una categoría',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                    _isStoreEnabled = value !=
                                        null; // Habilitar tienda si se selecciona categoría
                                    _selectedStore = null; // Resetear tienda
                                    _selectedFurniture =
                                        null; // Resetear muebles
                                    _isFurnitureEnabled =
                                        false; // Deshabilitar muebles
                                    listSegments = []; // Limpiar segmentos

                                    if (value != null) {
                                      _riBloc?.add(
                                        EventGetStores(
                                          categoryId: value.fiIdCategoria,
                                        ),
                                      ); // Cargar tiendas para la categoría seleccionada
                                    }
                                  });
                                },
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
                                items: (f, cs) =>
                                    [], // No hay elementos mientras carga
                                compareFn: (a, b) =>
                                    a.fiIdCategoria ==
                                    b.fiIdCategoria, // 👈 Necesario

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
                      if (state is IsLoadingGetStore) {
                        return DropdownSearch<StoreResponse>(
                          popupProps: PopupProps.menu(
                            menuProps: const MenuProps(
                              backgroundColor:
                                  Colors.white, // 👈 Fondo blanco del menú
                              elevation: 2,
                            ),
                            showSearchBox: false,

                            disabledItemFn: (_) =>
                                true, // Deshabilitar interacción mientras carga
                          ),
                          items: (f, cs) =>
                              [], // No hay elementos mientras carga
                          compareFn: (a, b) =>
                              a.claveTienda == b.claveTienda, // 👈 Necesario

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
                      } else if (state is ErrorGetStore) {
                        return Center(
                          child: Text(
                            state.messageError ?? 'Error al cargar las tiendas',
                          ),
                        );
                      } else if (state is SuccessGetStore) {
                        return listStoreResponse.isNotEmpty
                            ? DropdownSearch<StoreResponse>(
                                popupProps: PopupProps.menu(
                                  menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                  showSearchBox: true,
                                ),
                                items: (f, cs) =>
                                    listStoreResponse, // No hay elementos mientras carga
                                compareFn: (a, b) =>
                                    a.claveTienda ==
                                    b.claveTienda, // 👈 Necesario

                                itemAsString: (StoreResponse store) =>
                                    store.tienda!,
                                dropdownBuilder: (context, selectedItem) {
                                  return Text(
                                    selectedItem?.tienda ??
                                        'Selecciona una tienda',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                },
                                onChanged: _isStoreEnabled
                                    ? (value) {
                                        setState(() {
                                          _selectedStore = value;
                                          _isFurnitureEnabled = value !=
                                              null; // Habilitar muebles si se selecciona tienda
                                          _selectedFurniture =
                                              null; // Resetear muebles
                                          listSegments =
                                              []; // Limpiar segmentos

                                          if (value != null) {
                                            _riBloc?.add(
                                              EventGetFurnitures(
                                                storeId: value.claveTienda,
                                                event: value.evento,
                                                categoriaId: _selectedCategory!
                                                    .fiIdCategoria,
                                                bitacora: value.idBitacora!,
                                              ),
                                            ); // Cargar muebles para la tienda y categoría seleccionadas
                                          }
                                        });
                                      }
                                    : null, // Si no está habilitado, se desactiva
                                selectedItem: _selectedStore,
                              )
                            : DropdownSearch<StoreResponse>(
                                popupProps: PopupProps.menu(
                                  menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                  showSearchBox: false,
                                ),
                                items: (f, cs) =>
                                    [], // No hay elementos mientras carga
                                compareFn: (a, b) =>
                                    a.claveTienda ==
                                    b.claveTienda, // 👈 Necesario

                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'No hay tiendas disponibles',
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
                                  menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                  showSearchBox: true,
                                ),
                                items: (f, cs) =>
                                    listStoreResponse, // No hay elementos mientras carga
                                compareFn: (a, b) =>
                                    a.claveTienda ==
                                    b.claveTienda, // 👈 Necesario

                                itemAsString: (StoreResponse store) =>
                                    store.tienda!,
                                dropdownBuilder: (context, selectedItem) {
                                  return Text(
                                    selectedItem?.tienda ??
                                        'Selecciona una tienda',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                },
                                onChanged: _isStoreEnabled
                                    ? (value) {
                                        setState(() {
                                          _selectedStore = value;
                                          _isFurnitureEnabled = value !=
                                              null; // Habilitar muebles si se selecciona tienda
                                          _selectedFurniture =
                                              null; // Resetear muebles
                                          listSegments =
                                              []; // Limpiar segmentos

                                          if (value != null) {
                                            _riBloc?.add(
                                              EventGetFurnitures(
                                                storeId: value.claveTienda,
                                                event: value.evento,
                                                categoriaId: _selectedCategory!
                                                    .fiIdCategoria,
                                                bitacora: value.idBitacora!,
                                              ),
                                            ); // Cargar muebles para la tienda y categoría seleccionadas
                                          }
                                        });
                                      }
                                    : null, // Si no está habilitado, se desactiva
                                selectedItem: _selectedStore,
                              )
                            : DropdownSearch<StoreResponse>(
                                popupProps: PopupProps.menu(
                                  menuProps: const MenuProps(
                                    backgroundColor: Colors
                                        .white, // 👈 Fondo blanco del menú
                                    elevation: 2,
                                  ),
                                  showSearchBox: false,
                                ),
                                items: (f, cs) =>
                                    [], // No hay elementos mientras carga
                                compareFn: (a, b) =>
                                    a.claveTienda ==
                                    b.claveTienda, // 👈 Necesario

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

                  // Dropdown para seleccionar tiendas
                  const SizedBox(height: 16.0),
                  // Combo de Muebles
                  BlocBuilder<RIBloc, RIState>(
                    builder: (context, state) {
                      if (state is IsLoadingGetFurniture) {
                        return const Center(child: Text('Cargando muebles...'));
                      } else if (state is ErrorGetFurniture) {
                        return Center(
                          child: Text(
                            state.messageError ?? 'Error al cargar los muebles',
                          ),
                        );
                      } else if (state is SuccessGetFurniture) {
                        return DropdownButtonFormField<FurnitureResponse>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Selecciona un mueble',
                            border: OutlineInputBorder(),
                          ),
                          dropdownColor: Colors
                              .white, // 👈 fondo blanco del menú desplegable

                          items: listFurnitures.isEmpty
                              ? [
                                  const DropdownMenuItem<FurnitureResponse>(
                                    value: null,
                                    child: Text('No hay muebles disponibles'),
                                  ),
                                ]
                              : listFurnitures.map((
                                  FurnitureResponse furniture,
                                ) {
                                  return DropdownMenuItem<FurnitureResponse>(
                                    value: furniture,
                                    child: Text(furniture.nombreRealograma!),
                                  );
                                }).toList(),
                          onChanged: _isFurnitureEnabled
                              ? (value) {
                                  setState(() {
                                    _selectedFurniture = value;
                                    listSegments = [];

                                    GetIssuesParams params = GetIssuesParams(
                                      evento: _selectedStore!.evento,
                                      idCategoria:
                                          _selectedCategory!.fiIdCategoria,
                                      idTienda: _selectedStore!.claveTienda,
                                      idBitacora: _selectedStore!.idBitacora!,
                                    );

                                    _riBloc?.add(
                                      EventGetSegments(
                                        idRealograma:
                                            _selectedFurniture!.idRealograma,
                                        idCategoria:
                                            _selectedCategory!.fiIdCategoria,
                                      ),
                                    );
                                  });
                                }
                              : null,
                          value: _selectedFurniture,
                          disabledHint: Text('Selecciona una tienda primero'),
                        );
                      } else {
                        return DropdownButtonFormField<FurnitureResponse>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Selecciona un mueble',
                            border: OutlineInputBorder(),
                          ),
                          dropdownColor: Colors
                              .white, // 👈 fondo blanco del menú desplegable

                          items: listFurnitures.isEmpty
                              ? [
                                  const DropdownMenuItem<FurnitureResponse>(
                                    value: null,
                                    child: Text('No hay muebles disponibles'),
                                  ),
                                ]
                              : listFurnitures.map((
                                  FurnitureResponse furniture,
                                ) {
                                  return DropdownMenuItem<FurnitureResponse>(
                                    value: furniture,
                                    child: Text(furniture.nombreRealograma!),
                                  );
                                }).toList(),
                          onChanged: _isFurnitureEnabled
                              ? (value) {
                                  setState(() {
                                    listSegments = [];

                                    _selectedFurniture = value;

                                    GetIssuesParams params = GetIssuesParams(
                                      evento: _selectedStore!.evento,
                                      idCategoria:
                                          _selectedCategory!.fiIdCategoria,
                                      idTienda: _selectedStore!.claveTienda,
                                      idBitacora: _selectedStore!.idBitacora!,
                                    );

                                    // _riBloc?.add(
                                    //     EventStatusIndicadores(params: params));

                                    _riBloc?.add(
                                      EventGetSegments(
                                        idRealograma:
                                            _selectedFurniture!.idRealograma,
                                        idCategoria:
                                            _selectedCategory!.fiIdCategoria,
                                      ),
                                    );
                                  });

                                  print(
                                    "dkdkd ${_selectedStore!.evento}--${_selectedCategory!.fiIdCategoria}-${_selectedStore!.claveTienda}, ${_selectedFurniture!.idRealograma}",
                                  );
                                }
                              : null,
                          value: _selectedFurniture,
                          disabledHint: const Text(
                            'Selecciona una tienda primero',
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16.0),

                  BlocBuilder<RIBloc, RIState>(
                    builder: (context, state) {
                      if (state is IsLoadingGetFurnitureSegment ||
                          state is IsLoadingGenerarIndicadores ||
                          state is IsLoadingIndicadores) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is SuccessGetFurnitureSegment) {
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
                                      .where(
                                        (segment) => segment.estatusTramo == 3,
                                      )
                                      .length;

                                  if (filteredSegments > 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                          "Es necesario capturar todos los tramos para poder agregar un nuevo tramo.",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ), // Texto blanco
                                        ),
                                        backgroundColor:
                                            Colors.amber, // Fondo verde
                                      ),
                                    );

                                    return;
                                  } else {
                                    SearchModelHelper model = SearchModelHelper(
                                      event: _selectedStore!.evento,
                                      idTienda: _selectedStore!.claveTienda,
                                      idRealograma:
                                          _selectedFurniture!.idRealograma,
                                      tramo: encontrarTramoMasGrande(
                                              listSegments) +
                                          1,
                                      categoria:
                                          _selectedCategory!.fiIdCategoria,
                                      idReconocimiento: 0,
                                      idBitacora: _selectedStore!.idBitacora!,
                                    );

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => TakePicturePage(
                                          numberSegments: 1,
                                          searchParams: model,
                                        ),
                                      ),
                                    );

                                    // old
                                    // _showCustomPhotos(context, 1);
                                  }
                                }

                                if (listSegments[index].estatusTramo == 4) {
                                  return;
                                }

                                if (listSegments[index].estatusTramo != 4 &&
                                    listSegments[index].estatusTramo != 0) {
                                  print("Entro 4");
                                  print(listSegments[index].estatusTramo);

                                  if (listSegments[index].estatusTramo == 3) {
                                    if (listSegments[index].tramo !=
                                            tramoMasCercano &&
                                        tramoMasCercano != 0) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content: Text(
                                            "Los tramos se deben capturar de manera consecutiva, el siguiente tramo es: #${tramoMasCercano}.",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ), // Texto blanco
                                          ),
                                          backgroundColor: Color.fromARGB(
                                            255,
                                            227,
                                            227,
                                            227,
                                          ), // Fondo verde
                                        ),
                                      );

                                      return;
                                    }

                                    setState(() {
                                      tramoSelected = listSegments[index];
                                    });
                                    print("Tramo no capturado");

                                    SearchModelHelper model = SearchModelHelper(
                                      event: _selectedStore!.evento,
                                      idTienda: _selectedStore!.claveTienda,
                                      idRealograma:
                                          _selectedFurniture!.idRealograma,
                                      tramo: tramoSelected!.tramo,
                                      categoria:
                                          _selectedCategory!.fiIdCategoria,
                                      idReconocimiento:
                                          tramoSelected!.idReconocimiento,
                                      idBitacora: _selectedStore!.idBitacora!,
                                    );

                                    print(model.toJson());

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => TakePicturePage(
                                          numberSegments: 1,
                                          searchParams: model,
                                        ),
                                      ),
                                    );
                                  } else {
                                    _showBottomSheet(
                                        context, listSegments[index]);

                                    setState(() {
                                      tramoSelected = listSegments[index];
                                    });
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 5.0,
                                    color: _getColorForStatus(
                                      listSegments[index].estatusTramo,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                    image: _getImageProvider(
                                      listSegments[index].imagen,
                                      listSegments[index].estatusTramo,
                                    ),
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
                                        listSegments[index].estatusTramo,
                                      ),
                                      color: _getColorForStatus(
                                        listSegments[index].estatusTramo,
                                      ),
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
                      } else if (state is ErrorGetFurnitureSegment) {
                        return Center(
                          child: Text('Error: ${state.messageError}'),
                        );
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
                                            .where(
                                              (segment) =>
                                                  segment.estatusTramo == 3,
                                            )
                                            .length;

                                        if (filteredSegments > 0) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text(
                                                "Es necesario capturar todos los tramos para poder agregar un nuevo tramo.",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                    255,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                ), // Texto blanco
                                              ),
                                              backgroundColor:
                                                  Colors.amber, // Fondo verde
                                            ),
                                          );

                                          return;
                                        } else {
                                          SearchModelHelper model =
                                              SearchModelHelper(
                                            event: _selectedStore!.evento,
                                            idTienda:
                                                _selectedStore!.claveTienda,
                                            idRealograma: _selectedFurniture!
                                                .idRealograma,
                                            tramo: encontrarTramoMasGrande(
                                                    listSegments) +
                                                1,
                                            categoria: _selectedCategory!
                                                .fiIdCategoria,
                                            idReconocimiento: 0,
                                            idBitacora:
                                                _selectedStore!.idBitacora!,
                                          );

                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TakePicturePage(
                                                numberSegments: 1,
                                                searchParams: model,
                                              ),
                                            ),
                                          );
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
                                          if (listSegments[index].tramo !=
                                                  tramoMasCercano &&
                                              tramoMasCercano != 0) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: Text(
                                                  "Los tramos se deben capturar de manera consecutiva, el siguiente tramo es: #${tramoMasCercano}.",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                      255,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                  ), // Texto blanco
                                                ),
                                                backgroundColor: Color.fromARGB(
                                                  255,
                                                  227,
                                                  227,
                                                  227,
                                                ), // Fondo verde
                                              ),
                                            );

                                            return;
                                          }

                                          setState(() {
                                            tramoSelected = listSegments[index];
                                          });

                                          print("Tramo no capturado");

                                          SearchModelHelper model =
                                              SearchModelHelper(
                                            event: _selectedStore!.evento,
                                            idTienda:
                                                _selectedStore!.claveTienda,
                                            idRealograma: _selectedFurniture!
                                                .idRealograma,
                                            tramo: tramoSelected!.tramo,
                                            categoria: _selectedCategory!
                                                .fiIdCategoria,
                                            idReconocimiento:
                                                tramoSelected!.idReconocimiento,
                                            idBitacora:
                                                _selectedStore!.idBitacora!,
                                          );

                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TakePicturePage(
                                                numberSegments: 1,
                                                searchParams: model,
                                              ),
                                            ),
                                          );
                                        } else {
                                          _showBottomSheet(
                                              context, listSegments[index]);
                                          setState(() {
                                            tramoSelected = listSegments[index];
                                          });
                                        }
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 5.0,
                                          color: _getColorForStatus(
                                            listSegments[index].estatusTramo,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                        image: DecorationImage(
                                          image: _getImageProvider(
                                            listSegments[index].imagen,
                                            listSegments[index].estatusTramo,
                                          ),
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
                                              listSegments[index].estatusTramo,
                                            ),
                                            color: _getColorForStatus(
                                              listSegments[index].estatusTramo,
                                            ),
                                            size: 48.0,
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            listSegments[index].tramo == 0
                                                ? "Agregar tramo"
                                                : "Tramo ${listSegments[index].tramo}",
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                51,
                                                51,
                                                51,
                                              ),
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
        bottomNavigationBar: (listSegments.length > 0 && isReadyToEvaluate)
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 5,
                    bottom: 20,
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isReadyToEvaluate) {
                        _riBloc?.add(
                          EventValidateTramos(
                            request: ValidaTramosRequest(
                              idBitacora: _selectedStore!.idBitacora!,
                              tienda: _selectedStore!.claveTienda,
                              categoria: _selectedCategory!.fiIdCategoria,
                            ),
                          ),
                        );

                        print('idBitacora: ${_selectedStore!.idBitacora}, '
                            'tienda: ${_selectedStore!.claveTienda}, '
                            'categoria: ${_selectedCategory!.fiIdCategoria}');

                        // _riBloc?.add(EventValidateTramos(request: ValidaTramosRequest(idBitacora: 389472, tienda: 789, categoria: '164')));
                      }
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
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  bool hasStatusTramo1or2(List<FurnitureSegmentResponse> listSegments) {
    if (numberIncidents == 1) {
      return true;
    }

    if (numberIncidents == 2) {
      return true;
    }

    return false;
  }

  void mostrarAlerta(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Para que no se cierre al tocar fuera
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.orange,
                ),
                const SizedBox(height: 15),
                Text(
                  "Atención",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Existe más de un mueble para esta categoría.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cerrar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int getStatusTramoText(List<FurnitureSegmentResponse> listSegments) {
    if (numberIncidents >= 1) {
      return 2; // Si existe al menos un segmento con estatus 2, devolver 2
    }

    bool hasStatus1 = listSegments.any((segment) => segment.estatusTramo == 1);
    if (hasStatus1 && numberIncidents == 0) {
      return 1; // Si existe al menos un segmento con estatus 1, devolver 1
    }

    return 0; // Si no hay segmentos con estatus 1 o 2, devolver 0 (o el valor que prefieras)
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
                _buildListTile('Tomar una foto', 1, type, context),
                const Divider(),
                _buildListTile('Tomar 2 fotos', 2, type, context),
                const Divider(),
                // _buildListTile('Tomar 3 fotos', 3, type, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(
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

        int idReconocimiento =
            (type == 1) ? 0 : tramoSelected!.idReconocimiento;

        SearchModelHelper model = SearchModelHelper(
          event: _selectedStore!.evento,
          idTienda: _selectedStore!.claveTienda,
          idRealograma: _selectedFurniture!.idRealograma,
          tramo: tramo,
          categoria: _selectedCategory!.fiIdCategoria,
          idReconocimiento: idReconocimiento,
          idBitacora: _selectedStore!.idBitacora!,
        );

        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TakePicturePage(
              numberSegments: numberSegments,
              searchParams: model,
            ),
          ),
        );
      },
    );
  }

  void _showBottomSheet(
    BuildContext context,
    FurnitureSegmentResponse request,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                request.estatusTramo == 1 || request.estatusTramo == 2
                    ? ListTile(
                        leading: const Icon(
                          Icons.remove_red_eye_sharp,
                          color: Colors.blue,
                        ),
                        title: const Text('Ver'),
                        onTap: () {
                          ViewDetailTramo params = ViewDetailTramo(
                            idReconocimiento: request.idReconocimiento,
                            idRealograma: request.idRealograma,
                            tramo: request.tramo,
                            idCategoria: _selectedCategory!.fiIdCategoria,
                            evento: _selectedStore!.evento,
                            idTienda: _selectedStore!.claveTienda,
                          );

                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewFurniturePage(params: params),
                            ),
                          );
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
                          // List<FurnitureSegmentResponse> filteredSegments =
                          //     listSegments
                          //         .where((segment) => segment.estatusTramo == 1)
                          //         .toList()
                          //       ..sort((a, b) => b.tramo.compareTo(a.tramo));

                          // if (filteredSegments.isNotEmpty) {
                          //   tramoMasCercanoDelete = filteredSegments.first.tramo;
                          // } else {
                          //   tramoMasCercanoDelete = 0;
                          // }

                          // if (request.tramo != tramoMasCercanoDelete &&
                          //     tramoMasCercanoDelete != 0) {
                          //   Navigator.pop(context);

                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text(
                          //         "Los tramos se deden eliminar de manera ascendente, el siguiente tramo es: #${tramoMasCercanoDelete}.",
                          //         style: const TextStyle(
                          //             fontWeight: FontWeight.bold,
                          //             color: Color.fromARGB(
                          //                 255, 0, 0, 0)), // Texto blanco
                          //       ),
                          //       backgroundColor: Colors.amber, // Fondo verde
                          //     ),
                          //   );

                          //   return;
                          // }

                          // print(tramoMasCercanoDelete);

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
                          // old
                          Navigator.pop(context);
                          _showCustomPhotos(context, 2);
                        },
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }

  BlocListener buildLoginBlocListener(BuildContext context) {
    return BlocListener<RIBloc, RIState>(
      listener: (context, state) {
        if (state is IsLoadingGetFurnitureSegment ||
            state is IsLoadingGenerarIndicadores ||
            state is IsLoadingIndicadores ||
            state is IsLoadingCierreTienda) {
          showGeneralLoading(context);
        }

        if (state is ErrorGenerarIndicadores) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.messageError!,
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                ), // Texto blanco
              ),
              backgroundColor: const Color.fromARGB(
                255,
                244,
                36,
                36,
              ), // Fondo verde
            ),
          );
          Navigator.pop(context);
        }

        if (state is SuccessGenerarIndicadores) {
          print(state.response.estatus);
          print(state.response.respuesta);

          if (!state.response.estatus) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  state.response.respuesta,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                  ), // Texto blanco
                ),
                backgroundColor: Colors.amber, // Fondo verde
              ),
            );

            Navigator.pop(context);
            return;
          }

          GetIssuesParams params = GetIssuesParams(
            idCategoria: _selectedCategory!.fiIdCategoria,
            evento: _selectedStore!.evento,
            idTienda: _selectedStore!.claveTienda,
            idBitacora: _selectedStore!.idBitacora!,
          );
          _riBloc?.add(EventCierreTienda(params: params));

          Navigator.pop(context);
        }

        if (state is SuccessCierreTienda) {
          if (state.response.estatus) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "Se ha realizado correctamente el cierre de categorías y tiendas",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ), // Texto blanco
                ),
                backgroundColor: Color.fromARGB(255, 31, 167, 0), // Fondo verde
              ),
            );

            isReadyToEvaluate = false;
            _riBloc?.add(
              EventGetAvanceAuditoria(
                params: TiendaLRequest(
                  idTienda: widget.params!.tienda!,
                  dia: widget.day,
                ),
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  state.response.respuesta,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ), // Texto blanco
                ),
                backgroundColor: Color.fromARGB(255, 167, 0, 0), // Fondo verde
              ),
            );

            _riBloc?.add(
              EventGetAvanceAuditoria(
                params: TiendaLRequest(
                  idTienda: widget.params!.tienda!,
                  dia: widget.day,
                ),
              ),
            );

            Navigator.pop(context);
            return;
          }

          Navigator.pop(context);
        }

        if (state is SuccessGetFurniture) {
          listFurnitures = state.response;

          if (widget.params!.isByMenu) {
            setState(() {
              _selectedFurniture = listFurnitures[0];
            });

            _riBloc?.add(
              EventGetSegments(
                idRealograma: _selectedFurniture!.idRealograma,
                idCategoria: _selectedCategory!.fiIdCategoria,
              ),
            );
          } else {
            if (_selectedFurniture == null || listFurnitures.length == 1) {
              setState(() {
                _selectedFurniture = listFurnitures[0];
              });

              _riBloc?.add(
                EventGetSegments(
                  idRealograma: _selectedFurniture!.idRealograma,
                  idCategoria: _selectedCategory!.fiIdCategoria,
                ),
              );
            }
          }

          
        }

        if (state is SuccessGetFurnitureSegment) {
          setState(() {
            listSegments = state.response;
            listSegments.add(
              FurnitureSegmentResponse(
                idReconocimiento: 0,
                idRealograma: 0,
                tramo: 0,
                estatusTramo: 0,
                incidencias: 0,
                correctas: 0,
                imagen: "",
              ),
            );
            // _isSegments = hasStatusTramo1or2(listSegments);
            // var nextSegment = listSegments.;

            List<FurnitureSegmentResponse> filteredSegments = listSegments
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

            print(
              "TRANQUILIDAD______${listFurnitures.length} _______${isCheckedValidations}",
            );


            if (listFurnitures.length > 1 && !isCheckedValidations) {
              mostrarAlerta(context);
            }

            isCheckedValidations = true;
          });
           
        }

        if (state is SuccessIndicadores) {
          setState(() {
            print("Estatus: ${state.status}");
            numberIncidents = state.status;
            Navigator.pop(context);
          });
        }

        if (state is ErrorGetFurnitureSegment ||
            state is ErrorIndicadores ||
            state is ErrorCierreTienda) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.messageError!,
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                ), // Texto blanco
              ),
              backgroundColor: const Color.fromARGB(
                255,
                244,
                36,
                36,
              ), // Fondo verde
            ),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  BlocListener blocListenerTramos(BuildContext context) {
    return BlocListener<RIBloc, RIState>(
      listener: (context, state) {
        if (state is SuccessValidationsTramos) {
          print('ESTATUS DEL TRAMO ${state.response.toJson()}');

          if (state.response.estatus) {
            showDialog(
              context:
                  context, // ← Este es el context de tu widget, no del diálogo
              barrierDismissible: false,
              builder: (BuildContext context) {
                return SimpleAlertDialog(
                  title: "Atención",
                  description: '${state.response.descripcion}.',
                  onAccept: () {
                    Navigator.pop(context);

                    GetIssuesParams params = GetIssuesParams(
                      idCategoria: _selectedCategory!.fiIdCategoria,
                      evento: _selectedStore!.evento,
                      idTienda: _selectedStore!.claveTienda,
                      idBitacora: _selectedStore!.idBitacora!,
                    );
                    _riBloc?.add(EventGenerarIndicadores(params: params));
                  },
                  onClose: () {
                    Navigator.pop(context);
                  },
                  acceptText: 'Evaluar',
                  closeText: "Seguir capturando",
                );
              },
            );
          } else {
            GetIssuesParams params = GetIssuesParams(
              idCategoria: _selectedCategory!.fiIdCategoria,
              evento: _selectedStore!.evento,
              idTienda: _selectedStore!.claveTienda,
              idBitacora: _selectedStore!.idBitacora!,
            );
            _riBloc?.add(EventGenerarIndicadores(params: params));
          }
        }
      },
    );
  }

  BlocListener blocListenerDelete(BuildContext context) {
    return BlocListener<RIBloc, RIState>(
      listener: (context, state) {
        if (state is IsLoadingDeleteTramo) {
          showGeneralLoading(context);
        }

        if (state is SuccessGetCategory) {
          listCategories = state.response;

          if (widget.params!.isByMenu) {
            bool exist = state.response
                .where(
                  (element) =>
                      element.fiIdCategoria == widget.params!.categoria,
                )
                .isNotEmpty;

            if (exist) {
              _selectedCategory = state.response
                  .where(
                    (element) =>
                        element.fiIdCategoria == widget.params!.categoria,
                  )
                  .first;

              _isStoreEnabled = true;
              _riBloc?.add(
                EventGetStores(categoryId: _selectedCategory!.fiIdCategoria),
              );
            }
          }
        }

        if (state is SuccessGetStore) {
          listStoreResponse = state.response;

          if (widget.params!.isByMenu) {
            bool existStore = state.response
                .where(
                  (element) => element.claveTienda == widget.params!.tienda,
                )
                .isNotEmpty;

            if (existStore) {
              print("Existe la tienda");
              _selectedStore = state.response
                  .where(
                    (element) => element.claveTienda == widget.params!.tienda,
                  )
                  .first;

              _isFurnitureEnabled = true;

              _riBloc?.add(
                EventGetFurnitures(
                  storeId: _selectedStore!.claveTienda,
                  event: _selectedStore!.evento,
                  categoriaId: _selectedCategory!.fiIdCategoria,
                  bitacora: _selectedStore!.idBitacora!,
                ),
              ); // Cargar muebles para la tienda y categoría seleccionadas
            }
          } else {
            if (_selectedStore == null && listStoreResponse.length == 1) {
              setState(() {
                _selectedStore = listStoreResponse[0];

                _isFurnitureEnabled = true;
                _selectedFurniture = null; // Resetear muebles
                listSegments = []; // Limpiar segmentos

                _riBloc?.add(
                  EventGetFurnitures(
                    storeId: _selectedStore!.claveTienda,
                    event: _selectedStore!.evento,
                    categoriaId: _selectedCategory!.fiIdCategoria,
                    bitacora: _selectedStore!.idBitacora!,
                  ),
                ); // Cargar muebles para la tienda y categoría seleccionadas
              });
            }
          }
        }

        if (state is SuccessDeleteTramo) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.response,
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                ), // Texto blanco
              ),
              backgroundColor: const Color.fromARGB(
                255,
                62,
                208,
                13,
              ), // Fondo verde
            ),
          );

          _riBloc?.add(
            EventGetSegments(
              idRealograma: _selectedFurniture!.idRealograma,
              idCategoria: _selectedCategory!.fiIdCategoria,
            ),
          );
        }

        if (state is ErrorDeleteTramo) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.messageError!,
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                ), // Texto blanco
              ),
              backgroundColor: const Color.fromARGB(
                255,
                244,
                36,
                36,
              ), // Fondo verde
            ),
          );
        }
      },
    );
  }

  static int encontrarTramoMasGrande(List<FurnitureSegmentResponse> lista) {
    // Utilizamos map para obtener una lista de tramos y luego reduce para obtener el máximo
    return lista
        .map((segmento) => segmento.tramo)
        .reduce((max, tramo) => tramo > max ? tramo : max);
  }

  void _showCustomDialog(
    BuildContext context,
    FurnitureSegmentResponse request,
  ) {
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
                const Icon(Icons.info_outline, size: 50.0, color: Colors.blue),
                const SizedBox(height: 16.0),
                const Text(
                  'Al realizar esta acción se eliminará toda la información del tramo',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 110,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blue,
                            Color.fromARGB(255, 76, 104, 175),
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
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 228, 160, 148),
                            Color.fromARGB(255, 206, 45, 45),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      width: 110,
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
                          _riBloc?.add(
                            EventDeleteTramo(
                              idReconocimiento: request.idReconocimiento,
                              tramo: request.tramo,
                            ),
                          );
                          Navigator.pop(context); // Cerrar el modal
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.white),
                        ),
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
