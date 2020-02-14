import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A [SecureStorageAdapter] knows how to retrieve and store a value associated
/// with a key by using [FlutterSecureStorage].
class SecureStorageAdapter<T> {
  const SecureStorageAdapter();

  /// Retrieve a value associated with the [key] by using the [preferences].
  Future<String> getValue(
          FlutterSecureStorage flutterSecureStorage, String key) =>
      flutterSecureStorage.read(key: key);

  /// Set a [value] for the [key] by using the [preferences].
  ///
  /// Returns true if value was successfully set, otherwise false.
  Future<bool> setValue(FlutterSecureStorage flutterSecureStorage, String key,
          String value) =>
      flutterSecureStorage.write(key: key, value: value);
}