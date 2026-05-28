

import 'package:flutter/material.dart';

@immutable
abstract class LogState {
  final String? messageError;
  final String? response;

  const LogState({this.messageError, this.response});
}

class InitialLogState extends LogState {}

class IsLoadingWriteLog extends LogState {}

class ErrorWriteLog extends LogState {
  const ErrorWriteLog({required String messageError})
      : super(messageError: messageError);
}

class SuccesWriteLog extends LogState {
  const SuccesWriteLog({required String response})
      : super(response: response);
}