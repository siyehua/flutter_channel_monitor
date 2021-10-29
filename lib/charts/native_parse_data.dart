import 'dart:async';
import 'dart:math';
import '../monitor/data_upload.dart';
import '../monitor/utils.dart';
import '../monitor/bean.dart';

Future<List<String>> getChannelData() async {
  if (useTestData) {
    return _getTestData();
  } else {
    return _readCurrentAppChannelInfo();
  }
}

Future<List<String>> _readCurrentAppChannelInfo() async {
  return DataManager.instance.readSaveChannel();
}

Future<List<String>> _getTestData() async {
  List<String> result = [];
  for (int j = 0; j < 30; j++) {
    //7天内的数据
    for (int i = 0; i < 20; i++) {
      //这里表示当天有多少个统计点上报
      result.add((BinaryChannelObserver()
            ..channelName = "com.base.channel.xxx"
            ..platform = "ios"
            ..startTime = DateTime.now().millisecondsSinceEpoch -
                j * 24 * 60 * 60 * 1000 +
                Random().nextInt(i * 10 + 1)
            ..endTime = DateTime.now().millisecondsSinceEpoch -
                j * 24 * 60 * 60 * 1000 +
                Random().nextInt(i * 10 + 1) +
                Random().nextInt(500 * (i + 1)))
          .toString());

      result.add((MethodChannelObserver()
            ..channelName = "siyehua"
            ..methodName = "login"
            ..startTime = DateTime.now().millisecondsSinceEpoch -
                j * 24 * 60 * 60 * 1000 +
                Random().nextInt(i * 10 + 1)
            ..endTime = DateTime.now().millisecondsSinceEpoch -
                j * 24 * 60 * 60 * 1000 +
                Random().nextInt(i * 10 + 1) +
                Random().nextInt(200 * (i + 1)))
          .toString());

      result.add((MethodChannelObserver()
            ..channelName = "siyehua"
            ..methodName = "getAccountInfo"
            ..startTime = DateTime.now().millisecondsSinceEpoch -
                j * 24 * 60 * 60 * 1000 +
                Random().nextInt(i * 10 + 1)
            ..endTime = DateTime.now().millisecondsSinceEpoch -
                j * 24 * 60 * 60 * 1000 +
                Random().nextInt(i * 10 + 1) +
                Random().nextInt(50 * (i + 1)))
          .toString());
      result.add((MethodChannelObserver()
            ..channelName = "com.abc.xxx"
            ..methodName = "test"
            ..startTime = DateTime.now().millisecondsSinceEpoch -
                j * 24 * 60 * 60 * 1000 +
                Random().nextInt(i * 10 + 1)
            ..endTime = DateTime.now().millisecondsSinceEpoch -
                j * 24 * 60 * 60 * 1000 +
                Random().nextInt(i * 10 + 1) +
                Random().nextInt(200 * (i + 1)))
          .toString());
    }
  }
  return result;
}
