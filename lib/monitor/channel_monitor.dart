import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'bean.dart';
import 'data_upload.dart';
import 'utils.dart';

class ChannelMonitorManager {
  static final ChannelMonitorManager instance = ChannelMonitorManager._();

  ChannelMonitorManager._();

  final DataManager _dataManager = DataManager.instance;

  final Map<ChannelMonitor, WaitTimeOuter> _channelList = {};
  final List<String> _channelIgnores = [
    "flutter/platform",
    "flutter/navigation",
    // "plugins.flutter.io/path_provider",
  ];

  /// uploadData
  set dataUpload(UploadData uploadData) {
    _dataManager.uploadData = uploadData;
  }

  /// set monitor time out seconds
  int timeOut = 5;

  /// print log, default  is true
  set log(bool print) {
    logPrint = print;
  }

  /// use test data in Android or iOS
  set testData(bool test) {
    useTestData = test;
  }

  /// if you want to ignore some
  void addIgnoreChannelList(String channelName) {
    if (_channelList.containsKey(channelName)) {
      return;
    }
    _channelIgnores.add(channelName);
  }

  /// start monitor channel send, if channel in [_channelIgnores], return null
  ChannelMonitor? start(String channel, ByteData? message) {
    if (_channelIgnores.contains(channel)) {
      //ignore
      return null;
    }
    ChannelMonitor channelMonitor = ChannelMonitor();
    final WaitTimeOuter waitTimeOuter = WaitTimeOuter();
    waitTimeOuter.timeOut = timeOut;
    waitTimeOuter.timeOutListener(() {
      end(channelMonitor,
          "time out, more than ${waitTimeOuter.timeOut}seconds no reply!");
    });
    channelMonitor._start(channel, message);
    _channelList[channelMonitor] = waitTimeOuter;
    return channelMonitor;
  }

  /// end monitor channel send
  void end(ChannelMonitor channelMonitor,
      [Object? exception, StackTrace? errorStackTrace]) {
    var info = channelMonitor._end(exception, errorStackTrace);
    _channelList.remove(channelMonitor);
    _dataManager.add(info);
  }
}

/// channel monitor
class ChannelMonitor {
  int _pointer = 0;

  ChannelMonitor() {
    _pointer = Random().nextInt(999999999);
  }

  ChannelObserver? _observer;

  void _start(String channel, ByteData? message) {
    try {
      StandardMethodCodec methodCodec = StandardMethodCodec();
      MethodCall methodCall = methodCodec.decodeMethodCall(message);
      MethodChannelObserver methodObserver = MethodChannelObserver();
      methodObserver.methodName = methodCall.method;
      methodObserver.arguments = methodCall.arguments;
      _observer = methodObserver;
    } catch (e) {
      _observer = BinaryChannelObserver();
    }
    _observer?.channelName = channel;
    _observer?.startTime = DateTime.now().millisecondsSinceEpoch;
  }

  String _end([Object? exception, StackTrace? errorStackTrace]) {
    _observer?.endTime = DateTime.now().millisecondsSinceEpoch;
    _observer?.exception = exception;
    if (errorStackTrace != null) {
      _observer?.errorStackTrace = getStackStr(errorStackTrace);
    }
    String result = _observer?.toString() ?? "";
    _observer = null;
    return result;
  }

  @override
  String toString() {
    return "$_pointer $_observer";
  }
}
