import 'package:ago_app/models/login_response.dart';
import 'package:flutter/material.dart';

@immutable
abstract class LoginState {
  final String? messageError;
  final LoginResponse? response;

  const LoginState({this.messageError, this.response});
}

class InitialLoginState extends LoginState {}

class IsLoadingAuth extends LoginState {}

class ErrorAuth extends LoginState {
  const ErrorAuth({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessAuth extends LoginState {
  const SuccessAuth({required LoginResponse response})
      : super(response: response);
}