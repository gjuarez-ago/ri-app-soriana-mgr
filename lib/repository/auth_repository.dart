
import 'package:ago_app/models/login_response.dart';
import 'package:ago_app/services/auth_service.dart';

class AuthRepository {
  
  AuthService service = AuthService();

  Future<LoginResponse> login(
          {required String user, required String password}) =>
      service.login(user, password);

}