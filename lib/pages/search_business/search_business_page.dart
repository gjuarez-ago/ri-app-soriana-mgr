import 'package:ago_app/bloc/ri/bloc.dart';
import 'package:ago_app/models/category_response.dart';
import 'package:ago_app/models/events_response.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/search_params_request.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/pages/business/business_page.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/generic_pages.dart';
import 'package:ago_app/widgets/show_general_loading.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBusinessPage extends StatefulWidget {
  final SearchParamsRequest? params;

  const SearchBusinessPage({super.key, this.params});

  static String routeName = "search_page_bi";

  @override
  State<SearchBusinessPage> createState() => _SearchBusinessPageState();
}

class _SearchBusinessPageState extends State<SearchBusinessPage> {
  RIBloc? _riBloc; // Declaración del BLoC

  CategoryResponse? _selectedCategory;
  StoreResponse? _selectedStore;
  bool _isCategoryEnabled = false;

  List<CategoryResponse> listCategories = [];
  List<StoreResponse> listStoreResponse = [];

  List<EventsResponse> listEvents = [];

  @override
  void initState() {
    setState(() {
      listEvents = [];
    });
    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    _riBloc?.add(EventGetStoresIndicadores());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      listEvents = [];
    });
    super.didChangeDependencies();
    // Limpiar la lista cada vez que cambian las dependencias (navegación)
  }

  @override
  void dispose() {
    // _riBloc?.close(); // Cerrar el BLoC al terminar
    listCategories = [];
    listStoreResponse = [];
    listEvents = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [blocListenerDelete(context)],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Buscar',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          elevation: 1,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Constants.appBarStartColor, Constants.appBarEndColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                            state.messageError ?? 'Error al cargar los tiendas',
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

                                dropdownBuilder: (context, selectedItem) {
                                  return Text(
                                    selectedItem?.tienda ??
                                        'Selecciona una tienda',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                },
                                itemAsString: (StoreResponse store) =>
                                    store.tienda!, // Mostrar nombres en el menú
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStore = value;
                                    _isCategoryEnabled = value != null;
                                    _selectedCategory = null;

                                    listEvents = [];

                                    print(
                                      "Tienda ${_selectedStore!.claveTienda}",
                                    );

                                    if (value != null) {
                                      _riBloc?.add(EventGetCategories());
                                    }
                                  });
                                }, // Si no está habilitado, se desactiva
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
                                compareFn: (a, b) =>
                                    a.claveTienda ==
                                    b.claveTienda, // 👈 Necesario

                                items: (f, cs) =>
                                    listStoreResponse, // No hay elementos mientras carga

                                dropdownBuilder: (context, selectedItem) {
                                  return Text(
                                    selectedItem?.tienda ??
                                        'Selecciona una tienda',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                },
                                itemAsString: (StoreResponse store) =>
                                    store.tienda!, // Mostrar nombres en el menú
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStore = value;
                                    _isCategoryEnabled = value != null;
                                    _selectedCategory = null;

                                    listEvents = [];

                                    if (value != null) {
                                      _riBloc?.add(EventGetCategories());
                                    }
                                  });
                                }, // Si no está habilitado, se desactiva
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

                  const SizedBox(height: 16.0),

                  BlocBuilder<RIBloc, RIState>(
                    builder: (context, state) {
                      if (state is IsLoadingGetCategory) {
                        return DropdownSearch<CategoryResponse>(
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
                              a.fiIdCategoria ==
                              b.fiIdCategoria, // 👈 Necesario

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
                                items: (c, cf) => listCategories,
                                compareFn: (a, b) =>
                                    a.fiIdCategoria ==
                                    b.fiIdCategoria, // 👈 Necesario

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
                                onChanged: _isCategoryEnabled
                                    ? (value) {
                                        setState(() {
                                          _selectedCategory = value;
                                          listEvents = [];
                                          if (value != null) {
                                            print(
                                              "${_selectedCategory} ${_selectedStore!.claveTienda}",
                                            );

                                            GetIssuesParams params =
                                                GetIssuesParams(
                                              evento: _selectedStore!.evento,
                                              idCategoria: _selectedCategory!
                                                  .fiIdCategoria,
                                              idTienda:
                                                  _selectedStore!.claveTienda,
                                              idBitacora: 0,
                                            );

                                            _riBloc?.add(
                                              EventReporteEventosTiendas(
                                                params: params,
                                              ),
                                            );
                                          }
                                        });
                                      }
                                    : null, // Si no está habilitado, se desactiva
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
                                    [], // No hay elementos mientras ca
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
                                items: (f, cs) =>
                                    listCategories, // No hay elementos mientras carga
                                compareFn: (a, b) =>
                                    a.fiIdCategoria ==
                                    b.fiIdCategoria, // 👈 Necesario

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
                                onChanged: _isCategoryEnabled
                                    ? (value) {
                                        setState(() {
                                          _selectedCategory = value;
                                          listEvents = [];
                                          if (value != null) {
                                            print(
                                              "${_selectedCategory} ${_selectedStore!.claveTienda}",
                                            );

                                            GetIssuesParams params =
                                                GetIssuesParams(
                                              evento: _selectedStore!.evento,
                                              idCategoria: _selectedCategory!
                                                  .fiIdCategoria,
                                              idTienda:
                                                  _selectedStore!.claveTienda,
                                              idBitacora: 0,
                                            );

                                            _riBloc?.add(
                                              EventReporteEventosTiendas(
                                                params: params,
                                              ),
                                            );
                                          }
                                        });
                                      }
                                    : null, // Si no está habilitado, se desactiva
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

                  // Combo de Categorías
                  const SizedBox(height: 16),
                  BlocBuilder<RIBloc, RIState>(
                    builder: (context, state) {
                      if (state is IsLoadingReporteEventosTiendas) {
                        // Muestra un indicador de carga mientras se obtienen los datos
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is ErrorReporteEventosTiendas) {
                        // Muestra un mensaje de error si ocurre un problema
                        return Center(
                          child: Text('Error: ${state.messageError}'),
                        );
                      } else if (state is SuccessReporteEventosTiendas) {
                        listEvents = state.events;

                        if (listEvents.isEmpty) {
                          return CenteredImageWithText(
                            assetPath:
                                'assets/images/planet.png', // Ruta de la imagen local
                            title: 'Sin información',
                            description:
                                'No hay datos disponibles para mostrar.',
                          );
                        }

                        // Construye la lista de eventos cuando se obtienen correctamente
                        return ListView.builder(
                          shrinkWrap:
                              true, // Hace que el GridView se ajuste a su contenido

                          physics:
                              NeverScrollableScrollPhysics(), // Deshabilita el scroll del GridView

                          itemCount: listEvents.length,
                          itemBuilder: (context, index) {
                            final event = listEvents[index];

                            return InkWell(
                              onTap: () {
                                print(
                                  "evento: ${event.evento}, idCategoria: ${event.idCategoria},idTienda: ${event.idTienda}, idBitacora: ${event.idBitacora}",
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BusinessPage(
                                      params: GetIssuesParams(
                                        evento: event.evento,
                                        idCategoria: event.idCategoria,
                                        idTienda: event.idTienda,
                                        idBitacora: event.idBitacora,
                                      ),
                                      origin: 0,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Capturado: ${event.fechaMon}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoContainer(
                                            label: 'Monitoreados',
                                            value: '${event.monitoreo}',
                                            color: Colors.blue.shade100,
                                          ),
                                          _buildInfoContainer(
                                            label: 'Faltantes',
                                            value: '${event.teoricos}',
                                            color: Colors.red.shade100,
                                          ),
                                          _buildInfoContainer(
                                            label: '% Cumplimiento PLN',
                                            value: '${event.cumplimientoNvo}',
                                            color: Colors.green.shade100,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing:
                                            4, // Espacio horizontal entre los elementos
                                        runSpacing:
                                            4, // Espacio vertical entre las líneas en caso de que se envuelva
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize
                                                .min, // Ajusta el tamaño del Row al contenido
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                color: Colors.blue.shade100,
                                                size: 10,
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ), // Espacio entre el ícono y el texto
                                              Text(
                                                'Monitoreados',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize
                                                .min, // Ajusta el tamaño del Row al contenido
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                color: Colors.red.shade100,
                                                size: 10,
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ), // Espacio entre el ícono y el texto
                                              Text(
                                                'Faltantes',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize
                                                .min, // Ajusta el tamaño del Row al contenido
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                color: Colors.green.shade100,
                                                size: 10,
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ), // Espacio entre el ícono y el texto
                                              Text(
                                                '% Cumplimiento PLN',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // const SizedBox(height: 10,),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.end,
                                      //   children: [   Text(
                                      //             'Capturado: ${event.fechaMon}',
                                      //             style: TextStyle(
                                      //               fontSize: 12,
                                      //               color: Colors.grey[600],
                                      //             ),
                                      //           ),],
                                      // )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        // Maneja cualquier otro estado (por ejemplo, estado inicial)
                        return listEvents.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap:
                                    true, // Hace que el GridView se ajuste a su contenido
                                physics:
                                    NeverScrollableScrollPhysics(), // Deshabilita el scroll del GridView
                                itemCount: listEvents.length,
                                itemBuilder: (context, index) {
                                  final event = listEvents[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => BusinessPage(
                                            params: GetIssuesParams(
                                              evento: event.evento,
                                              idCategoria: event.idCategoria,
                                              idTienda: event.idTienda,
                                              idBitacora: event.idBitacora,
                                            ),
                                            origin: 0,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Capturado: ${event.fechaMon}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _buildInfoContainer(
                                                  label: 'Monitoreados',
                                                  value: '${event.monitoreo}',
                                                  color: Colors.blue.shade100,
                                                ),
                                                _buildInfoContainer(
                                                  label: 'Faltantes',
                                                  value: '${event.teoricos}',
                                                  color: Colors.red.shade100,
                                                ),
                                                _buildInfoContainer(
                                                  label: '% Cumplimiento PLN',
                                                  value:
                                                      '${event.cumplimientoNvo}',
                                                  color: Colors.green.shade100,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing:
                                                  4, // Espacio horizontal entre los elementos
                                              runSpacing:
                                                  4, // Espacio vertical entre las líneas en caso de que se envuelva
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize
                                                      .min, // Ajusta el tamaño del Row al contenido
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      color:
                                                          Colors.blue.shade100,
                                                      size: 10,
                                                    ),
                                                    const SizedBox(
                                                      width: 4,
                                                    ), // Espacio entre el ícono y el texto
                                                    Text(
                                                      'Monitoreados',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize
                                                      .min, // Ajusta el tamaño del Row al contenido
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      color:
                                                          Colors.red.shade100,
                                                      size: 10,
                                                    ),
                                                    const SizedBox(
                                                      width: 4,
                                                    ), // Espacio entre el ícono y el texto
                                                    Text(
                                                      'Faltantes',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize
                                                      .min, // Ajusta el tamaño del Row al contenido
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      color:
                                                          Colors.green.shade100,
                                                      size: 10,
                                                    ),
                                                    const SizedBox(
                                                      width: 4,
                                                    ), // Espacio entre el ícono y el texto
                                                    Text(
                                                      '% Cumplimiento PLN',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Capturado: ${event.fechaMon}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  BlocListener blocListenerDelete(BuildContext context) {
    return BlocListener<RIBloc, RIState>(
      listener: (context, state) {
        if (state is SuccessGetStore) {
          Navigator.pop(context);

          listStoreResponse = state.response;

          if (!widget.params!.isByMenu) {
            bool existStore = state.response
                .where(
                  (element) => element.claveTienda == widget.params!.tienda,
                )
                .isNotEmpty;

            if (existStore) {
              _selectedStore = state.response
                  .where(
                    (element) => element.claveTienda == widget.params!.tienda,
                  )
                  .first;

              _isCategoryEnabled = true;

              _riBloc?.add(
                EventGetCategories(),
              ); // Cargar muebles para la tienda y categoría seleccionadas
            }
          } else {
            if (_selectedStore == null && listStoreResponse.length == 1) {
              setState(() {
                _selectedStore = listStoreResponse[0];
                _isCategoryEnabled =
                    true; // Habilita categorías si hay una tienda seleccionada
                listCategories = []; // Resetea las categorías

                _isCategoryEnabled = true;

                _riBloc?.add(
                  EventGetCategories(),
                );
              });
            }
          }
        }

        if (state is SuccessGetCategory) {
          listCategories = state.response;

          bool existCategory = state.response
              .where(
                (element) => element.fiIdCategoria == widget.params!.categoria,
              )
              .isNotEmpty;

          if (!widget.params!.isByMenu) {
            if (existCategory) {
              print("Existe la categoria");

              setState(() {
                _selectedCategory = state.response
                    .where(
                      (element) =>
                          element.fiIdCategoria == widget.params!.categoria,
                    )
                    .first;
              });
            }

            GetIssuesParams params = GetIssuesParams(
              evento: _selectedStore!.evento,
              idCategoria: _selectedCategory!.fiIdCategoria,
              idTienda: _selectedStore!.claveTienda,
              idBitacora: 0,
            );

            _riBloc?.add(EventReporteEventosTiendas(params: params));
          }
        }

        if (state is IsLoadingReporteEventosTiendas ||
            state is IsLoadingGetStore) {
          listEvents = [];
          showGeneralLoading(context);
        }

        if (state is SuccessReporteEventosTiendas) {
          setState(() {
            listEvents = state.events;
          });

          Navigator.pop(context);
        }

        if (state is ErrorReporteEventosTiendas) {
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

  Widget _buildInfoContainer({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
