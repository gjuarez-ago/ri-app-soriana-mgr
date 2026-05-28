import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/models/search_params_request.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/models/tienda_l_request.dart';
import 'package:ago_app/models/tienda_l_response.dart';
import 'package:ago_app/models/type_categorie.dart';
import 'package:ago_app/pages/login/login_page.dart';
import 'package:ago_app/pages/search/search_page.dart';
import 'package:ago_app/pages/search_business/search_business_page.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/utils/dialogs.dart';
import 'package:ago_app/widgets/auditoria_card.dart';
import 'package:ago_app/widgets/generic_pages.dart';
import 'package:ago_app/widgets/navbar_generic.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = "home_page";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  RIBloc? _riBloc;
  bool isSupercito = false;
  bool isAdmin = false;
  List<String> permisos = [];
  List<StoreResponse> listStoreResponse = [];
  List<TiendaLResponse> listadoTiendas = [];

  // Tab controller para Auditados / Pendientes
  late TabController _tabController;
  int _selectedTabIndex = 0; // 0 = Auditados, 1 = Pendientes

  StoreResponse? _selectedStore;
  TypeCategory? resultadoSeleccionado;
  List<TypeCategory> listOpcions = [];

  // Listas filtradas
  List<TiendaLResponse> get _auditados =>
      listadoTiendas.where((t) => t.auditado == true).toList();

  List<TiendaLResponse> get _pendientes =>
      listadoTiendas.where((t) => t.auditado == false).toList();

  // El día es siempre "hoy" (campo = 1, dia = 0)
  final int _diaFijo = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _riBloc = BlocProvider.of<RIBloc>(context);
    _riBloc?.add(EventGetStoresIndicadores());
    _getPref();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      String? permisosString = preferences.getString('permisos');
      if (permisosString != null && permisosString.isNotEmpty) {
        permisos = permisosString.split(',');
      }

      listOpcions.add(TypeCategory(id: 1, descripcion: "AUDITAR"));
      listOpcions.add(TypeCategory(id: 2, descripcion: "VER RESULTADOS"));
      listOpcions.add(TypeCategory(id: 0, descripcion: "CERRAR"));

      isSupercito = preferences.getBool('esSupercito') ?? false;
      isAdmin = preferences.getBool('admin') ?? false;
    });
  }

  late String lastEmail;

  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [_blocListener(context)],
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: _buildAppBar(),
        drawer: permisos.contains("VIEW_DRAWER") ? NavBar() : null,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: permisos.contains("VIEW_M_CRONOGRAMA")
                ? _buildMainContent()
                : _buildEmptyContent(),
          ),
        ),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Menú',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Constants.appBarStartColor,
              Constants.appBarEndColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Constants.appBarStartColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 26),
          onPressed: () {
            Dialogs.confirm(
              context,
              title: "Cerrar sesión",
              description: "¿Seguro que deseas cerrar sesión?",
              onConfirm: _signOut,
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── Contenido principal ───────────────────────────────────────────────────

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con store selector + stats
        _buildHeaderSection(),
        // Tabs
        _buildTabBar(),
        // Lista
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dropdown de tienda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: BlocBuilder<RIBloc, RIState>(
              builder: (context, state) => _buildDropdown(state),
            ),
          ),
          // Leyenda de colores + contador
          if (listadoTiendas.isNotEmpty) _buildLegendAndStats(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLegendAndStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildLegendItem(
            color: const Color(0xFFB89C01),
            label: "Prioritario",
          ),
          const SizedBox(width: 12),
          _buildLegendItem(
            color: const Color(0xFF6C6C6C),
            label: "Regular",
          ),
          const SizedBox(width: 12),
          _buildLegendItem(
            color: const Color(0xFFB80101),
            label: "Revisar clase",
          ),
          const Spacer(),
          // Contador total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD0D8F0)),
            ),
            child: Text(
              "${listadoTiendas.length} categorías",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5FBF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  // ─── TabBar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    final auditadosCount = _auditados.length;
    final pendientesCount = _pendientes.length;

    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        tabs: [
          _buildTab(
            index: 0,
            icon: Icons.check_circle_rounded,
            label: "Auditados",
            count: auditadosCount,
            activeColor: const Color(0xFF2E7D32),
            activeBg: const Color(0xFFE8F5E9),
            badgeColor: const Color(0xFF4CAF50),
          ),
          _buildTab(
            index: 1,
            icon: Icons.pending_actions_rounded,
            label: "Pendientes",
            count: pendientesCount,
            activeColor: const Color(0xFFC62828),
            activeBg: const Color(0xFFFFEBEE),
            badgeColor: const Color(0xFFEF5350),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
    required int count,
    required Color activeColor,
    required Color activeBg,
    required Color badgeColor,
  }) {
    final isSelected = _selectedTabIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: activeColor.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? activeColor : const Color(0xFFAAAAAA),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : const Color(0xFFAAAAAA),
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? badgeColor : const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Contenido de tabs ─────────────────────────────────────────────────────

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildListSection(isAuditados: true),
        _buildListSection(isAuditados: false),
      ],
    );
  }

  Widget _buildListSection({required bool isAuditados}) {
    return BlocBuilder<RIBloc, RIState>(
      buildWhen: (previous, current) =>
          current is IsLoadingGetAvanceAuditoria ||
          current is SuccessGetAvanceAuditoria ||
          current is ErrorGetAvanceAuditoria,
      builder: (context, state) {
        // Loading
        if (state is IsLoadingGetAvanceAuditoria) {
          return _buildLoadingState();
        }

        // Error
        if (state is ErrorGetAvanceAuditoria) {
          return _buildErrorState(state.messageError);
        }

        // Sin tienda seleccionada
        if (_selectedStore == null) {
          return CenteredImageWithText(
            assetPath: 'assets/images/planet.png',
            title: 'Sin información',
            description: 'Selecciona una tienda para visualizar el cronograma.',
          );
        }

        final lista = isAuditados ? _auditados : _pendientes;

        // Lista vacía
        if (lista.isEmpty) {
          return _buildEmptyTab(isAuditados: isAuditados);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          itemCount: lista.length,
          itemBuilder: (context, index) {
            final tienda = lista[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AuditoriaCard(
                titulo: "${tienda.categoria} (${tienda.idCategoriaPln})",
                audito: tienda.auditado!,
                faltantes: tienda.faltante!,
                cumplimiento: tienda.cumplimiento!,
                badgePrioritario: tienda.prioritaria!,
                faltanteMayor: tienda.faltanteMayor!,
                grupo: tienda.grupo!,
                onTap: () {
                  if (isAuditados) {
                    // Auditados: mostrar modal con opciones
                    _mostrarModalSeleccion(index, tienda);
                  } else {
                    // Pendientes: ir directo a auditar
                    Navigator.of(context).push(
                      _createRoute(
                        SearchPage(
                          params: SearchParamsRequest(
                            isByMenu: true,
                            categoria: tienda.idCategoriaPln.toString(),
                            tienda: tienda.idTienda,
                          ),
                          day: _diaFijo,
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Constants.appBarStartColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cargando auditorías...',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Color(0xFFEF5350),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Error al cargar los datos',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (_selectedStore != null) {
                  _riBloc?.add(EventGetAvanceAuditoria(
                    params: TiendaLRequest(
                      idTienda: _selectedStore!.claveTienda,
                      dia: _diaFijo,
                    ),
                  ));
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.appBarStartColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTab({required bool isAuditados}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isAuditados
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAuditados
                    ? Icons.check_circle_outline_rounded
                    : Icons.pending_actions_rounded,
                size: 44,
                color: isAuditados
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isAuditados ? 'Sin auditorías completadas' : '¡Todo al día!',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAuditados
                  ? 'Aún no se han completado auditorías para esta tienda.'
                  : 'No hay categorías pendientes por auditar.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Column(
      children: [
        Center(
          child: CenteredImageWithText(
            assetPath: 'assets/images/planet.png',
            title: 'Próximamente',
            description:
                'Consulta nuestro menú de opciones ubicado en la parte superior.',
          ),
        ),
      ],
    );
  }

  // ─── Dropdown tiendas ──────────────────────────────────────────────────────

  Widget _buildDropdown(RIState state) {
    if (state is IsLoadingGetStore) {
      return _dropdownDisabled(label: 'Cargando tiendas...');
    }
    if (state is ErrorGetStore) {
      return Center(
        child: Text(
          state.messageError ?? 'Error al cargar las tiendas',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final hasItems = listStoreResponse.isNotEmpty;

    return DropdownSearch<StoreResponse>(
      popupProps: PopupProps.menu(
        showSearchBox: hasItems,
        menuProps: const MenuProps(
          backgroundColor: Colors.white,
          elevation: 4,
        ),
        searchFieldProps: const TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Buscar tienda...',
            prefixIcon: Icon(Icons.search_rounded),
            border: OutlineInputBorder(),
          ),
        ),
      ),
      items: (f, cs) => listStoreResponse,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText:
              hasItems ? 'Selecciona una tienda' : 'No hay tiendas disponibles',
          prefixIcon: Icon(
            Icons.store_rounded,
            color: Constants.appBarStartColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Constants.appBarStartColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      itemAsString: (StoreResponse store) => store.tienda ?? '',
      compareFn: (a, b) => a?.claveTienda == b?.claveTienda,
      enabled: hasItems,
      selectedItem: _selectedStore,
      onChanged: hasItems
          ? (value) {
              setState(() {
                _selectedStore = value;
                listadoTiendas = [];
              });
              if (value != null) {
                _riBloc?.add(EventGetAvanceAuditoria(
                  params: TiendaLRequest(
                    idTienda: value.claveTienda,
                    dia: _diaFijo,
                  ),
                ));
              }
            }
          : null,
    );
  }

  Widget _dropdownDisabled({required String label}) {
    return DropdownSearch<StoreResponse>(
      popupProps: PopupProps.menu(
        showSearchBox: false,
        menuProps: const MenuProps(
          backgroundColor: Colors.white,
          elevation: 2,
        ),
        disabledItemFn: (_) => true,
      ),
      items: (f, cs) => [],
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.store_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      compareFn: (a, b) => a?.claveTienda == b?.claveTienda,
      onChanged: null,
      enabled: false,
    );
  }

  // ─── BlocListener ──────────────────────────────────────────────────────────

  BlocListener _blocListener(BuildContext context) {
    return BlocListener<RIBloc, RIState>(listener: (context, state) {
      if (state is SuccessGetAvanceAuditoria) {
        setState(() {
          listadoTiendas = state.response;
        });
      }

      if (state is SuccessCierreTienda) {
        _riBloc?.add(EventGetAvanceAuditoria(
          params: TiendaLRequest(
            idTienda: _selectedStore!.claveTienda,
            dia: _diaFijo,
          ),
        ));
      }

      if (state is ErrorGetAvanceAuditoria) {
        setState(() {
          listadoTiendas = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.messageError!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }

      if (state is SuccessGetStore) {
        listStoreResponse = state.response;
        if (state.response.length == 1) {
          setState(() {
            _selectedStore = listStoreResponse[0];
          });
          _riBloc?.add(EventGetAvanceAuditoria(
            params: TiendaLRequest(
              idTienda: _selectedStore!.claveTienda,
              dia: _diaFijo,
            ),
          ));
        }
      }
    });
  }

  // ─── Modal de selección (solo para Auditados) ──────────────────────────────

  void _mostrarModalSeleccion(int index, TiendaLResponse tienda) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: Color(0xFF1565C0),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tienda.categoria ?? 'Categoría',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: Text(
                    "¿Qué deseas hacer?",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                for (var opcion in listOpcions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildModalButton(opcion, tienda),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalButton(TypeCategory opcion, TiendaLResponse tienda) {
    Color bgColor;
    Color fgColor;
    IconData iconData;

    switch (opcion.id) {
      case 1:
        bgColor = const Color(0xFF1565C0);
        fgColor = Colors.white;
        iconData = Icons.edit_note_rounded;
        break;
      case 2:
        bgColor = const Color(0xFF2E7D32);
        fgColor = Colors.white;
        iconData = Icons.bar_chart_rounded;
        break;
      default:
        bgColor = const Color(0xFFFFEBEE);
        fgColor = const Color(0xFFC62828);
        iconData = Icons.close_rounded;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (opcion.id == 1) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              _createRoute(
                SearchPage(
                  params: SearchParamsRequest(
                    isByMenu: true,
                    categoria: tienda.idCategoriaPln.toString(),
                    tienda: tienda.idTienda,
                  ),
                  day: _diaFijo,
                ),
              ),
            );
          } else if (opcion.id == 2) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              _createRoute(
                SearchBusinessPage(
                  params: SearchParamsRequest(
                    isByMenu: false,
                    categoria: tienda.idCategoriaPln.toString(),
                    tienda: tienda.idTienda,
                  ),
                ),
              ),
            );
          } else {
            Navigator.of(context).pop();
          }
        },
        icon: Icon(iconData, size: 18),
        label: Text(
          opcion.descripcion,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: opcion.id == 0 ? 0 : 1,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ─── Route ─────────────────────────────────────────────────────────────────

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // ─── Sign out ──────────────────────────────────────────────────────────────

  _signOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    lastEmail = sharedPreferences.getString('usuario')!;
    await sharedPreferences.clear();
    
    // Limpiar constantes estáticas de memoria para que el siguiente login lo cargue limpio.
    Constants.malUbicadosSecuencia = "";
    Constants.malUbicadosProdSinHuecos = "";

    sharedPreferences.setString("usuario", lastEmail);
    await Navigator.pushNamedAndRemoveUntil(
        context, LoginPage.routeName, (_) => false);
  }
}
