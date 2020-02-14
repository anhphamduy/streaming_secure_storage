import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StreamingSecureStorage {
  static Completer<StreamingSecureStorage> _instanceCompleter;

  static FlutterSecureStorage _secureStorage;
  static StreamController<String> _keyChanges;

  /// Obtain an instance to [StreamingSecureStorage].
  static Future<StreamingSecureStorage> get instance async {
    if (_instanceCompleter == null) {
      _instanceCompleter = Completer();
    }

    return _instanceCompleter.future;
  }
}
