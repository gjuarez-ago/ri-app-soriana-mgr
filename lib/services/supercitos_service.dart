import 'package:ago_app/models/FurnitureSupercitosResponse.dart';
import 'package:ago_app/models/category_response.dart';
import 'package:ago_app/models/fixissues_response.dart';
import 'package:ago_app/models/segmentsSupercitos.dart';
import 'package:ago_app/models/send_pictures_supercitos_params.dart';
import 'package:ago_app/models/send_pictures_supercitos_response.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/models/supercito_delete_response.dart';
import 'package:ago_app/models/supercito_segm_stats_detail.dart';
import 'package:ago_app/models/supercito_segment_detail.dart';
import 'package:ago_app/models/supercito_segment_eventos.dart';
import 'package:ago_app/models/supercito_segment_stats_response.dart';
import 'package:ago_app/models/supercito_segments_stats_detail_request.dart';
import 'package:ago_app/services/api_helper.dart';
import 'package:ago_app/services/log_service.dart';
import 'package:ago_app/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SupercitosService {

  LogService logService = LogService();

  // Servicio para llamar las tiendas
  Future<List<StoreResponse>> getStoresBySupercitos(String category) async {
    var uri = ApiHelper.buildUri(Constants.apiUrl,
        '/${Constants.path}/ri/get-stores-by-supercitos/${getUser()}/${category}');

    logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: user: ${getUser} / category: $category');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);

        List<StoreResponse> list = List<StoreResponse>.from(
            l.map((model) => StoreResponse.fromMap(model)));
        return list;
      } else {
        print("--- ERROR EN getStoresBySupercitos ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception("Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getStoresBySupercitos: $e");
      throw Exception("Error de conexión en getStoresBySupercitos: $e");
    }
  }

  // Servicio para llamar las tiendas
  Future<List<CategoryResponse>> getCategoriesBySupercitos() async {
    var uri = ApiHelper.buildUri(Constants.apiUrl,
        '/${Constants.path}/ri/get-categories-by-supercitos/${getUser()}');

    logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: user: ${getUser} ');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        Iterable l = json.decode(decodedBody);

        List<CategoryResponse> list = List<CategoryResponse>.from(
            l.map((model) => CategoryResponse.fromJson(model)));

        return list;
      } else if (response.statusCode == 400) {
        throw Exception("Ocurrió un error con la consulta");
      } else if (response.statusCode == 500) {
        throw Exception("Problemas en el servidor");
      } else {
        throw Exception("No funciona el servicio por el momento");
      }
    } catch (e) {
      throw Exception("Error al conectar con el servicio: $e");
    }
  }

  // Servicio para llamar las tiendas
  Future<List<FurnitureSupercitosResponse>> getFurnitureBySupercito(
      int store, int idBitacora) async {
    var uri = ApiHelper.buildUri(Constants.apiUrl,
        '/${Constants.path}/ri/get-furniture-supercitos/${store}/${idBitacora}');

    logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: idBitacora: ${idBitacora} store: ${store}');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<FurnitureSupercitosResponse> list =
            List<FurnitureSupercitosResponse>.from(
                l.map((model) => FurnitureSupercitosResponse.fromJson(model)));
        return list;
      } else if (response.statusCode == 400) {
        throw Exception("Ocurrió un error con la consulta");
      } else if (response.statusCode == 500) {
        throw Exception("Problemas en el servidor");
      } else {
        throw Exception("No funciona el servicio por el momento");
      }
    } catch (e) {
      throw Exception("Error al conectar con el servicio: $e");
    }
  }

  // Servicio para llamar las tiendas
  Future<List<SegmentsSupercitos>> getSegmentsBySupercito(
      int piIdRealograma) async {
    var uri = ApiHelper.buildUri(Constants.apiUrl,
        '/${Constants.path}/ri/get-segments-supercitos/${piIdRealograma}/${Constants.enviroment}');

    logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: idBitacora: ${piIdRealograma} store: ${Constants.enviroment}');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<SegmentsSupercitos> list = List<SegmentsSupercitos>.from(
            l.map((model) => SegmentsSupercitos.fromJson(model)));
        return list;
      } else if (response.statusCode == 400) {
        throw Exception("Ocurrió un error con la consulta");
      } else if (response.statusCode == 500) {
        throw Exception("Problemas en el servidor");
      } else {
        throw Exception("No funciona el servicio por el momento");
      }
    } catch (e) {
      throw Exception("Error al conectar con el servicio: $e");
    }
  }

  Future<SupercitoDeleteResponse> deleteTramoSupercitos(
      int idRealograma, int tramo) async {
    print(idRealograma);
    print(tramo);

    var uri = ApiHelper.buildUri(Constants.apiUrl,
        '/${Constants.path}/ri/delete-segment-supercitos/$idRealograma/$tramo');

    logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: idRealograma: ${idRealograma} tramo: ${tramo}');

    try {
      final http.Response response = await http.delete(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return SupercitoDeleteResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        throw Exception("Ocurrió un error con la consulta");
      } else if (response.statusCode == 500) {
        throw Exception("Problemas en el servidor");
      } else {
        throw Exception("No funciona el servicio por el momento");
      }
    } catch (e) {
      throw Exception("Error al conectar con el servicio: $e");
    }
  }

  Future<SupercitoSegmentDetail> getDetailTramoSupercito(
      int idRealograma, int tramo) async {
    print(idRealograma);

    var uri = ApiHelper.buildUri(Constants.apiUrl,
        '/${Constants.path}/ri/segment-detail-supercito/$idRealograma/$tramo/${Constants.enviroment}');

    logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: idRealograma: ${idRealograma} tramo: ${tramo}, constante: ${Constants.enviroment}');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        // Decodifica el cuerpo de la respuesta y crea una instancia de FixIssuesResponse
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return SupercitoSegmentDetail.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        throw Exception("Ocurrió un error con la consulta");
      } else if (response.statusCode == 500) {
        throw Exception("Problemas en el servidor");
      } else {
        throw Exception("No funciona el servicio por el momento");
      }
    } catch (e) {
      throw Exception("Error al conectar con el servicio: $e");
    }
  }

  Future<FixIssuesResponse> cierreSupercitos(int idRealograma) async {


    var uri = ApiHelper.buildUri(
        Constants.apiUrl, '/${Constants.path}/ri/cierre-supercitos/$idRealograma');

    logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: idRealograma: ${idRealograma}');

    try {
      final http.Response response =
          await http.post(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        // Decodifica el cuerpo de la respuesta y crea una instancia de FixIssuesResponse
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return FixIssuesResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        throw Exception("Ocurrió un error con la consulta");
      } else if (response.statusCode == 500) {
        throw Exception("Problemas en el servidor");
      } else {
        throw Exception("No funciona el servicio por el momento");
      }
    } catch (e) {
      throw Exception("Error al conectar con el servicio: $e");
    }
  }



  // Servicio para llamar las tiendas
  Future<List<SupercitoSegmentEventos>> getEventsSupercito(
      int idTienda, String categoria) async {
    // Cambiamos la URL para incluir idTienda como query parameter
    var uri = ApiHelper.buildUri(
      Constants.apiUrl,
      '/${Constants.path}/ri/supercito-events', // Ruta base sin el parámetro
      {
        'idTienda': idTienda.toString(),
        'categoria': categoria.toString()
      }, // Query parameter agregado
    );

        logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: idTienda: ${idTienda} categoria: ${categoria}');


    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<SupercitoSegmentEventos> list = List<SupercitoSegmentEventos>.from(
            l.map((model) => SupercitoSegmentEventos.fromJson(model)));

        return list;
      } else if (response.statusCode == 400) {
        throw Exception("Ocurrió un error con la consulta");
      } else if (response.statusCode == 500) {
        throw Exception("Problemas en el servidor");
      } else {
        throw Exception("No funciona el servicio por el momento");
      }
    } catch (e) {
      throw Exception("Error al conectar con el servicio: $e");
    }
  }

  Future<SupercitoSegmentStatsResponse> getSegmentsStatsSupercitos(
      int tienda, int idEvento, int idBitacora) async {
    var uri = ApiHelper.buildUri(Constants.apiUrl,
        '/${Constants.path}/ri/supercito-segments-stats/${tienda}/${idEvento}/${idBitacora}');

        logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: idTienda: ${tienda} categoria: ${idEvento} idBitacora: $idBitacora');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        // Decodifica el cuerpo de la respuesta y crea una instancia de FixIssuesResponse
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return SupercitoSegmentStatsResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        throw Exception("Ocurrió un error con la consulta");
      } else if (response.statusCode == 500) {
        throw Exception("Problemas en el servidor");
      } else {
        throw Exception("No funciona el servicio por el momento");
      }
    } catch (e) {
      throw Exception("Error al conectar con el servicio: $e");
    }
  }

  Future<List<SupercitoSegmStatsDetail>> getStatsDetails(
      SupercitoSegmentStatsDetailRequest request) async {

    var uri = ApiHelper.buildUri(Constants.apiUrl, '/${Constants.path}/ri/supercito-stats-details');
    
    try {
      // Serializa el objeto `request` a JSON
      String requestBody = jsonEncode(request.toJson());

      print(requestBody);

      // Realiza la solicitud POST con el cuerpo y las cabeceras
      final http.Response response = await http.post(
        uri,
        headers: getHeadersWithToken(),
        body: requestBody,
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<SupercitoSegmStatsDetail> list =
            List<SupercitoSegmStatsDetail>.from(
                l.map((model) => SupercitoSegmStatsDetail.fromJson(model)));

        return list;
      } else {
        print("--- ERROR EN getStatsDetails ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception("Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getStatsDetails: $e");
      throw Exception("Error de conexión en getStatsDetails: $e");
    }
  }

  // Ahora puedes obtener los encabezados de forma síncrona
  Map<String, String> getHeadersWithToken() {
    String token = Constants.token;

    return {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    };
  }

  String getUser() {
    String user = Constants.user;
    return user;
  }

  Future<SendPictureSupectitosResponse> sendPicturesV1Supercitos(
      SendPicturesSupercitosParams params) async {

    var uri = ApiHelper.buildUri(Constants.apiSUAJEUrl, '/unionImagenes');
    http.Response? response;

        logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: ${params.toJson()} ');

    try {
      
      if (params.segments == 1) {
        response = await http.post(
          uri,
          headers: getHeadersWithToken(),
          body: jsonEncode({
            "idRealograma": params.idRealograma,
            "tramo": params.tramo,
            "usuario": params.usuario,
            "categoria": params.categoria,
            "idTienda": params.idTienda,
            "evento":params.evento,
            "fechaCap": _getCurrentFormattedDateTime(),
            "imagen": params.imagenInferior,
            "ambiente": Constants.enviroment,
          }),
        );



      }

      if (params.segments == 2) {
        response = await http.post(
          uri,
          headers: getHeadersWithToken(),
          body: jsonEncode({
            "idRealograma": params.idRealograma,
            "tramo": params.tramo,
            "usuario": params.usuario,
            "categoria": params.categoria,
            "idTienda": params.idTienda,
            "evento":params.evento,
            "fechaCap": _getCurrentFormattedDateTime(),
            "imagen_inferior": params.imagenInferior,
            "imagen_superior": params.imagenSuperior,
            "ambiente": Constants.enviroment,
          }),
        );
      }

      if (response?.statusCode == 200) {
        final responseBody = jsonDecode(response!.body);
        return SendPictureSupectitosResponse.fromJson(responseBody);
      } else if (response?.statusCode == 400) {
        throw Exception("Ocurrió un error con la consulta");
      } else if (response?.statusCode == 500) {
        throw Exception("Problemas en el servidor");
      } else {
        throw Exception("No funciona el servicio por el momento");
      }

    } catch (e) {
      throw Exception("Error al conectar con el servicio: $e");
    }
  }

  String _getCurrentFormattedDateTime() {
    DateTime now = DateTime.now();

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String threeDigits(int n) => n.toString().padLeft(3, '0');

    String year = now.year.toString();
    String month = twoDigits(now.month);
    String day = twoDigits(now.day);
    String hour = twoDigits(now.hour);
    String minute = twoDigits(now.minute);
    String second = twoDigits(now.second);
    String millisecond = threeDigits(now.millisecond);

    return '$year-$month-$day $hour:$minute:$second.$millisecond';
  }
}
