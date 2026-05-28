import 'package:ago_app/models/search_params_request.dart';
import 'package:ago_app/pages/implementation_of_planogram/implementation_of_planograms_page.dart';
import 'package:ago_app/pages/login/login_page.dart';
import 'package:ago_app/pages/search/search_page.dart';
import 'package:ago_app/pages/search_business/search_business_page.dart';
import 'package:ago_app/pages/search_planogram/search_planogram_page.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  List<String> permisos = [];
  bool isSupercito = false;
  bool isAdmin = false;
  String names = '', apP = '', apM = '', userName = '', initials = '';
  String usuario = '';
  String _version = '';

  signOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    await Navigator.pushNamedAndRemoveUntil(
        context, LoginPage.routeName, (_) => false);
  }

  Route _createRoute(page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    getPref();
    _getAppVersion();
    super.initState();
  }

  
  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _version = packageInfo.version; // ← Esto es el 2.0.1
    });
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      String? permisosString = preferences.getString('permisos');

      if (permisosString != null && permisosString.isNotEmpty) {
        permisos = permisosString.split(',');
        for (var permiso in permisos) {
          print(permiso
              .trim()); // El trim() elimina espacios en blanco adicionales
        }
      }

      isSupercito = preferences.getBool('esSupercito')!;
      isAdmin = preferences.getBool('admin')!;
      names = "${preferences.getString('name')?.trim() ?? 'Nombres'}";
      apP = '${preferences.getString('apPaterno')?.trim() ?? 'Paterno'}';
      apM = '${preferences.getString('apMaterno')?.trim() ?? 'Materno'}';
      userName = '$names $apP $apM';
      initials = '${names[0].toUpperCase()}${apP[0].toUpperCase()}';
      usuario = "${preferences.getString('idUsuario')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                accountName: Text(
                  "$userName",
                  style: TextStyle(fontSize: 17),
                ),
                accountEmail: Column(
                  children: [
                    // Text(
                    //   "$usuario",
                    //   style: TextStyle(fontSize: 15),
                    // ),
                    Text(
                       'Versión $_version',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 12,
                                    ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                arrowColor: Colors.amber,
                currentAccountPicture: Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text(
                      initials,
                      style: TextStyle(fontSize: 30.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: permisos.contains("VIEW_M_CAPREC"),
                child: ListTile(
                  title: Text("Captura reconocimiento"),
                  leading: _getIconForTitle("Captura reconocimiento"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(_createRoute(SearchPage(
                        params: SearchParamsRequest(
                            isByMenu: false, categoria: '0', tienda: 0), day: 1,)));
                  },
                ),
              ),
              Visibility(
                visible: permisos.contains("VIEW_M_ANARE"),
                child: ListTile(
                  title: Text("Análisis reconocimiento"),
                  leading: _getIconForTitle("arec."),
                  onTap: () {
                    Navigator.pop(context);
      
                    Navigator.of(context).push(_createRoute(SearchBusinessPage(
                      params: SearchParamsRequest(
                        isByMenu: true,
                        categoria: '0',
                        tienda: 0,
                      ),
                    )));
                  },
                ),
              ),
              // Visibility(
              //   visible: permisos.contains("VIEW_M_CAPSUPER"),
              //   child: ListTile(
              //     title: Text("Captura supercitos"),
              //     leading: _getIconForTitle("Captura supercitos"),
              //     onTap: () {
              //       Navigator.pop(context);
      
              //       Navigator.of(context)
              //           .push(_createRoute(SearchSupercitosPage()));
              //     },
              //   ),
              // ),
              // Visibility(
              //   visible: permisos.contains("VIEW_M_ANASUPER"),
              //   child: ListTile(
              //     title: Text("Análisis supercitos"),
              //     leading: _getIconForTitle("Análisis supercito"),
              //     onTap: () {
              //       Navigator.pop(context);
      
              //       Navigator.of(context)
              //           .push(_createRoute(SupercitoStatsPage()));
              //     },
              //   ),
              // ),
              Visibility(
                visible: permisos.contains('VIEW_M_PLANOGRAM'),
                child: ListTile(
                  title: Text("Planograma"),
                  leading: _getIconForTitle("Planograma"),
                  onTap: () {
                    _showModal(context, 1);
                  },
                ),
              ),
               Visibility(
                visible: permisos.contains('VIEW_M_IMPLEMENTACIONES'),
                child: ListTile(
                  title: Text("Implementaciones"),
                  leading: _getIconForTitle("Implementaciones"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(
                      context,
                    ).push(_createRoute(ImplementationOfPlanogramsPage()));
                  },
                ),
              ),
              Divider(
                thickness: 2.0,
                color: Colors.blueAccent,
              ),
              ListTile(
                title: Text("Salir"),
                leading: Icon(
                  Icons.exit_to_app,
                  size: 25,
                  color: Color.fromARGB(255, 255, 0, 0),
                ),
                onTap: () {
                  signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Icon _getIconForTitle(String title) {
    switch (title) {
      case 'Captura reconocimiento':
        return const Icon(Icons.camera_alt, color: Colors.blueAccent);
      case 'arec.':
        return const Icon(Icons.analytics, color: Colors.teal);
      case 'Captura supercitos':
        return const Icon(Icons.store_mall_directory, color: Colors.orange);
      case 'Análisis supercito':
        return const Icon(Icons.bar_chart, color: Colors.deepPurple);
      case 'Planograma':
        return const Icon(Icons.grid_view, color: Colors.brown);
      case 'Implementaciones':
        return const Icon(Icons.shopping_cart, color: Colors.lime);
      case 'Salir':
        return const Icon(Icons.exit_to_app, color: Colors.red);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  void _showModal(BuildContext context, int type) {
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
                ListTile(
                  title: const Text('Buscar planograma por:',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),

                const Divider(),
                ListTile(
                  leading: const Icon(Icons.store),
                  title: const Text('Tiendas',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchPlanogramPage(type: 1),
                    ));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.account_tree),
                  title: const Text(
                    'Productos',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchPlanogramPage(type: 2),
                    ));
                  },
                ),
                const Divider(),

                // ListTile(
                //   leading: const Icon(Icons.add_a_photo),
                //   title: const Text('Tomar 3 fotos'),
                //   onTap: () {
                //     int tramo = 0;
                //     int idReconocimiento = 0;

                //     if (type == 1) {
                //       tramo = encontrarTramoMasGrande(listSegments) + 1;
                //       idReconocimiento = 0;
                //     } else {
                //       tramo = tramoSelected!.tramo;
                //       idReconocimiento = tramoSelected!.idReconocimiento;
                //     }

                //     SearchModelHelper model = SearchModelHelper(
                //         event: _selectedStore!.evento,
                //         idTienda: _selectedStore!.claveTienda,
                //         idRealograma: _selectedFurniture!.idRealograma,
                //         tramo: tramo,
                //         categoria: _selectedCategory.toString(),
                //         idReconocimiento: idReconocimiento);

                //     // Acción al seleccionar Tomar 3 fotos
                //     Navigator.pop(context);
                //     Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) => TakePicturePage(
                //           numberSegments: 3, searchParams: model),
                //     ));
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
