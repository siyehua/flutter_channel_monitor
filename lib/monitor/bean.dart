import 'utils.dart';

/// binary channel observer
class BinaryChannelObserver extends ChannelObserver {}

/// method channel observer
class MethodChannelObserver extends ChannelObserver {
  /// method name
  String methodName = "";
  Object? arguments;

  @override
  String toString() {
    return 'MethodChannelObserver{'
        '"channelName": "$channelName", '
        '"platform": "$platform", '
        '"cost":${endTime - startTime}, '
        '"startTime": $startTime, '
        '"endTime": $endTime, '
        '"methodName": "$methodName", '
        '"arguments": "$arguments", '
        '"invokeStack": "$invokeStack", '
        '"errorStackTrace": "$errorStackTrace", '
        '"exception": "$exception"'
        '}';
  }
}

/// observer
abstract class ChannelObserver {
  int startTime = 0;
  int endTime = 0;

  /// channel name
  String channelName = "";

  ///平台
  String platform = getPlatformName();

  /// invoke stack
  String invokeStack = getStackStr(StackTrace.current);

  /// error stack
  String errorStackTrace = "";

  /// exception
  Object? exception;

  @override
  String toString() {
    return 'ChannelObserver{'
        '"channelName": "$channelName",'
        '"platform": "$platform",'
        '"cost":${endTime - startTime}, '
        '"startTime": $startTime, '
        '"endTime": $endTime, '
        '"invokeStack": "$invokeStack", '
        '"errorStackTrace": "$errorStackTrace", '
        '"exception": "$exception"'
        '}';
  }
}

/// upload channel data
typedef UploadData = bool Function(String dataPaht);

