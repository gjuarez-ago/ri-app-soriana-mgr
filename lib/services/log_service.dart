import 'dart:convert';
import 'package:ago_app/services/api_helper.dart';
import 'package:ago_app/utils/constants.dart';
import 'package:http/http.dart' as http;

class LogService {
  Future<String> writeLog(String level, String message) async {
    var uri = ApiHelper.buildUri(Constants.apiUrl, '/${Constants.path}/api/logs');

    try {
      final http.Response response = await http.post(
        uri,
        headers: getHeadersWithToken(),
        body: jsonEncode(
            {"level": level, "message": '${message}', "timestamp": _getCurrentFormattedDateTime()}),
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

  // Ahora puedes obtener los encabezados de forma síncrona
  Map<String, String> getHeadersWithToken() {
    String token = Constants.token;

    return {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    };
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
