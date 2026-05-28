import 'package:ago_app/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<BlocProvider> blocsServices(String token) {
  return [
    BlocProvider<RIBloc>(
      create: (context) => RIBloc(),
    ),
    BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(),
    ),  BlocProvider<LogBloc>(
      create: (context) => LogBloc(),
    )
  ];
}
