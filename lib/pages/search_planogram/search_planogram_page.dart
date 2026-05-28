import 'package:ago_app/models/planogram.dart';
import 'package:ago_app/models/category_response.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/pages/bar_code/bar_code_page.dart';
import 'package:ago_app/pages/business/widgets/view_pdfs/view_pdfs_bi.dart';
import 'package:ago_app/pages/pdf_view/pdf_view.dart';
import 'package:ago_app/pages/pdf_view/pdf_view_url.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/widgets/generic_pages.dart';
import 'package:ago_app/widgets/show_general_loading.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bloc.dart';

class SearchPlanogramPage extends StatefulWidget {
  static String routeName = "search_planogram_page";

  final int? type;

  const SearchPlanogramPage({super.key, this.type});

  @override
  State<SearchPlanogramPage> createState() => _SearchPlanogramPageState();
}

class _SearchPlanogramPageState extends State<SearchPlanogramPage> {
  RIBloc? _riBloc; // Declaración del BLoC

  List<CategoryResponse> listCategories = [];
  List<StoreResponse> listStoreResponse = [];
  List<Planograma> listPlanograms = [];

  CategoryResponse? _selectedCategory;
  StoreResponse? _selectedStore;
  String? _selectPdfPlanogram;
  bool _isCategoryEnabled = false;
  bool _isPdfEnabled = false;
  bool _isLoading = false;
  String upcAP = "";

  @override
  void initState() {
    super.initState();
    _riBloc = BlocProvider.of<RIBloc>(context); // Obtener instancia del BLoC
    _riBloc?.add(EventGetStoresIndicadores());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [listenerGetCategoriesByUPC(context)],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Búsqueda por ${widget.type == 1 ? 'tienda' : 'producto'}',
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
            child: GestureDetector(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    BlocBuilder<RIBloc, RIState>(
                      builder: (context, state) {
                        if (state is IsLoadingGetStore) {
                          return DropdownSearch<StoreResponse>(
                            popupProps: PopupProps.menu(
                              showSearchBox: false,
                              menuProps: const MenuProps(
                                backgroundColor:
                                    Colors.white, // 👈 Fondo blanco del menú
                                elevation: 2,
                              ),
                              disabledItemFn: (_) =>
                                  true, // Deshabilitar interacción mientras carga
                            ),
                            items: (f, cs) =>
                                [], // No hay elementos mientras carga
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: 'Cargando tiendas...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            compareFn: (StoreResponse? a, StoreResponse? b) =>
                                a?.claveTienda == b?.claveTienda,
                            onChanged: null, // Deshabilitado
                            enabled:
                                false, // El widget completo está deshabilitado
                          );
                        } else if (state is ErrorGetStore) {
                          return Center(
                            child: Text(state.messageError ??
                                'Error al cargar los tiendas'),
                          );
                        } else if (state is SuccessGetStore) {
                          // Solo asignar la tienda por defecto si no hay una seleccionada

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
                                  itemAsString: (StoreResponse store) => store
                                      .tienda!, // Mostrar nombres en el menú
                                  compareFn:
                                      (StoreResponse? a, StoreResponse? b) =>
                                          a?.claveTienda == b?.claveTienda,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStore = value;
                                      _selectedCategory = null;
                                      _isPdfEnabled = false;
                                      _selectPdfPlanogram = null;
                                      listPlanograms = [];
                                      listCategories = [];

                                      if (widget.type == 1 && value != null) {
                                        _riBloc?.add(EventGetCategories());
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
                                      labelText:
                                          'No hay tiendas disponibles...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  compareFn:
                                      (StoreResponse? a, StoreResponse? b) =>
                                          a?.claveTienda == b?.claveTienda,
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
                                  itemAsString: (StoreResponse store) => store
                                      .tienda!, // Mostrar nombres en el menú
                                  compareFn:
                                      (StoreResponse? a, StoreResponse? b) =>
                                          a?.claveTienda == b?.claveTienda,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStore = value;
                                      _selectedCategory = null;
                                      _isPdfEnabled = false;
                                      _selectPdfPlanogram = null;
                                      listPlanograms = [];
                                      listCategories = [];

                                      if (widget.type == 1 && value != null) {
                                        _riBloc?.add(EventGetCategories());
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
                                      labelText:
                                          'No hay tiendas disponibles...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  compareFn:
                                      (StoreResponse? a, StoreResponse? b) =>
                                          a?.claveTienda == b?.claveTienda,
                                  onChanged: null, // Dropdown deshabilitado
                                  enabled: false, // Deshabilitar interacción
                                );
                        }
                      },
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    // Combo de Categorías
                    if (widget.type == 1)
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
                              decoratorProps: DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  labelText: 'Cargando categorías...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              compareFn:
                                  (CategoryResponse? a, CategoryResponse? b) =>
                                      a?.fiIdCategoria == b?.fiIdCategoria,
                              onChanged: null, // Deshabilitado
                              enabled:
                                  false, // El widget completo está deshabilitado
                            );
                          } else if (state is ErrorGetCategory) {
                            return Center(
                              child: Text(state.messageError ??
                                  'Error al cargar las categorías'),
                            );
                          } else if (state is SuccessGetCategory) {

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
                                        store.fcCategoria,
                                    compareFn: (CategoryResponse? a,
                                            CategoryResponse? b) =>
                                        a?.fiIdCategoria == b?.fiIdCategoria,
                                    onChanged: _isCategoryEnabled
                                        ? (value) {
                                            setState(() {
                                              _selectedCategory = value;
                                              _selectPdfPlanogram = null;
                                              _isPdfEnabled = value != null;
                                              listPlanograms = [];

                                              // listEvents = [];
                                              if (value != null) {
                                                print(
                                                    "${_selectedCategory} ${_selectedStore!}");

                                                _riBloc?.add(
                                                    EventGetPdfPlanogram(
                                                        store: _selectedStore!
                                                            .claveTienda
                                                            .toString(),
                                                        category:
                                                            _selectedCategory!
                                                                .fiIdCategoria,
                                                        esSupercito: false));

                                                // _riBloc?.add(EventReporteEventosTiendas(
                                                //     params: params));
                                              }
                                            });
                                          }
                                        : null, // Si no está habilitado, se desactiva
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
                                        labelText:
                                            'No hay categorías disponibles',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    compareFn: (CategoryResponse? a,
                                            CategoryResponse? b) =>
                                        a?.fiIdCategoria == b?.fiIdCategoria,
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
                                        store.fcCategoria,
                                    compareFn: (CategoryResponse? a,
                                            CategoryResponse? b) =>
                                        a?.fiIdCategoria == b?.fiIdCategoria,
                                    onChanged: _isCategoryEnabled
                                        ? (value) {
                                            setState(() {
                                              _selectedCategory = value;
                                              _selectPdfPlanogram = null;
                                              _isPdfEnabled = value != null;
                                              listPlanograms = [];

                                              // listEvents = [];
                                              if (value != null) {
                                                print(
                                                    "${_selectedCategory} ${_selectedStore!}");

                                                _riBloc?.add(
                                                    EventGetPdfPlanogram(
                                                        store: _selectedStore!
                                                            .claveTienda
                                                            .toString(),
                                                        category:
                                                            _selectedCategory!
                                                                .fiIdCategoria,
                                                        esSupercito: false));

                                                // _riBloc?.add(EventReporteEventosTiendas(
                                                //     params: params));
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
                                    items: (f, cs) => [],
                                    decoratorProps: DropDownDecoratorProps(
                                      decoration: InputDecoration(
                                        labelText:
                                            'No hay categorías disponibles',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    compareFn: (CategoryResponse? a,
                                            CategoryResponse? b) =>
                                        a?.fiIdCategoria == b?.fiIdCategoria,
                                    onChanged: null, // Dropdown deshabilitado
                                    enabled: false, // Deshabilitar interacción
                                  );
                          }
                        },
                      ),

                    SizedBox(
                      height: 16,
                    ),
                    // Combo pdfs
                    if (widget.type == 1)
                      BlocBuilder<RIBloc, RIState>(
                        builder: (context, state) {
                          if (state is IsLoadingGetPdfPlanogram) {
                            return DropdownButtonFormField<CategoryResponse>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Cargando pdf´s...',
                                border: OutlineInputBorder(),
                              ),
                              dropdownColor: Colors
                                  .white, // 👈 fondo blanco del menú desplegable

                              items: [
                                const DropdownMenuItem<CategoryResponse>(
                                  value: null,
                                  child: Text('Cargando pdf´s...'),
                                ),
                              ],
                              onChanged:
                                  null, // Deshabilita el Dropdown mientras se cargan las tiendas
                            );
                          } else if (state is ErrorGetPdfPlanogram) {
                            return Center(
                                child: Text(state.messageError ??
                                    'Error al cargar las pdf´s'));
                          } else if (state is SuccessGetPdfPlanogram) {
                            listPlanograms = state.response;
                            return DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Selecciona algún pdf',
                                border: OutlineInputBorder(),
                              ),
                              dropdownColor: Colors
                                  .white, // 👈 fondo blanco del menú desplegable

                              items: listPlanograms.isEmpty
                                  ? [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text(
                                            'No hay pdf´s disponibles para esta categoría'),
                                      )
                                    ]
                                  : listPlanograms.map((Planograma planograma) {
                                      return DropdownMenuItem<String>(
                                        value: planograma.urlPdf,
                                        child:
                                            Text(planograma.nombrePlanograma),
                                      );
                                    }).toList(),
                              onChanged: _isPdfEnabled
                                  ? (value) {
                                      setState(() {
                                        _selectPdfPlanogram = value;
                                        // listEvents = [];
                                        if (value != null) {
                                          print("${_selectPdfPlanogram}");

                                          // _riBloc?.add(EventReporteEventosTiendas(
                                          //     params: params));

                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PdfViewByURL(
                                                          url:
                                                              _selectPdfPlanogram)));
                                        }
                                      });
                                    }
                                  : null,
                              value: _selectPdfPlanogram,
                              disabledHint:
                                  Text('Selecciona una categoría primero'),
                            );
                          } else {
                            return DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Selecciona un PDF',
                                border: OutlineInputBorder(),
                              ),
                              dropdownColor: Colors
                                  .white, // 👈 fondo blanco del menú desplegable

                              items: listPlanograms.isEmpty
                                  ? [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text(
                                            'No hay pdf´s disponibles para esta categoría'),
                                      )
                                    ]
                                  : listPlanograms.map((Planograma planograma) {
                                      return DropdownMenuItem<String>(
                                        value: planograma.urlPdf,
                                        child:
                                            Text(planograma.nombrePlanograma),
                                      );
                                    }).toList(),
                              onChanged: _isPdfEnabled
                                  ? (value) {
                                      setState(() {
                                        _selectPdfPlanogram = value;
                                        // listEvents = [];
                                        if (value != null) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PdfViewByURL(
                                                          url:
                                                              _selectPdfPlanogram)));
                                        }
                                      });
                                    }
                                  : null,
                              value: _selectPdfPlanogram,
                              disabledHint: Text('Selecciona un pdf primero'),
                            );
                          }
                        },
                      ),
                    SizedBox(
                      height: 50,
                    ),
                    CenteredImageWithTextAndButton(
                      assetPath:
                          'assets/images/search.png', // Ruta de la imagen local
                      title: 'Empecemos la búsqueda',
                      description: 'Empecemos con la búsqueda dando click.',
                      buttonTitle: 'Buscar planograma',
                      onPressed: () async {
                        if (widget.type == 1 && _selectPdfPlanogram != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                PdfViewByURL(url: _selectPdfPlanogram),
                          ));
                        } else {
                          await _navigateToCamera();
                        }
                      },
                      showButton: (_selectPdfPlanogram != null ||
                          widget.type ==
                              2), // Condicion para la busqueda de planogramas
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BlocListener listenerGetCategoriesByUPC(BuildContext context) {
    return BlocListener<RIBloc, RIState>(listener: (context, state) {
      if (state is IsLoadingGetCategoriesByUPC) {
        showGeneralLoading(context);
      }

      if (state is SuccessGetCategoriesByUPC) {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ViewPDFByBI(
              store: _selectedStore!.claveTienda.toString(),
              upc: upcAP,
              type: 0,
              category: state.response.fiIdCategoria,
              origin: 0,
            ),
          ),
        );

        // if (state.response.fcCategoria.isEmpty) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(
        //         "Exitoso",
        //         style: const TextStyle(
        //             color: Color.fromARGB(255, 255, 255, 255)), // Texto blanco
        //       ),
        //       backgroundColor:
        //           const Color.fromARGB(255, 62, 208, 13), // Fondo verde
        //     ),
        //   );

        // } else {
        //   _showCustomDialog(context, state.response);
        // }
      }

      if(state is SuccessGetCategory) {
                            listCategories = state.response;

      }

      if (state is SuccessGetStore) {
        listStoreResponse = state.response;

        if (_selectedStore == null && listStoreResponse.isNotEmpty) {
          setState(() {
            _selectedStore = listStoreResponse[0];
            _isCategoryEnabled =
                true; // Habilita categorías si hay una tienda seleccionada
            listCategories = []; // Resetea las categorías

            if (widget.type == 1) {
              _riBloc?.add(EventGetCategories());
            }
          });
        }
      }

      if (state is ErrorGetCategoriesByUPC) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "No hemos encontrado una categoría relacionada a este UPC y tienda",
              style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255)), // Texto blanco
            ),
            backgroundColor:
                const Color.fromARGB(255, 244, 36, 36), // Fondo verde
          ),
        );
      }
    });
  }

  Future<void> _navigateToCamera() async {
    _isLoading = true;
    final String? image = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarCodePage(
          onUpcTaken: (upc) {
            setState(() {
              _isLoading = false;
              Navigator.pop(context);
              this.upcAP = upc;
              print("Incidencia:  $upc");
              _riBloc?.add(EventGetCategoryByUPC(
                  store: _selectedStore!.claveTienda, upc: upc));
            });
          },
        ),
      ),
    );
  }

  String cortarTexto(String texto, int maxLength) {
    if (texto.length > maxLength) {
      return texto.substring(0, maxLength) +
          ".."; // Cortamos el texto y agregamos los puntos suspensivos
    } else {
      return texto; // Si el texto es menor o igual a maxLength, lo devolvemos tal cual
    }
  }

  void _showCustomDialog(BuildContext context, CategoryResponse request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            height: 235.0,
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
                Column(
                  children: [
                    Text(
                      '¿Deseas visualizar el planograma de ${request.fcCategoria}?',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
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
                            Color.fromARGB(255, 243, 65, 33),
                            Color.fromARGB(255, 206, 45, 45)
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
                          setState(() {
                            Navigator.pop(context); // Cerrar el modal
                          });
                        },
                        child: const Text('Cerrar'),
                      ),
                    ),
                    Container(
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
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PdfView(
                                store: _selectedStore!.claveTienda,
                                category: request.fiIdCategoria),
                          ));
                        },
                        child: const Text(
                          'Ok',
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
