import 'package:ago_app/services/log_service.dart';

class LogRepository {
  LogService service = LogService();

  Future<String> writeLog(String level, String message) =>
      service.writeLog(level, message);
      
}
