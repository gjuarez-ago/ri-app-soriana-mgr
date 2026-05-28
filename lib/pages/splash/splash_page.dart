import 'dart:async';

import 'package:ago_app/bloc/bloc.dart';
import 'package:ago_app/pages/home/home_page.dart';
import 'package:ago_app/pages/login/login_page.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:ago_app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);
  static String routeName = "splash_page";

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  RIBloc? _riBloc;
  List<String> permisos = [];
  StreamSubscription? _sub;

  late String lastEmail;

  @override
  void initState() {
    super.initState();
    _riBloc = BlocProvider.of<RIBloc>(context);
    _riBloc?.add(EventGetConstants());
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   // Widget
    //   getPref();
    // });
  }

  signOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    lastEmail = sharedPreferences.getString('usuario')!;
    await sharedPreferences.clear();

    Constants.malUbicadosSecuencia = "";
    Constants.malUbicadosProdSinHuecos = "";

    sharedPreferences.setString("usuario", lastEmail);
    await Navigator.pushNamedAndRemoveUntil(
        context, LoginPage.routeName, (_) => false);
  }

  getPref() async {
    
    await Future.delayed(const Duration(seconds: 2));
    String? token;
    bool hasExpired = false;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    token = preferences.getString('token');

    String? permisosString = preferences.getString('permisos');

    if (permisosString != null && permisosString.isNotEmpty) {  
      permisos = permisosString.split(',');
    }
    
    if (token != null) {
      hasExpired = JwtDecoder.isExpired(token);
    }

    if (token != null && !hasExpired) {
      Constants.loadEnviroments();
      Constants.loadToken();
      
      Navigator.pushReplacementNamed(context, HomePage.routeName);

    } else {
      Constants.loadEnviroments();
      signOut();
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);
    return MultiBlocListener(
      listeners: [
        blocListenerDelete(context),
      ],
      child: Scaffold(
        body: Container(
          color: Constants.appBarEndColor,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                color: Constants.appBarEndColor,
                padding: EdgeInsets.only(bottom: responsive.dp(4)),
                child: Container(
                  alignment: Alignment.center,
                  child: Lottie.asset(
                    'assets/images/loading.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 200, left: 100, right: 100),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/images/logo_b.png',
                    // color: Colors.white30,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  BlocListener blocListenerDelete(BuildContext context) {
    return BlocListener<RIBloc, RIState>(listener: (context, state) async {
      if (state is IsLoadingGetConstants) {}

      if (state is SuccessGetConstants) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        setState(() {
          preferences.setString(
              "apiPathService", state.response.apiPathService);
          preferences.setString("apiUrlService", state.response.apiUrlService);
          preferences.setString(
              "apiEnvironment", state.response.apiEnvironment);
          preferences.setString("apiPathSuaje", state.response.apiPathSuaje);
          preferences.setString("apiUrlSuaje", state.response.apiUrlSuaje);
          preferences.setString("apiPathRICh", state.response.apiPathRICh);
          preferences.setString("apiUrlRICh", state.response.apiUrlRICh);
          preferences.setString("apiUrlBI", state.response.apiUrlBI);
          preferences.setString("malUbicadosSecuencia", state.response.malUbicadosSecuencia);
          preferences.setString("malUbicadosProdSinHuecos", state.response.malUbicadosProdSinHuecos);
        });

        getPref();
      }

      if (state is ErrorGetConstants) {
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

        Navigator.pushReplacementNamed(context, LoginPage.routeName);
      }
    });
  }

  saveEnviroments(
      String apiPathService,
      String apiUrlService,
      String apiEnvironment,
      String apiPathSuaje,
      String apiUrlSuaje,
      String apiPathRICh,
      String apiUrlRICh,
      String apiUrlBI,
      String malUbicadosSecuencia,
      String malUbicadosProdSinHuecos) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      preferences.setString("apiPathService", apiPathService);
      preferences.setString("apiUrlService", apiUrlService);
      preferences.setString("apiEnvironment", apiEnvironment);
      preferences.setString("apiPathSuaje", apiPathSuaje);
      preferences.setString("apiUrlSuaje", apiUrlSuaje);
      preferences.setString("apiPathRICh", apiPathRICh);
      preferences.setString("apiUrlRICh", apiUrlRICh);
      preferences.setString("apiUrlBI", apiUrlBI);
      preferences.setString("malUbicadosSecuencia", malUbicadosSecuencia);
      preferences.setString("malUbicadosProdSinHuecos", malUbicadosProdSinHuecos);
    });
  }
}