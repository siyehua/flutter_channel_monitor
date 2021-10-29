import 'dart:io';

import 'package:flutter/foundation.dart';

/// The call wait until the time out
class WaitTimeOuter {
  int timeOut = 10;

  Future timeOutListener(void Function() call) {
    return Future.delayed(Duration(seconds: timeOut), () {
      call();
    });
  }
}

///打印日志
bool logPrint = true;


/// 获取当前平台的名字
String getPlatformName() {
  if (kIsWeb) {
    return "web";
  }
  try {
    return Platform.operatingSystem;
  } catch (e) {
    return "error";
  }
}

/// 获取堆栈 Str
String getStackStr(StackTrace stackTrace) {
  String stack = stackTrace.toString();
  // print("stack $stack");
  return stack.replaceAll("\n", "\\n");
}
