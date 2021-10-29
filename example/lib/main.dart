import 'package:channel_monitor/charts/base_page.dart';
import 'package:channel_monitor/charts/channel_data.dart';
import 'package:channel_monitor/monitor/custom_flutter_binding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // ChannelMonitorManager.instance.dataUpload = (path) {
  //   File file = File(path);
  //   print("channel data, file: $path \n content: ${file.readAsStringSync()}");
  //   return true;
  // };
  if (!kIsWeb) {
    CustomFlutterBinding(); //这一句必须放init最前面，
    _setHandler();
  }
  runApp(MyApp());
}

void _setHandler() {
  methodChannel.setMethodCallHandler((call) async {});
}

MethodChannel methodChannel = MethodChannel("siyehua");

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    testInvokeMethod();
    return BasePage(ChannelDataManager.instance);
  }
}

void testInvokeMethod() async {
  if (!kIsWeb) {
    Future.delayed(Duration(seconds: 5), () {
      methodChannel.invokeMethod("login");
    });
    Future.delayed(Duration(seconds: 3), () {
      methodChannel.invokeMethod("abc");
    });
  }
}
