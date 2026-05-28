import 'package:ansicolor/ansicolor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  AnsiPen penBlue = AnsiPen()..blue(bold: true);
  AnsiPen penRed = AnsiPen()..red(bold: true);
  AnsiPen penGreen = AnsiPen()..green(bold: true);

  // final LogRepository _repositoryLog = LogRepository();

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print(penRed('onCreate -- ${bloc.runtimeType}'));
    
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print(penBlue('onChange -- ${bloc.runtimeType}, $change'));
    
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print(penRed('onError -- ${bloc.runtimeType}, $error'));
    

    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    
    print('onClose -- ${bloc.runtimeType}');
  }
}
