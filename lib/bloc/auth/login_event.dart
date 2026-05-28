import 'package:flutter/material.dart';

@immutable
abstract class LoginEvent {
  final String user;
  final String password;

  const LoginEvent({required this.user, required this.password});
}

class EventAuth extends LoginEvent {
  const EventAuth({
    required String user,
    required String password,
  }) : super(user: user, password: password);
}