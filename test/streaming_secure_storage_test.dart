import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streaming_secure_storage/streaming_secure_storage.dart';

void main() {
  const MethodChannel channel = MethodChannel('streaming_secure_storage');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await StreamingSecureStorage.platformVersion, '42');
  });
}
