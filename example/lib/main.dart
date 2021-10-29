import 'dart:io';

import 'package:channel_monitor/charts/base_page.dart';
import 'package:channel_monitor/charts/channel_data.dart';
import 'package:channel_monitor/monitor/channel_monitor.dart';
import 'package:channel_monitor/monitor/custom_flutter_binding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // ChannelMonitorManager.instance
  //   ..timeOut = 10 //set monitor time out seconds, default is 5
  //   ..log = true // default is false
  //   ..testData =
  //       false // use test data in Android or iOS, default is false : user your current project data
  //   ..addIgnoreChannelList("ignorechannle")//add ignore channel name, default is  "flutter/platform", "flutter/navigation"
  //   ..dataUpload = (path) {
  //     //the channel profiler will save in app's private dir.
  //     //it will callback will the data > 10K
  //     //you can upload data to your service and parse it.
  //
  //     File file = File(path);
  //     //todo upload content to your service
  //     print("channel data, file: $path \n content: ${file.readAsStringSync()}");
  //
  //     //if return true, the data will be delete.
  //     return true;
  //   };
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
