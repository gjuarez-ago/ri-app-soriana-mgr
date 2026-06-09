import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/producto_mal_acomodado_secuencia.dart';
import 'package:ago_app/models/producto_sin_hueco.dart';
import 'package:ago_app/pages/misplaced_products/buttons_cards.dart';
import 'package:ago_app/pages/misplaced_products/product_frente_card.dart';
import 'package:ago_app/pages/misplaced_products/product_location_card.dart';
import 'package:ago_app/pages/misplaced_products/product_secuencia_card.dart';
import 'package:ago_app/pages/misplaced_products/product_sinhueco_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/misplaced_products_response.dart';
import '../../utils/constants.dart';
import '../../widgets/show_general_loading.dart';

class MisplacedProductsPage extends StatefulWidget {
  final GetIssuesParams? params;
  final bool? esSupercito;
  static String routeName = "misplaced_products_page";
  const MisplacedProductsPage({super.key, this.params, this.esSupercito});

  @override
  State<MisplacedProductsPage> createState() => _MisplacedProductsState();
}

class _MisplacedProductsState extends State<MisplacedProductsPage> {
  RIBloc? _riBloc;
  bool isAdmin = false;
  List<String> permisos = [];
  int selectedIndex = 0;

  MisplacedProductsResponse? _misplacedData;
  List<ProductoMalAcomodadoSecuencia>? _secuenciaData;
  List<ProductoSinHueco>? _sinHuecoData;

  bool _isLoadingMisplaced = false;
  bool _isLoadingSecuencia = false;
  bool _isLoadingSinHueco = false;

  @override
  void initState() {
    super.initState();
    getPref();
    _riBloc = BlocProvider.of<RIBloc>(context);
    _fetchMisplaced();
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = preferences.getBool('admin') ?? false;
      String? permisosString = preferences.getString('permisos');
      if (permisosString != null && permisosString.isNotEmpty) {
        permisos = permisosString.split(',');
      }
    });

    if (permisos.contains("VIEW_FN_SECUENCIA") &&
        permisos.contains("VIEW_FN_HUECOS")) {
      _fetchSecuencia();
      _fetchSinHuecos();
    }
  }

  void _fetchMisplaced() {
    setState(() => _isLoadingMisplaced = true);
    _riBloc?.add(EventGetMisplacedProducts(
      idBitacora: widget.params!.idBitacora,
      idTienda: widget.params!.idTienda,
      idEvento: widget.params!.evento,
      categoria: widget.params!.idCategoria,
    ));
  }

  void _fetchSecuencia() {
    if (_secuenciaData != null) return;
    setState(() => _isLoadingSecuencia = true);
    _riBloc?.add(EventGetProductosMalAcomodadosSecuencia(
        idBitacora: widget.params!.idBitacora));
  }

  void _fetchSinHuecos() {
    if (_sinHuecoData != null) return;
    setState(() => _isLoadingSinHueco = true);
    _riBloc?.add(
        EventGetProductosSinHuecos(idBitacora: widget.params!.idBitacora));
  }

  void _onTabSelected(int index) {
    setState(() => selectedIndex = index);
    if (index == 3) _fetchSecuencia();
    if (index == 4) _fetchSinHuecos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87, size: 24),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          children: [
            Text(
              'AUDITORÍA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xff4f46e5),
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Productos mal acomodados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<RIBloc, RIState>(
        listener: (context, state) {
          // Listen to base API
          if (state is SuccessGetMisplacedProducts) {
            setState(() {
              _isLoadingMisplaced = false;
              _misplacedData = state.response;
            });
          }
          if (state is ErrorGetMisplacedProducts) {
            setState(() => _isLoadingMisplaced = false);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.messageError!)));
          }

          // Listen to Secuencia API
          if (state is SuccessProductosMalAcomodadosSecuencia) {
            setState(() {
              _isLoadingSecuencia = false;
              _secuenciaData = state.response;
            });
          }
          if (state is ErrorProductosMalAcomodadosSecuencia) {
            setState(() => _isLoadingSecuencia = false);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.messageError!)));
          }

          // Listen to Sin Huecos API
          if (state is SuccessProductosSinHuecos) {
            setState(() {
              _isLoadingSinHueco = false;
              _sinHuecoData = state.response;
            });
          }
          if (state is ErrorProductosSinHuecos) {
            setState(() => _isLoadingSinHueco = false);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.messageError!)));
          }
        },
        builder: (context, state) {
          final totalTramo = _misplacedData?.totalFueraDelTramo ?? 0;
          final totalNivel = _misplacedData?.totalFueraDeNivel ?? 0;
          final totalFrentes = _misplacedData?.totalFrentes ?? 0;
          final totalSecuencia = _secuenciaData?.length ?? 0;
          final totalSinHueco = _sinHuecoData?.length ?? 0;

          List<dynamic> listToShow = [];
          bool isLoadingCurrent = false;

          switch (selectedIndex) {
            case 0:
              listToShow = _misplacedData?.lsFueraDelTramo ?? [];
              isLoadingCurrent = _isLoadingMisplaced;
              break;
            case 1:
              listToShow = _misplacedData?.lsFueraDelNivel ?? [];
              isLoadingCurrent = _isLoadingMisplaced;
              break;
            case 2:
              listToShow = _misplacedData?.lsFrentes ?? [];
              isLoadingCurrent = _isLoadingMisplaced;
              break;
            case 3:
              listToShow = _secuenciaData ?? [];
              isLoadingCurrent = _isLoadingSecuencia;
              break;
            case 4:
              listToShow = _sinHuecoData ?? [];
              isLoadingCurrent = _isLoadingSinHueco;
              break;
          }
          bool hasAdvancedPerms = permisos.contains("VIEW_FN_SECUENCIA") &&
              permisos.contains("VIEW_FN_HUECOS");
          bool showSecuencia = hasAdvancedPerms;
          bool showSinHuecos = hasAdvancedPerms;

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ButtonsCards(
                  totalTramo: totalTramo,
                  totalNivel: totalNivel,
                  totalFrentes: totalFrentes,
                  totalSecuencia: totalSecuencia,
                  totalSinHueco: totalSinHueco,
                  selectedIndex: selectedIndex,
                  showSecuencia: showSecuencia,
                  showSinHuecos: showSinHuecos,
                  onSelected: _onTabSelected,
                ),
                Expanded(
                  child: isLoadingCurrent
                      ? const Center(child: CircularProgressIndicator())
                      : listToShow.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined,
                                      size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No hay datos disponibles',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No se encontraron productos en esta categoría',
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : AnimationLimiter(
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                physics: const BouncingScrollPhysics(),
                                itemCount: listToShow.length,
                                itemBuilder: (context, index) {
                                  final prod = listToShow[index];
                                  Widget cardObj;

                                  if (prod is MisplacedProduct) {
                                    cardObj =
                                        ProductLocationCard(product: prod);
                                  } else if (prod is MisplacedProductFrente) {
                                    cardObj = ProductFrenteCard(product: prod);
                                  } else if (prod
                                      is ProductoMalAcomodadoSecuencia) {
                                    cardObj =
                                        ProductSecuenciaCard(product: prod);
                                  } else if (prod is ProductoSinHueco) {
                                    cardObj =
                                        ProductSinHuecoCard(product: prod);
                                  } else {
                                    cardObj = const SizedBox.shrink();
                                  }

                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: cardObj,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
