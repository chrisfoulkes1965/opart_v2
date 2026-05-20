import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class PrintFlowLog {
  PrintFlowLog._();

  static const String _name = 'PrintFlow';

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _name,
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint('[$_name] ERROR: $message${error != null ? ' | $error' : ''}');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  static void info(String message) {
    developer.log(message, name: _name);
    debugPrint('[$_name] $message');
  }
}
