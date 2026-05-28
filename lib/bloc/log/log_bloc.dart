import 'package:ago_app/bloc/log/bloc.dart';
import 'package:ago_app/repository/log_repository.dart';
import 'package:bloc/bloc.dart';

class LogBloc extends Bloc<LogEvent, LogState> {
  final _repository = LogRepository();

  LogBloc() : super(InitialLogState()) {
    on<EventWriteLog>((event, emit) async {
      emit(IsLoadingWriteLog());
      try {
        String response = await _repository.writeLog(event.level, event.message);
        emit(SuccesWriteLog(response: response));
      } catch (e) {
        emit(ErrorWriteLog(messageError: e.toString()));
      }
    });
  }
}
