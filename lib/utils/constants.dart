import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static const double padding = 20;
  static const double avatarRadius = 55;
  static const Color blueGeneric = Color.fromARGB(0, 15, 48, 156);
  // static Color appBarStartColor = Color.fromARGB(255, 23, 191, 11); // Blanco
  // static Color appBarEndColor = Color.fromARGB(255, 36, 144, 28); // Rojo oscuro
  static Color appBarStartColor = Colors.blue.shade400;
  static Color appBarEndColor = Colors.blue.shade800;

  static String apiUrl =
      '200.78.251.37:8432'; // Soriana Desarrollo Actualizado 30/10/25
  // static String apiUrl = '148.245.208.247:8046'; // Soriana QA
  // static String apiUrl = '148.245.208.250:8475';// Soriana Producción

  static String apiIAUrl = ''; // I&D
  static String apiBIUrl = ''; // BI
  static String apiSUAJEUrl = ''; // Detector de suajes

  static String malUbicadosSecuencia = "";
  static String malUbicadosProdSinHuecos = "";

  static String path = "ri-api";
  static String pathSuaje = "";
  static String pathIACh = "";
  static String enviroment = "";

  static String token = "";
  static String user = "";

  static const Map<String, String> headersPublic = {
    HttpHeaders.contentTypeHeader: "application/json"
  };

  static Future<void> loadToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    token = preferences.getString("token") ?? "";
    user = preferences.getString("usuario")!;
  }

  static Future<void> loadEnviroments() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    path = preferences.getString("apiPathService")!;
    apiUrl = preferences.getString("apiUrlService")!;
    enviroment = preferences.getString("apiEnvironment")!;
    pathSuaje = preferences.getString("apiPathSuaje")!;
    apiSUAJEUrl = preferences.getString("apiUrlSuaje")!;
    pathIACh = preferences.getString("apiPathRICh")!;
    apiIAUrl = preferences.getString("apiUrlRICh")!;
    apiBIUrl = preferences.getString("apiUrlBI")!;
    malUbicadosSecuencia = preferences.getString("malUbicadosSecuencia") ?? "";
    malUbicadosProdSinHuecos =
        preferences.getString("malUbicadosProdSinHuecos") ?? "";
  }
}

const kPrimaryColor = Color(0xFFFF8084);
const kAccentColor = Color(0xFFF1F1F1);
const kWhiteColor = Color(0xFFFFFFFF);
const kLightColor = Color(0xFF808080);
const kDarkColor = Color(0xFF303030);
const kTransparent = Colors.transparent;

const kDefaultPadding = 24.0;
const kLessPadding = 10.0;
const kFixPadding = 16.0;
const kLess = 4.0;

const kShape = 30.0;

const kRadius = 0.0;
const kAppBarHeight = 56.0;

const kHeadTextStyle = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
);

const kSubTextStyle = TextStyle(
  fontSize: 18.0,
  color: kLightColor,
);

const kTitleTextStyle = TextStyle(
  fontSize: 20.0,
  color: kPrimaryColor,
);

const kDarkTextStyle = TextStyle(
  fontSize: 23.0,
  color: kDarkColor,
);

const kDivider = Divider(
  color: kAccentColor,
  thickness: kLessPadding,
);

const kSmallDivider = Divider(
  color: kAccentColor,
  thickness: 5.0,
);

const String pieChart = 'assets/images/pieChart.png';
const String trophy = 'assets/images/trophy.png';
const String chat = 'assets/images/chat.png';
const String whiteShape = 'assets/images/whitebg.svg';
const String logo = 'assets/images/shoppingBag.png';
const String profile = 'assets/images/profile.jpg';
const String bg = 'assets/images/background.jpg';
const String manShoes = 'assets/images/manShoes.jpg';
const String success = 'assets/images/success.gif';
const String chatBubble = 'assets/images/emptyChat.png';
const String emptyOrders = 'assets/images/orders.png';
const String callCenter = 'assets/images/center.png';
const String conversation = 'assets/images/conversation.png';
