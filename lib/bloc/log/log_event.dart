import 'package:flutter/material.dart';

@immutable
abstract class LogEvent {
  final String level;
  final String message;

  const LogEvent({required this.level, required this.message});
}

class EventWriteLog extends LogEvent {
  const EventWriteLog({
    required String level,
    required String message,
  }) : super(level: level, message: message);
}
