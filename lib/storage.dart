import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'adapter.dart';

/// A [SecureStorage] is a single value associated with a key, which is persisted
/// using [FlutterSecureStorage].
///
/// It is also a special type of [Stream] that emits a new value whenever the
/// value associated with [key] changes. You can use a [SecureStorage] like you would
/// use any regular [Stream].
///
/// Whenever the backing value associated with [key] transitions from non-null to
/// null, it emits [defaultValue]. The [defaultValue] is also emitted if the value
/// is null when initially listening to the stream.
class SecureStorage<T> extends StreamView<T> {
  /// Only exposed for internal purposes. Do not call directly.
  @visibleForTesting
  SecureStorage.$$_private()
      : super(
          _keyChanges.stream.transform(_EmitValueChanges(
              _key, _defaultValue, _adapter, flutterSecureStorage)),
        );

  static SecureStorageAdapter _adapter;
  static StreamController<String> _keyChanges;
  static FlutterSecureStorage flutterSecureStorage;
  static String _defaultValue;
  static String _key;
}

/// A [StreamTransformer] that starts with the current persisted value and emits
/// a new one whenever the [key] has update events.
class _EmitValueChanges<T> extends StreamTransformerBase<String, T> {
  _EmitValueChanges(
    this.key,
    this.defaultValue,
    this.adapter,
    this.flutterSecureStorage,
  );

  final String key;
  final String defaultValue;
  final SecureStorageAdapter<T> adapter;
  final FlutterSecureStorage flutterSecureStorage;

  T _getValueFromPersistentStorage() {
    // Return the latest value from preferences,
    // If null, returns the default value.
    return adapter.getValue(flutterSecureStorage, key) ?? defaultValue;
  }

  @override
  Stream<T> bind(Stream<String> stream) {
    return StreamTransformer<String, T>((input, cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
        sync: true,
        onListen: () {
          // When the stream is listened to, start with the current persisted
          // value.
          final value = _getValueFromPersistentStorage();
          controller.add(value);

          // Cache the last value. Caching is specific for each listener, so the
          // cached value exists inside the onListen() callback for a reason.
          T lastValue = value;

          // Whenever a key has been updated, fetch the current persisted value
          // and emit it.
          subscription = input
              .transform(_EmitOnlyMatchingKeys(key))
              .map((_) => _getValueFromPersistentStorage())
              .listen(
            (value) {
              if (value != lastValue) {
                controller.add(value);
                lastValue = value;
              }
            },
            onDone: () => controller.close(),
          );
        },
        onPause: ([resumeSignal]) => subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel(),
      );

      return controller.stream.listen(null);
    }).bind(stream);
  }
}

/// A [StreamTransformer] that filters out values that don't match the [key].
///
/// One exception is when the [key] is null - in this case, returns the source
/// stream as is. One such case would be calling the `getKeys()` method on the
/// `StreamingSharedPreferences`, as in that case there's no specific [key].
class _EmitOnlyMatchingKeys extends StreamTransformerBase<String, String> {
  _EmitOnlyMatchingKeys(this.key);
  final String key;

  @override
  Stream<String> bind(Stream<String> stream) {
    if (key != null) {
      // If key is non-null, emit only the changes that match the key.
      // Otherwise, emit all changes.
      return stream.where((changedKey) => changedKey == key);
    }

    return stream;
  }
}
