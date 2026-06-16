import 'dart:convert';
import 'package:ago_app/models/login_response.dart';
import 'package:ago_app/services/api_helper.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:http/http.dart' as http;


class AuthService {

  

  // ** : Servicio para loguearnos
  Future<LoginResponse> login(String user, String password) async {
    var uri = ApiHelper.buildUri(
      Constants.apiUrl,
      '/${Constants.path}/auth/login',
    );

    final http.Response response = await http.post(
      uri,
      headers: Constants.headersPublic,
      body:
          jsonEncode(<String, dynamic>{"username": user, "password": password}),
    );

    print(uri);

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(json.decode(response.body));
    }

    if (response.statusCode == 400) {
      return throw ("Nombre de usuario / contraseña incorrectos. Inténtalo de nuevo");
    }

    if (response.statusCode == 500) {
      return throw ("Problemas en el servidor");
    }

    return throw ("No funciona el servicio por el momento");
  }

  

}