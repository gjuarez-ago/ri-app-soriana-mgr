import 'package:ago_app/bloc/auth/login_event.dart';
import 'package:ago_app/bloc/auth/login_state.dart';
import 'package:ago_app/models/login_response.dart';
import 'package:ago_app/repository/auth_repository.dart';
import 'package:ago_app/repository/log_repository.dart';
import 'package:bloc/bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final _repositoryAuth = AuthRepository();
  final _repositoryLog = LogRepository();

  LoginBloc() : super(InitialLoginState()) {

    on<EventAuth>((event, emit) async {
      emit(IsLoadingAuth());
      try {
        LoginResponse response = await _repositoryAuth.login(
            user: event.user, password: event.password);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params:${event.user}--${response}',
        );
        emit(SuccessAuth(response: response));
      } catch (e) {
        // _repositoryLog.writeLog(
        //   'ERROR',
        //   '${event}--params:${event.user}--${e.toString()}',
        // );
        emit(ErrorAuth(errorMessage: e.toString()));
      }
    });
  }
}
