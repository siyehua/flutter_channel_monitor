import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:channel_monitor/monitor/channel_monitor.dart';

void main() {
  const MethodChannel channel = MethodChannel('channel_monitor');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
