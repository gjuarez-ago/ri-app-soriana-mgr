import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/event_details.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/supercito_segm_stats_detail.dart';
import 'package:ago_app/models/supercito_segments_stats_detail_request.dart';
import 'package:ago_app/pages/business/widgets/view_pdfs/view_pdfs_bi.dart';
import 'package:ago_app/pages/labels_with_incidents/labels_with_incidents_page.dart';
import 'package:ago_app/pages/missing_products/missing_products_page.dart';
import 'package:ago_app/pages/misplaced_products/misplaced_products_page.dart';
import 'package:ago_app/pages/total_product/total_product_page.dart';
import 'package:ago_app/utils/centered_svg_with_text.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
//  Colores de la app
// ─────────────────────────────────────────────
const _kBlue = Color(0xff379ae6);
const _kOrange = Color(0xFFFF5724);
const _kBorder = Color(0xFFEBEBEA);
const _kIndigo = Color(0xff4f46e5);

// ─────────────────────────────────────────────
//  Página principal
// ─────────────────────────────────────────────
class BusinessPage extends StatefulWidget {
  final GetIssuesParams? params;
  final int? origin;

  static String routeName = 'analisis_page';
  const BusinessPage({super.key, this.params, this.origin});

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage>
    with TickerProviderStateMixin {
  RIBloc? _riBloc;
  late TabController _tabController;

  List<SupercitoSegmStatsDetail> listProducts = [];
  List<String> permisos = [];
  EventDetail? indicadores;
  late SharedPreferences preferences;

  bool isAdmin = false;
  bool isOriginZero = false;
  bool shouldShowPrices = false;
  bool _prefsLoaded = false;

  // Índice del tab activo, para el bottom bar condicional
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _getPref();

    _riBloc = BlocProvider.of<RIBloc>(context);

    if (widget.params != null) {
      _riBloc?.add(
        EventResumenIndicadores(
          params: GetIssuesParams(
            evento: widget.params!.evento,
            idCategoria: widget.params!.idCategoria,
            idTienda: widget.params!.idTienda,
            idBitacora: widget.params!.idBitacora,
          ),
        ),
      );

      _riBloc?.add(
        EventGetStatsDetails(
          request: SupercitoSegmentStatsDetailRequest(
            ambiente: Constants.enviroment,
            idBitacora: widget.params!.idBitacora,
            idEvento: widget.params!.evento,
            idTienda: widget.params!.idTienda,
          ),
        ),
      );
    }
  }

  Future<void> _getPref() async {
    isOriginZero = widget.origin == 1;
    preferences = await SharedPreferences.getInstance();
    isAdmin = preferences.getBool('admin') ?? false;
    permisos = (preferences.getString('permisos') ?? '').split(',');

    // TODO: Tab de Precios oculto temporalmente. Para reactivarlo,
    // descomentar las 3 líneas siguientes y eliminar `shouldShowPrices = false;`.
    // final precios = permisos.contains('VIEW_M_PRECIOS');
    // final preciosSupercitos = permisos.contains('VIEW_M_PRECIOSUPERCITOS');
    // shouldShowPrices =
    //     (!isOriginZero && precios) || (isOriginZero && preciosSupercitos);
    shouldShowPrices = false;

    final tabCount = _tabCount();
    _tabController = TabController(length: tabCount, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() => _currentTab = _tabController.index);
        }
      });

    _prefsLoaded = true;
    if (mounted) setState(() {});
  }

  int _tabCount() {
    int count = 2; // Faltante + Planograma siempre presentes
    if (isOriginZero) count++;
    if (shouldShowPrices) count++;
    return count;
  }

  // Mapea índice de tab a "tipo"
  _TabType _tabType(int index) {
    if (index == 0) return _TabType.faltante;
    if (index == 1) return _TabType.planograma;
    if (index == 2 && isOriginZero) return _TabType.cajas;
    return _TabType.precios;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocConsumer<RIBloc, RIState>(
      listener: (context, state) {
        if (state is ErrorResumenIndicadores) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.messageError}')),
          );
        }
        if (state is SuccessGetStatsDetails) {
          setState(() => listProducts = state.response);
        }
        if (state is SuccessResumenIndicadores) {
          setState(() => indicadores = state.indicadores);
        }
      },
      builder: (context, state) {
        final data = (state is SuccessResumenIndicadores)
            ? state.indicadores
            : indicadores;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(data),
          body: _buildBody(state, data),
          bottomNavigationBar: data != null ? _buildBottomBar(data) : null,
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(EventDetail? data) {
    final tabs = _buildTabs();

    return AppBar(
      elevation: 0,
      toolbarHeight: 70,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leadingWidth: 60,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
      title: const Text(
        'Panel de Análisis',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              // Chip de información del evento
              Container(
                margin: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        size: 20,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categoría: ${data?.categoria ?? data?.idCategoria ?? '—'}',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Evento: ${widget.params?.evento ?? '—'}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // TabBar Dashboard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: tabs,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: Colors.blue.shade800,
                    unselectedLabelColor: Colors.grey.shade500,
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Tab> _buildTabs() {
    Tab _tab(String label, IconData icon) => Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

    return [
      _tab('Faltante', Icons.inventory_2_outlined),
      _tab('Planogramas', Icons.format_align_center_outlined),
      if (isOriginZero) _tab('Cajas', Icons.inbox_outlined),
      if (shouldShowPrices) _tab('Precios', Icons.price_change_outlined),
    ];
  }

  // ─────────────────────────────────────────────
  //  BODY
  // ─────────────────────────────────────────────
  Widget _buildBody(RIState state, EventDetail? data) {
    if (state is IsLoadingResumenIndicadores && data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (data == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return SafeArea(
      child: TabBarView(
        controller: _tabController,
        children: [
          _FaltanteTab(indicadores: data),
          _PlanogramaTab(indicadores: data),
          if (isOriginZero) _CajasTab(products: listProducts),
          if (shouldShowPrices)
            _PreciosTab(indicadores: data, params: widget.params),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BAR CONDICIONAL
  // ─────────────────────────────────────────────
  Widget _buildBottomBar(EventDetail data) {
    final type = _tabType(_currentTab);

    switch (type) {
      case _TabType.faltante:
        return _BottomBar(
          buttons: [
            _BottomBarButton(
              label: 'Ver productos faltantes',
              icon: Icons.remove_red_eye_outlined,
              isPrimary: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MissingProductsPage(params: widget.params),
                ),
              ),
            ),
          ],
        );

      case _TabType.planograma:
        return _BottomBar(
          buttons: [
            _BottomBarButton(
              label: 'Planograma',
              icon: Icons.grid_view_outlined,
              isPrimary: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewPDFByBI(
                    store: widget.params?.idTienda.toString(),
                    origin: widget.origin,
                    upc: 'N/A',
                    type: 1,
                    category: widget.params?.idCategoria,
                  ),
                ),
              ),
            ),
            if (isAdmin)
              _BottomBarButton(
                label: 'Realograma',
                icon: Icons.view_module_outlined,
                isPrimary: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TotalProductPage(
                      params: widget.params,
                      origin: widget.origin,
                    ),
                  ),
                ),
              ),
            if (widget.origin != 1)
              _BottomBarButton(
                label: 'Mal acomodados',
                icon: Icons.swap_horiz_outlined,
                isPrimary: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MisplacedProductsPage(
                      params: widget.params,
                    ),
                  ),
                ),
              ),
          ],
        );

      case _TabType.cajas:
        return const SizedBox.shrink();

      case _TabType.precios:
        if (data.etiTotales <= 0) return const SizedBox.shrink();
        return _BottomBar(
          buttons: [
            _BottomBarButton(
              label: 'Ver errores de precio',
              icon: Icons.price_change_outlined,
              isPrimary: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LabelsWithIncidentsPage(params: widget.params),
                ),
              ),
            ),
          ],
        );
    }
  }
}

// ─────────────────────────────────────────────
//  Enum para tipo de tab
// ─────────────────────────────────────────────
enum _TabType { faltante, planograma, cajas, precios }

// ─────────────────────────────────────────────
//  BOTTOM BAR
// ─────────────────────────────────────────────
class _BottomBarButton {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;
  const _BottomBarButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });
}

class _BottomBar extends StatelessWidget {
  final List<_BottomBarButton> buttons;
  const _BottomBar({required this.buttons});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _kBorder, width: 0.8)),
        ),
        child: Row(
          children: buttons
              .map(
                (b) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton.icon(
                      onPressed: b.onTap,
                      icon: Icon(b.icon,
                          size: 18,
                          color: b.isPrimary ? Colors.white : Colors.black87),
                      label: Text(
                        b.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: b.isPrimary ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            b.isPrimary ? _kOrange : const Color(0xFFF0F2F5),
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TAB 1 — FALTANTE DE ANAQUEL
// ─────────────────────────────────────────────
class _FaltanteTab extends StatelessWidget {
  final EventDetail indicadores;
  const _FaltanteTab({required this.indicadores});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Monitoreados',
                  value: '${indicadores.monitoreados}',
                  subtitle: '${indicadores.monitoreadosPorc}%',
                  description: 'Total SKU exhibidos',
                  valueColor: _kIndigo,
                  icon: Icons.visibility_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Faltantes',
                  value: '${indicadores.faltanteTotal}',
                  subtitle: '${indicadores.faltanteTotalPorc}%',
                  description: 'SKU por revisar',
                  valueColor: Colors.redAccent,
                  icon: Icons.error_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Estatus detallado',
            child: Column(
              children: [
                _ProgressRow(
                  label: 'Faltante con inventario',
                  count: indicadores.faltanteAnaquel,
                  percent: indicadores.faltanteAnaquelPorc,
                  color: _kIndigo,
                ),
                const Divider(height: 24),
                _ProgressRow(
                  label: 'Agotados',
                  count: indicadores.teoricos,
                  percent: indicadores.teoricosPorc,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TAB 2 — PLANOGRAMA
// ─────────────────────────────────────────────
class _PlanogramaTab extends StatelessWidget {
  final EventDetail indicadores;
  const _PlanogramaTab({required this.indicadores});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _PlanCard(
                  label: 'Cumplen',
                  value: '${indicadores.skusCumplen}%',
                  description: 'Skus que cumplen',
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlanCard(
                  label: 'NO cumplen',
                  value: '${indicadores.skusNoCumplen}%',
                  description: 'Skus que NO cumplen',
                  icon: Icons.cancel_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BigMetricCard(
            title: 'Cumplimiento de planograma',
            value: '${indicadores.cumplimientoNvo}%',
            subtitle: 'Promedio de variables de implementación',
            icon: Icons.verified_user_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PlanCard(
                  label: 'Tramo',
                  value: '${indicadores.fnCalTramo}%',
                  description: 'En tramo correcto',
                  icon: Icons.view_column_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlanCard(
                  label: 'Nivel',
                  value: '${indicadores.fncalNivel}%',
                  description: 'En nivel correcto',
                  icon: Icons.layers_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PlanCard(
                  label: 'Frentes',
                  value: '${indicadores.fnFtes}%',
                  description: 'Frentes logrados',
                  icon: Icons.compare_arrows_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlanCard(
                  label: 'Secuencia',
                  value: '${indicadores.secuencia}%',
                  description: 'Secuencia correcta',
                  icon: Icons.format_align_justify_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Diferencia de tramos',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DiffColumn(
                  label: 'Planograma',
                  value: '${indicadores.totalTramosPlanos}',
                ),
                _DiffColumn(
                  label: 'Realograma',
                  value: '${indicadores.totalTramosReales}',
                ),
                _DiffColumn(
                  label: 'Diferencia',
                  value: '${indicadores.difTramos}',
                  valueColor:
                      indicadores.difTramos < 0 ? Colors.green : Colors.black87,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TAB 3 — CAJAS
// ─────────────────────────────────────────────
class _CajasTab extends StatelessWidget {
  final List<SupercitoSegmStatsDetail> products;
  const _CajasTab({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('Sin datos de cajas'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 60,
              columnSpacing: 32,
              headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
              columns: const [
                DataColumn(
                  label: Text(
                    'Tramo',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '% con caja',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '% sin caja',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Evidencia',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: products.map((p) {
                return DataRow(
                  cells: [
                    DataCell(Text('${p.tramo ?? ' '}',
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('${p.porcCajas ?? 0}%')),
                    DataCell(Text('${p.porcSinCajas ?? 0}%')),
                    DataCell(
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImagePreviewView(
                              imageUrl: p.imagen ??
                                  'https://cdn-icons-png.flaticon.com/512/1257/1257249.png',
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.image_outlined, size: 16),
                        label: const Text('Ver',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          backgroundColor: _kBlue.withOpacity(0.1),
                          foregroundColor: _kBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// Preview page simple local para imágenes (Cajas)
class ImagePreviewView extends StatelessWidget {
  final String imageUrl;
  const ImagePreviewView({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evidencia de Caja')),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TAB 4 — PRECIOS
// ─────────────────────────────────────────────
class _PreciosTab extends StatelessWidget {
  final EventDetail indicadores;
  final GetIssuesParams? params;

  const _PreciosTab({required this.indicadores, required this.params});

  @override
  Widget build(BuildContext context) {
    if (indicadores.etiTotales <= 0) {
      return CenteredSvgWithText(
        svgPath: 'assets/images/no-data.svg',
        text: 'Para este evento no se evaluó etiquetas de precios',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BigMetricCard(
            title: 'Etiquetas requeridas',
            value: '${indicadores.etiTotales}',
            subtitle: 'SKU únicos por nivel',
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Estatus general',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _PrecioCard(
                  title: 'Sí encontradas',
                  value: '${indicadores.etiquetasEncontradas}%',
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrecioCard(
                  title: 'No encontradas',
                  value: '${indicadores.sinEtiPorc}%',
                  icon: Icons.cancel_outlined,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Estatus encontradas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _PrecioCard(
                  title: 'Precio correcto',
                  value: '${indicadores.etiCorrectasPorc}%',
                  icon: Icons.monetization_on_outlined,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrecioCard(
                  title: 'Precio incorrecto',
                  value: '${indicadores.etiIncorrectasPorc}%',
                  icon: Icons.money_off_csred_outlined,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PrecioCard(
                  title: 'Sin promoción',
                  value: '${indicadores.sinPromocionPorc}%',
                  icon: Icons.info_outline_rounded,
                  color: Colors.blueGrey.shade600,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGETS REUTILIZABLES
// ─────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String description;
  final Color valueColor;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.valueColor = _kIndigo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _kBorder.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: valueColor.withOpacity(0.8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: '  ($subtitle)',
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BigMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _BigMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrange, const Color(0xFFFF7A55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.15)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _kBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: _kIndigo.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int count;
  final double percent;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$count ($percent%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              color: color,
              backgroundColor: color.withOpacity(0.12),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String label;
  final String value;
  final String description;
  final IconData icon;

  const _PlanCard({
    required this.label,
    required this.value,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _kBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kIndigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: _kIndigo),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 11, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}

class _DiffColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DiffColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _PrecioCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _PrecioCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _kBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Del total auditado',
            style: TextStyle(
                fontSize: 11,
                color: Colors.black45,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
