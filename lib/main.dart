import 'dart:async';
import 'dart:io';

import 'package:ago_app/pages/splash/splash_page.dart';
import 'package:ago_app/router/routes.dart';
import 'package:ago_app/services/bloc_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_update/in_app_update.dart'; // Importamos la librería
import 'bloc/bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  // in_app_update only works on Android (Google Play Core); skip on iOS.
  if (Platform.isAndroid) {
    await checkForUpdate();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocsServices(""),
      child: MaterialApp(
        title: 'AGO App',
        debugShowCheckedModeBanner: false,
        initialRoute: SplashPage.routeName,
        theme: ThemeData(
          fontFamily: 'Comfortaa',

          primaryColor: Colors.white, // Color principal blanco
          brightness: Brightness.light, // 👈 Tema claro

          scaffoldBackgroundColor:
              Colors.white, // 👈 Fondo blanco en todas las pantallas

          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black,
            selectionHandleColor: Colors.black,
            selectionColor: Colors.black26,
          ),

          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Colors.white, // 👈 Loader blanco
            circularTrackColor: Colors.grey, // Fondo del círculo
            linearTrackColor: Colors.grey, // Fondo de la barra
            refreshBackgroundColor: Colors.white,
          ),

          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white, // Fondo blanco en navbar
            selectedItemColor:
                Colors.black, // Íconos/textos seleccionados negros
            unselectedItemColor: Colors.grey, // No seleccionados grises
          ),

          //  scaffoldBackgroundColor: Colors.white, // 👈 Fondo blanco en todas las pantallas
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white), // Íconos negros
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white, // 👈 Campos blancos por defecto
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.black),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.black, width: 1), // borde negro al enfocar
            ),
          ),

          cardTheme: const CardThemeData(
            color: Colors.white, // 👈 Fondo blanco global
            surfaceTintColor:
                Colors.white, // 👈 Evita el "overlay" en Material 3
            shadowColor: Colors.black26, // 👈 Opcional, sombra más suave
            elevation: 3, // 👈 Opcional, altura de la sombra
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(12)), // 👈 Bordes redondeados
            ),
          ),
        ),
        routes: getApplicationRoutes(),
      ),
    );
  }
}

// Clase para manejar la actualización
Future<void> checkForUpdate() async {
  try {
    final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

    // Si hay una actualización inmediata disponible, la realizamos
    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
        updateInfo.immediateUpdateAllowed) {
      await InAppUpdate.performImmediateUpdate();
    }
  } catch (e) {
    // Si ocurre algún error (por ejemplo, problemas de red), lo mostramos
    print('Error al comprobar la actualización: $e');
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
