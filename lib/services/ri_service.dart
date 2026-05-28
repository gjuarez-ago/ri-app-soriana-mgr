import 'package:ago_app/models/CapturarFaltanteParams.dart';
import 'package:ago_app/models/consultas_response.dart';
import 'package:ago_app/models/implementation_of_planograms_item_response.dart';
import 'package:ago_app/models/location_response.dart';
import 'package:ago_app/models/label_incidents_response.dart';
import 'package:ago_app/models/login_response.dart';
import 'package:ago_app/models/nuevos_planogramas_impl_response.dart';
import 'package:ago_app/models/planogram.dart';
import 'package:ago_app/models/capture_response.dart';
import 'package:ago_app/models/category_response.dart';
import 'package:ago_app/models/detalle_nivel_con_imagen.dart';
import 'package:ago_app/models/detalle_nivel_params.dart';
import 'package:ago_app/models/detalle_nivel_response.dart';
import 'package:ago_app/models/event_details.dart';
import 'package:ago_app/models/events_response.dart';
import 'package:ago_app/models/faltante_response.dart';
import 'package:ago_app/models/fix_response.dart';
import 'package:ago_app/models/fix_single_issue.dart';
import 'package:ago_app/models/fixissues_response.dart';
import 'package:ago_app/models/furniture_segm_response.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/incidents_response.dart';
import 'package:ago_app/models/layout_faltante_params.dart';
import 'package:ago_app/models/layout_faltante_response.dart';
import 'package:ago_app/models/muebles_categoria_response.dart';
import 'package:ago_app/models/planogram_item_product.dart';
import 'package:ago_app/models/resume_pictures_params.dart';
import 'package:ago_app/models/resume_pictures_response.dart';
import 'package:ago_app/models/segments_incidents_response.dart';
import 'package:ago_app/models/send_picture_params.dart';
import 'package:ago_app/models/send_picture_params_v2.dart';
import 'package:ago_app/models/send_pictures_response.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/models/deparments_response.dart';
import 'package:ago_app/models/furniture_response.dart';
import 'package:ago_app/models/product_list_response.dart';
import 'package:ago_app/models/tienda_l_request.dart';
import 'package:ago_app/models/tienda_l_response.dart';
import 'package:ago_app/models/tramos_mueble_response.dart';
import 'package:ago_app/models/validate_categories.dart';
import 'package:ago_app/models/validate_ceros_response.dart';
import 'package:ago_app/models/validate_tramos_request.dart';
import 'package:ago_app/models/validateceros.dart';
import 'package:ago_app/services/log_service.dart';
import 'package:ago_app/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/misplaced_products_response.dart';
import '../models/producto_mal_acomodado_secuencia.dart';
import '../models/producto_sin_hueco.dart';
import '../models/adyacencia_error_response.dart';

class RIService {
  LogService logService = LogService();
  Future<List<CategoryResponse>> getAllCategories() async {
    var uri = Uri.http(
        Constants.apiUrl, '/${Constants.path}/ri/get-categories/${getUser()}');

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
    } else {
      print("--- ERROR EN getAllCategories ---");
      print("URL: $uri");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("-------------------------------");
      throw Exception(
          "Error del servidor (${response.statusCode}): ${response.body}");
    }
  }

  Future<CategoryResponse> getAllCategoriesByUPC(int store, String upc) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-categories-by-upc/${store}/${upc}');

    final http.Response response = await http.get(
      uri,
      headers: getHeadersWithToken(),
    );

    if (response.statusCode == 200) {
      String decodedBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> jsonResponse = jsonDecode(decodedBody);
      return CategoryResponse.fromJson(jsonResponse);
    } else {
      print("--- ERROR EN getAllCategoriesByUPC ---");
      print("URL: $uri");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("-------------------------------");
      throw Exception(
          "Error del servidor (${response.statusCode}): ${response.body}");
    }
  }

  Future<List<StoreResponse>> getStores(String categoryId) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-stores/${categoryId}/${getUser()}');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      logService.writeLog(
          "API-MESSAGE", 'URL: ${uri} PARAMS: ${categoryId}/${getUser()}');

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<StoreResponse> list = List<StoreResponse>.from(
            l.map((model) => StoreResponse.fromMap(model)));
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

  Future<List<Planograma>> getPdfPlanogram(
      String store, String categoryId, bool esSupercito) async {
    var uri;

    if (esSupercito) {
      uri = Uri.http(Constants.apiUrl,
          '/${Constants.path}/ri/lista-planogramas-supercitos/${categoryId}');
    } else {
      uri = Uri.http(Constants.apiUrl,
          '/${Constants.path}/ri/lista-planogramas/${categoryId}/${store}');
    }

    logService.writeLog(
        "API-MESSAGE", 'URL: ${uri} PARAMS: ${categoryId}/${store}');

    print('URL: ${uri}');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<Planograma> list =
            List<Planograma>.from(l.map((model) => Planograma.fromJson(model)));

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

  Future<List<StoreResponse>> getStoresIndicadores() async {
    print(getUser());
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-tiendas-indicadores/${getUser()}');

    logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: ${getUser()}');

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

  Future<List<DeparmentsResponse>> getDeptosTienda(
      int storeId, int event) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-deparments/$storeId/$event');

    logService.writeLog(
        "API-MESSAGE", 'URL: ${uri} PARAMS: ${storeId}/${event}');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<DeparmentsResponse> list = List<DeparmentsResponse>.from(
            l.map((model) => DeparmentsResponse.fromMap(model)));
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

  Future<List<FurnitureResponse>> getMueblesTienda(
      int storeId, int event, String categoria, int bitacora) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-furnitures/$storeId/$event/$categoria/$bitacora');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: /$storeId/$event/$categoria/$bitacora');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<FurnitureResponse> list = List<FurnitureResponse>.from(
            l.map((model) => FurnitureResponse.fromJson(model)));
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

  Future<List<SegmentIncidentsResponse>> getIncidencias(
      int idReconocimiento, int tramo) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-incidents/$idReconocimiento/$tramo');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: IdReconocimiento: $idReconocimiento, Tramo: $tramo');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        List<SegmentIncidentsResponse> list =
            List<SegmentIncidentsResponse>.from(
          l.map((model) => SegmentIncidentsResponse.fromMap(model)),
        );
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

  Future<List<FurnitureSegmentResponse>> getSegmentos(
      int idRealograma, String idCategoria) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-segments/$idRealograma/$idCategoria/${Constants.enviroment}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: idRealograma; $idRealograma/IdCategoria: $idCategoria/Enviroment: ${Constants.enviroment}');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        List<FurnitureSegmentResponse> list =
            List<FurnitureSegmentResponse>.from(
          l.map((model) => FurnitureSegmentResponse.fromMap(model)),
        );
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

  Future<List<ProductListResponse>> getProductos(
      int idReconocimiento, int tramo) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-products/$idReconocimiento/$tramo');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: idReconocimiento; $idReconocimiento, Tramo: $tramo');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<ProductListResponse> list = List<ProductListResponse>.from(
            l.map((model) => ProductListResponse.fromMap(model)));
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

  Future<FixIssuesResponse> getFixIssue(String incidencias) async {
    var uri = Uri.http(Constants.apiUrl, '/${Constants.path}/ri/get-fixissue');

    logService.writeLog(
        "API-MESSAGE", 'URL: ${uri} PARAMS: incidencias; $incidencias');

    try {
      final http.Response response = await http.post(
        uri,
        headers: getHeadersWithToken(),
        body: jsonEncode({'incidencias': incidencias}),
      );

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

  Future<FixResponse> fixSingleIssue(FixSingleIssueParams incidencia) async {
    var uri =
        Uri.http(Constants.apiUrl, '/${Constants.path}/ri/fix-single-issue');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: idRegistro: ${incidencia.idRegistro}, upc: ${incidencia.upc}');

    try {
      final http.Response response = await http.post(
        uri,
        headers: getHeadersWithToken(),
        body: jsonEncode(
            {"idRegistro": incidencia.idRegistro, "upc": incidencia.upc}),
      );

      if (response.statusCode == 200) {
        // Decodifica el cuerpo de la respuesta y crea una instancia de FixIssuesResponse
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return FixResponse.fromJson(jsonResponse);
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

  Future<List<IncidentsResponse>> getListIncidentsV2(
      GetIssuesParams request) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/incidents/${request.idTienda}/${request.evento}/${request.idCategoria}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: idTienda: ${request.idTienda} evento: ${request.evento}/idCategoria: ${request.idCategoria}');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        List<IncidentsResponse> list = List<IncidentsResponse>.from(
            l.map((model) => IncidentsResponse.fromJson(model)));
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

  Future<FixIssuesResponse> generarIndicadores(GetIssuesParams request) async {
    print("${request.idTienda}/${request.evento}/${request.idCategoria}");

    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/cierre-categoria/${request.idTienda}/${request.evento}/${request.idCategoria}/${request.idBitacora}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: idTienda: ${request.idTienda} evento: ${request.evento} idCategoria: ${request.idCategoria}, idBitacora: ${request.idBitacora}');

    print(uri);

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

  Future<int> getStatusIndicadores(GetIssuesParams request) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/estatus-cierre-categoria/${request.idTienda}/${request.evento}/${request.idCategoria}/${request.idBitacora}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: idTienda: ${request.idTienda} evento: ${request.evento}/idCategoria: ${request.idCategoria} idBitacora: ${request.idBitacora}');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      print("Response ${response.body}");

      if (response.statusCode == 200) {
        // Decodifica directamente el cuerpo de la respuesta como un entero
        return int.parse(response.body);
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

  Future<FixIssuesResponse> cierreTienda(GetIssuesParams request) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/cierre-tienda/${request.idTienda}/${request.evento}/${request.idCategoria}/${request.idBitacora}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: idTienda: ${request.idTienda} evento: ${request.evento}/idCategoria: ${request.idCategoria} idBitacora: ${request.idBitacora}');

    print(uri);

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

  Future<SendPictureResponse> sendPictures(SendPictureParams params) async {
    var uri = Uri.http(Constants.apiBIUrl, '/unionImagenes');
    http.Response? response;

    logService.writeLog(
        "API-MESSAGE", 'URL: ${uri} PARAMS: ${params.toJson()}');

    try {
      if (params.segments == 2) {
        response = await http.post(
          uri,
          headers: getHeadersWithToken(),
          body: jsonEncode({
            // "imagen_superior": params.imagenSuperior,
            // "imagen_inferior": params.imagenInferior
            "imagen_inferior": params.imagenInferior,
            "imagen_superior": params.imagenSuperior
          }),
        );
      }

      if (params.segments == 3) {
        response = await http.post(
          uri,
          headers: getHeadersWithToken(),
          body: jsonEncode({
            "imagen_inferior": params.imagenInferior,
            "imagen_media": params.imagenMedia,
            "imagen_superior": params.imagenSuperior,
          }),
        );
      }

      if (response?.statusCode == 200) {
        final responseBody = jsonDecode(response!.body);
        return SendPictureResponse.fromJson(responseBody);
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

  Future<SendPictureResponse> sendPicturesV2(SendPictureParamsV2 params) async {
    var uri = Uri.http(Constants.apiIAUrl, '${Constants.pathIACh}');

    print(uri);

    http.Response? response;

    logService.writeLog(
        "API-MESSAGE", 'URL: ${uri} PARAMS: ${params.toJson()}');

    try {
      Map<String, dynamic> body = {
        "idRealograma": params.idRealograma,
        "tramo": params.tramo,
        "usuario": params.usuario,
        "categoria": params.categoria,
        "fechaCap": _getCurrentFormattedDateTime(),
        "idTienda": params.idTienda,
        "evento": params.evento,
        "ambiente": params.ambiente,
      };

      if (params.segments == 1) {
        body["imagen"] = params.imagenSuperior;
      } else if (params.segments == 2) {
        body["imagen_inferior"] = params.imagenInferior;
        body["imagen_superior"] = params.imagenSuperior;
      } else if (params.segments == 3) {
        body["imagen_inferior"] = params.imagenInferior;
        body["imagen_media"] = params.imagenMedia;
        body["imagen_superior"] = params.imagenSuperior;
      }

      print('sendPicturesV2 request body keys: ${body.keys.toList()}');
      print('sendPicturesV2 image lengths: ' +
          '{imagenSuperior=${params.imagenSuperior?.length}, imagenMedia=${params.imagenMedia?.length}, imagenInferior=${params.imagenInferior?.length}}');

      response = await http.post(
        uri,
        headers: getHeadersWithToken(),
        body: jsonEncode(body),
      );

      if (response?.statusCode == 200) {
        final responseBody = jsonDecode(response!.body);
        return SendPictureResponse.fromJson(responseBody);
      } else if (response?.statusCode == 400) {
        throw Exception("Ocurrió un error con la consulta");
      } else if (response?.statusCode == 500) {
        throw Exception("Problemas en el servidor");
      } else {
        throw Exception("No funciona el servicio por el momento");
      }

      if (response?.statusCode == 200) {
        final responseBody = jsonDecode(response!.body);
        return SendPictureResponse.fromJson(responseBody);
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

  Future<ResumePicturesResponse> getResumenProducts(
      ResumePicturesParams params) async {
    var uri = Uri.http(Constants.apiIAUrl, '/ir/recimage');

    logService.writeLog(
        "API-MESSAGE", 'URL: ${uri} PARAMS: ${params.toJson()}');

    try {
      final http.Response response = await http.post(
        uri,
        headers: getHeadersWithToken(),
        body: jsonEncode({
          "idRealograma": params.idRealograma,
          "tramo": params.tramo,
          "usuario": params.usuario,
          "categoria": params.categoria,
          "fechaCap": _getCurrentFormattedDateTime(),
          "imagen": params.imagen
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return ResumePicturesResponse.fromJson(responseBody);
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

  Future<String> deleteTramo(int idReconocimiento, int tramo) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-deleteSegment/$idReconocimiento/$tramo');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} idReconocimiento: ${idReconocimiento} tramo: ${tramo} ');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        return response.body;
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

  Future<FurnitureSegmentResponse> getResumeTramo(
      int idReconocimiento, int tramo) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-segmentsummary/$idReconocimiento/$tramo/${Constants.enviroment}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} idReconocimiento: ${idReconocimiento} tramo: ${tramo} enviroment: ${Constants.enviroment} ');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        // Decodifica el cuerpo de la respuesta y crea una instancia de FixIssuesResponse
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return FurnitureSegmentResponse.fromMap(jsonResponse);
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

  Future<List<EventsResponse>> getReporteEventosTiendas(
      GetIssuesParams request) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/reporte-eventos-de-tienda/${request.idTienda}/${request.idCategoria}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} idTienda: ${request.idTienda} idCategoria: ${request.idCategoria}');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<EventsResponse> list = List<EventsResponse>.from(
            l.map((model) => EventsResponse.fromJson(model)));
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

  Future<List<UbicacionResponse>> getLocations() async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/obtener-ubicaciones-encontrado');

    logService.writeLog("API-MESSAGE", 'URL: ${uri}');

    try {
      final http.Response response =
          await http.post(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<UbicacionResponse> list = List<UbicacionResponse>.from(
            l.map((model) => UbicacionResponse.fromJson(model)));
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

  Future<EventDetail> getResumenIndicadores(GetIssuesParams request) async {
    print(
        "/${request.idTienda}/${request.evento}/${request.idCategoria}/${request.idBitacora}");

    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/reporte-promedio-indicadores/${request.idTienda}/${request.evento}/${request.idCategoria}/${request.idBitacora}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} idTienda: ${request.idTienda} idCategoria: ${request.idCategoria} evento: ${request.evento}  idBitacora: ${request.idBitacora}');

    print(uri);

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return EventDetail.fromJson(responseBody);
      } else {
        print("--- ERROR EN getResumenIndicadores ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getResumenIndicadores: $e");
      throw Exception("Error de conexión en getResumenIndicadores: $e");
    }
  }

  Future<String> getImagenByTramo(
      int idReconocimiento, int idRealograma, int tramo) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/analisis-image-tramo/$idReconocimiento/$idRealograma/$tramo');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} idReconocimiento: ${idReconocimiento} idRealograma: ${idRealograma} tramo: ${tramo}');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        return response.body;
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

  Future<List<LayoutFaltanteResponse>> getLayoutProductosFaltantes(
      LayoutFaltantesParams request) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/layout-faltantes/${request.idTienda}/${request.evento}/${request.idCategoria}/${request.idBitacora}/${request.upc}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} idTienda: ${request.idTienda} evento: ${request.evento} idCategoria: ${request.idCategoria} idBitacora: ${request.idBitacora} upc: ${request.upc}');

    print(
        '${request.idTienda} evento: ${request.evento} idCategoria: ${request.idCategoria} idBitacora: ${request.idBitacora} upc: ${request.upc}');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<LayoutFaltanteResponse> list = List<LayoutFaltanteResponse>.from(
            l.map((model) => LayoutFaltanteResponse.fromJson(model)));
        return list;
      } else {
        print("--- ERROR EN getLayoutProductosFaltantes ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getLayoutProductosFaltantes: $e");
      throw Exception("Error de conexión en getLayoutProductosFaltantes: $e");
    }
  }

  Future<List<FaltanteResponse>> getProductosFaltantes(
      GetIssuesParams request) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/faltantes/${request.idTienda}/${request.evento}/${request.idCategoria}/${request.idBitacora}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} idTienda: ${request.idTienda} evento: ${request.evento} idCategoria: ${request.idCategoria} idBitacora: ${request.idBitacora}');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<FaltanteResponse> list = List<FaltanteResponse>.from(
            l.map((model) => FaltanteResponse.fromJson(model)));
        return list;
      } else {
        print("--- ERROR EN getProductosFaltantes ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getProductosFaltantes: $e");
      throw Exception("Error de conexión en getProductosFaltantes: $e");
    }
  }

  Future<List<MueblesCategoriaResponse>> getMueblesCategoria(
      GetIssuesParams request, bool esSupercito) async {
    var uri = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/muebles-categoria/${request.idTienda}/${request.evento}/${request.idCategoria}/${request.idBitacora}',
      {
        'esSupercito': esSupercito.toString(), // Agregado como query param
      },
    );

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} idTienda: ${request.idTienda} evento: ${request.evento} idCategoria: ${request.idCategoria} idBitacora: ${request.idBitacora}');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<MueblesCategoriaResponse> list =
            List<MueblesCategoriaResponse>.from(
                l.map((model) => MueblesCategoriaResponse.fromJson(model)));
        return list;
      } else {
        print("--- ERROR EN getMueblesCategoria ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getMueblesCategoria: $e");
      throw Exception("Error de conexión en getMueblesCategoria: $e");
    }
  }

  Future<List<DetalleNivelResponse>> getDetalleNivel(
      DetalleNivelParams request, bool esSupercito) async {
    var uri = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/detalle-de-nivel/${request.idRealograma}/${request.tramo}/${request.nivel}',
      {
        'esSupercito': esSupercito.toString(), // Query param agregado
      },
    );

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} idRealograma: ${request.idRealograma} tramo: ${request.tramo} nivel: ${request.nivel} ');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<DetalleNivelResponse> list = List<DetalleNivelResponse>.from(
            l.map((model) => DetalleNivelResponse.fromJson(model)));
        return list;
      } else {
        print("--- ERROR EN getDetalleNivel ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getDetalleNivel: $e");
      throw Exception("Error de conexión en getDetalleNivel: $e");
    }
  }

  Future<List<TramosMuebleResponse>> getTramosMueble(
      int idReconocimiento, int idRealograma, bool esSupercito) async {
    var uri = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/tramos-de-mueble/$idReconocimiento/$idRealograma',
      {
        'esSupercito': esSupercito.toString(), // Agregado como query param
      },
    );

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} idReconocimiento: ${idReconocimiento} idRealograma: ${idRealograma}');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<TramosMuebleResponse> list = List<TramosMuebleResponse>.from(
            l.map((model) => TramosMuebleResponse.fromJson(model)));
        return list;
      } else {
        print("--- ERROR EN getTramosMueble ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getTramosMueble: $e");
      throw Exception("Error de conexión en getTramosMueble: $e");
    }
  }

  Future<DetalleNivelConImagen> getDetalleNivelConImagen(
      DetalleNivelParams request, bool esSupercito) async {
    // URL para obtener la imagen
    var uriImagen = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/analisis-image-tramo/${request.idReconocimiento}/${request.idRealograma}/${request.tramo}/${Constants.enviroment}',
      {
        'esSupercito': esSupercito.toString(), // Query param agregado
      },
    );

    // URL para obtener el detalle del nivel
    var uriDetalle = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/detalle-de-nivel/${request.idRealograma}/${request.tramo}/${request.nivel}',
      {
        'esSupercito': esSupercito.toString(), // Query param agregado
      },
    );

    logService.writeLog(
        "API-MESSAGE", 'URL: ${uriImagen} PARAMS: ${request.toJson()}');

    try {
      // Hacer las solicitudes simultáneamente
      final responses = await Future.wait([
        http.get(uriImagen, headers: getHeadersWithToken()),
        http.get(uriDetalle, headers: getHeadersWithToken()),
      ]);

      final responseImagen = responses[0];
      final responseDetalle = responses[1];

      if (responseImagen.statusCode == 200 &&
          responseDetalle.statusCode == 200) {
        // Procesar la imagen
        String imageUrl = responseImagen.body;

        // Procesar el detalle del nivel
        String decodedBody = utf8.decode(responseDetalle.bodyBytes);
        Iterable l = json.decode(decodedBody);
        List<DetalleNivelResponse> list = List<DetalleNivelResponse>.from(
            l.map((model) => DetalleNivelResponse.fromJson(model)));

        return DetalleNivelConImagen(
          imageUrl: imageUrl,
          detalleNivel: list,
        );
      } else {
        throw Exception(
            "Error en la solicitud: ${responseImagen.statusCode}, ${responseDetalle.statusCode}");
      }
    } catch (e) {
      throw Exception("Error al conectar con el servicio: $e");
    }
  }

  Future<CaptureResponse> capturarFaltante(
      CapturarFaltanteParams request) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/capturar-faltante/${request.idTienda}/${request.evento}/${request.categoria}/${request.sku}/${request.idBitacora}/${request.idUbicacion}');

    logService.writeLog(
        "API-MESSAGE", 'URL: ${uri} PARAMS: ${request.toJson()}');

    print("URL: $uri");

    try {
      final http.Response response =
          await http.post(uri, headers: getHeadersWithToken());
      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(decodedBody);
        return CaptureResponse.fromJson(responseBody);
      } else {
        print("--- ERROR EN capturarFaltante ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en capturarFaltante: $e");
      throw Exception("Error de conexión en capturarFaltante: $e");
    }
  }

  Future<String> getPdfByCategory(String categoria, int tienda) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-planograma-cat/$tienda/$categoria/${Constants.enviroment}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: tienda: ${tienda}, categoria: ${categoria} ${Constants.enviroment}');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        return response.body;
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

  // ** : Servicio para loguearnos
  Future<ConstantsEnviroment> getParams() async {
    var uri = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/get-constants-api',
    );

    final http.Response response = await http.post(
      uri,
      headers: Constants.headersPublic,
    );

    if (response.statusCode == 200) {
      return ConstantsEnviroment.fromJson(json.decode(response.body));
    }

    if (response.statusCode == 400) {
      return throw ("Nombre de usuario / contraseña incorrectos. Inténtalo de nuevo");
    }

    if (response.statusCode == 500) {
      return throw ("Problemas en el servidor");
    }

    return throw ("No funciona el servicio por el momento");
  }

  Future<List<TiendaLResponse>> getAvanceAuditoria(
      TiendaLRequest request) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-avance-auditoria/${request.idTienda}/${request.dia}');

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: tienda: ${request.idTienda}, dia: ${request.dia}');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<TiendaLResponse> list = List<TiendaLResponse>.from(
            l.map((model) => TiendaLResponse.fromJson(model)));
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

  // Llama a este método una sola vez, por ejemplo, al iniciar la app

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

  Future<MisplacedProductsResponse> getMisplacedProducts(
    int idBitacora, {
    required int idTienda,
    required int idEvento,
    required String categoria,
  }) async {
    print(getUser());

    var uri = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/reporte-mal-acomodados/${idBitacora}',
      {
        'idTienda': idTienda.toString(),
        'idEvento': idEvento.toString(),
        'categoria': categoria,
      },
    );

    logService.writeLog("API-MESSAGE",
        'URL: ${uri} PARAMS: idBitacora: ${idBitacora}, idTienda: $idTienda, idEvento: $idEvento, categoria: $categoria');

    print("URI completo: ${uri}");

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> jsonResponse = jsonDecode(decodedBody);
        return MisplacedProductsResponse.fromJson(jsonResponse);
      } else {
        print("--- ERROR EN getMisplacedProducts ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getMisplacedProducts: $e");
      throw Exception("Error de conexión en getMisplacedProducts: $e");
    }
  }

  Future<IncidenciasEtiquetasResponse> getLabelWithIncidents(
      int idBitacora) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/reporte-etiquetas-incidencias/${idBitacora}');

    logService.writeLog(
        "API-MESSAGE", 'URL: ${uri} PARAMS: idBitacora: ${idBitacora}');
    print('Request a --> $uri');

    try {
      final http.Response response =
          await http.get(uri, headers: getHeadersWithToken());

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> jsonResponse = jsonDecode(decodedBody);
        return IncidenciasEtiquetasResponse.fromJson(jsonResponse);
      } else {
        print("--- ERROR EN getLabelWithIncidents ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getLabelWithIncidents: $e");
      throw Exception("Error de conexión en getLabelWithIncidents: $e");
    }
  }

  Future<ConsultasResponse> getValidateCategories(
    ValidateCategories request,
  ) async {
    var uri = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/validate-categories',
    );

    logService.writeLog(
      "API-MESSAGE",
      'URL: ${uri} PARAMS: idRegistro: ${request.category}, upc: ${request.store}',
    );

    try {
      final http.Response response = await http.post(
        uri,
        headers: getHeadersWithToken(),
        body: jsonEncode({
          "tienda": request.store,
          "categoria": request.category,
          "upc": request.upc,
        }),
      );

      if (response.statusCode == 200) {
        // Decodifica el cuerpo de la respuesta y crea una instancia de FixIssuesResponse
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ConsultasResponse.fromJson(jsonResponse);
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

  Future<ValidateCerosResponse> getValidateCeros(ValidateCeros request) async {
    var uri = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/validate-ceros',
    );

    logService.writeLog(
      "API-MESSAGE",
      'URL: ${uri} PARAMS: idRegistro: ${request.category}, upc: ${request.idRealograma}',
    );

    try {
      final http.Response response = await http.post(
        uri,
        headers: getHeadersWithToken(),
        body: jsonEncode({
          "pidRealograma": request.idRealograma,
          "categoria": request.category,
          "tramo": request.tramo,
        }),
      );

      if (response.statusCode == 200) {
        // Decodifica el cuerpo de la respuesta y crea una instancia de FixIssuesResponse
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ValidateCerosResponse.fromJson(jsonResponse);
      } else {
        print("--- ERROR EN getValidateCeros ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getValidateCeros: $e");
      throw Exception("Error de conexión en getValidateCeros: $e");
    }
  }

  Future<ConsultasResponse> getValidateTramos(
    ValidaTramosRequest request,
  ) async {
    var uri = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/validate-tramos',
    );

    logService.writeLog(
      "API-MESSAGE",
      'URL: ${uri} PARAMS: idRegistro: ${request.categoria}, upc: ${request.idBitacora}',
    );

    try {
      final http.Response response = await http.post(
        uri,
        headers: getHeadersWithToken(),
        body: jsonEncode({
          "idBitacora": request.idBitacora,
          "categoria": request.categoria,
          "tienda": request.tienda,
        }),
      );

      if (response.statusCode == 200) {
        // Decodifica el cuerpo de la respuesta y crea una instancia de FixIssuesResponse
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ConsultasResponse.fromJson(jsonResponse);
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

  Future<List<PlanogramaItemResponse>> getProductPLN(
    int tienda,
    String upc,
  ) async {
    print('-- params: ${tienda}/ ${upc} -- Too large}');

    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/get-product-pln/${tienda}/${upc}');

    logService.writeLog(
      "API-MESSAGE",
      'URL: ${uri} tienda: ${tienda} upc: ${upc}',
    );

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);

        Iterable l = json.decode(decodedBody);
        List<PlanogramaItemResponse> list = List<PlanogramaItemResponse>.from(
          l.map((model) => PlanogramaItemResponse.fromJson(model)),
        );
        return list;
      } else {
        print("--- ERROR EN getProductPLN ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getProductPLN: $e");
      throw Exception("Error de conexión en getProductPLN: $e");
    }
  }

  Future<NuevosPlanogramasImplResponse> getImplementationOfPlanograms(
      int idTienda) async {
    var uri = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/categorias-implementasion-planogramas/${getUser()}/${idTienda}',
    );

    logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: ${getUser()}');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );
      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        final List<dynamic> categoriasJson = data["categorias"];

        final int caducados = data["caducados"];
        final int porImplementar = data["porImplemeentar"];
        final int implementados = data["implementados"];
        final List<ImplementationOfPlanogramsItemResponse> lista =
            categoriasJson
                .map((item) =>
                    ImplementationOfPlanogramsItemResponse.fromJson(item))
                .toList();

        return NuevosPlanogramasImplResponse(
          caducados: caducados,
          porImplementar: porImplementar,
          implementados: implementados,
          planogramas: lista,
        );
      } else {
        print("--- ERROR EN getImplementationOfPlanograms ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getImplementationOfPlanograms: $e");
      throw Exception("Error de conexión en getImplementationOfPlanograms: $e");
    }
  }

  Future<bool> setPlanogramaImplementado(int id, int idTienda) async {
    var uri = Uri.http(
      Constants.apiUrl,
      '/${Constants.path}/ri/set-implementacion-planograma/${id}/$idTienda',
    );

    logService.writeLog("API-MESSAGE", 'URL: ${uri} PARAMS: ${getUser()}');

    try {
      final http.Response response = await http.post(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        final bool resultado = data["resultado"];

        return resultado;
      } else {
        print("--- ERROR EN setPlanogramaImplementado ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en setPlanogramaImplementado: $e");
      throw Exception("Error de conexión en setPlanogramaImplementado: $e");
    }
  }

  Future<List<ProductoMalAcomodadoSecuencia>>
      getProductosMalAcomodadosSecuencia(int idBitacora) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/productos-mal-acomodados-secuencia/$idBitacora');

    logService.writeLog("API-MESSAGE", 'URL: $uri PARAMS: $idBitacora');

    print(uri);

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        Iterable l = json.decode(decodedBody);
        List<ProductoMalAcomodadoSecuencia> list =
            List<ProductoMalAcomodadoSecuencia>.from(l
                .map((model) => ProductoMalAcomodadoSecuencia.fromJson(model)));
        return list;
      } else {
        print("--- ERROR EN getProductosMalAcomodadosSecuencia ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getProductosMalAcomodadosSecuencia: $e");
      throw Exception(
          "Error de conexión al obtener productos mal acomodados por secuencia: $e");
    }
  }

  Future<List<ProductoSinHueco>> getProductosSinHuecos(int idBitacora) async {
    var uri = Uri.http(Constants.apiUrl,
        '/${Constants.path}/ri/productos-sin-huecos/$idBitacora');

    logService.writeLog("API-MESSAGE", 'URL: $uri PARAMS: $idBitacora');

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        Iterable l = json.decode(decodedBody);
        List<ProductoSinHueco> list = List<ProductoSinHueco>.from(
            l.map((model) => ProductoSinHueco.fromJson(model)));
        return list;
      } else {
        print("--- ERROR EN getProductosSinHuecos ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getProductosSinHuecos: $e");
      throw Exception("Error de conexión al obtener productos sin huecos: $e");
    }
  }

  Future<List<AdyacenciaErrorResponse>> getAdyacenciaError(
      int idBitacora) async {
    var uri = Uri.http(
        Constants.apiUrl, '/${Constants.path}/ri/adyacencia-error/$idBitacora');

    logService.writeLog("API-MESSAGE", 'URL: $uri PARAMS: $idBitacora');

    print(uri);

    try {
      final http.Response response = await http.get(
        uri,
        headers: getHeadersWithToken(),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        Iterable l = json.decode(decodedBody);
        List<AdyacenciaErrorResponse> list = List<AdyacenciaErrorResponse>.from(
            l.map((model) => AdyacenciaErrorResponse.fromJson(model)));
        return list;
      } else {
        print("--- ERROR EN getAdyacenciaError ---");
        print("URL: $uri");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("-------------------------------");
        throw Exception(
            "Error del servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Excepción en getAdyacenciaError: $e");
      throw Exception("Error de conexión al obtener adyacencia con error: $e");
    }
  }
}
