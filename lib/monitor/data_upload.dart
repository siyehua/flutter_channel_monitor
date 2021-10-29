import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'utils.dart';
import 'bean.dart';

/// cache channel data or upload
class DataManager {
  static const TAG = "channel_DataManager";
  static const CACHE_DIR_NAME = "channel_monitor";
  static const CACHE_FILE_NAME = "cache_file_name";
  static const SHOULD_UPLOAD_KEY = "should_upload";

  /// max file size
  static const maxSize = 1024 * 50;

  static final DataManager instance = DataManager._();

  String _savePath = "";
  UploadData? uploadData;

  DataManager._();

  Future add(String channelMonitorInfo) async {
    if (channelMonitorInfo.isEmpty) {
      return;
    }
    if (_savePath.isEmpty) {
      final directory = await getApplicationDocumentsDirectory();
      _savePath = directory.path;
    }
    if (logPrint) {
      print("$TAG $channelMonitorInfo");
    }
    String filePathStr =
        _savePath + "/" + CACHE_DIR_NAME + "/" + CACHE_FILE_NAME;
    File saveFile = File(filePathStr);
    if (!saveFile.existsSync()) {
      saveFile.parent.createSync();
      saveFile.createSync();
    }
    try {
      saveFile.writeAsStringSync(channelMonitorInfo + "\n",
          mode: FileMode.append);
      int fileSize = saveFile.statSync().size;
      if (fileSize >= maxSize) {
        String newPath = _savePath +
            "/" +
            CACHE_DIR_NAME +
            "/" +
            SHOULD_UPLOAD_KEY +
            "_" +
            DateTime.now().millisecondsSinceEpoch.toString();
        if (logPrint) {
          print("$TAG file size > limit size:$maxSize rename: $newPath");
        }
        saveFile.renameSync(newPath);
        _tryUpload();
      }
    } catch (e) {
      print(e);
    }
  }

  void _tryUpload() async {
    if (uploadData == null) {
      if (logPrint) {
        print("$TAG not uploadData, so return");
      }
      return;
    }
    String dirPath = _savePath + "/" + CACHE_DIR_NAME;
    Directory dataDir = Directory(dirPath);
    if (!dataDir.existsSync()) {
      return;
    }
    dataDir.listSync().where((element) {
      return element.path.split("/").last.contains(SHOULD_UPLOAD_KEY);
    }).forEach((file) async {
      if (logPrint) {
        print("upload data: $file");
      }
      var uploadResult = uploadData?.call(file.path) ?? false;
      if (uploadResult) {
        if (logPrint) {
          print("upload data success: $file");
        }
        try {
          file.deleteSync();
        } catch (e) {
          print(e);
        }
      }
    });
  }

  Future<List<String>> readSaveChannel() async {
    List<String> result = [];
    String dirPath = _savePath + "/" + CACHE_DIR_NAME;
    Directory dataDir = Directory(dirPath);
    if (!dataDir.existsSync()) {
      return result;
    }
    dataDir
        .listSync()
        .where((element) {
          return element.path.split("/").last.contains(SHOULD_UPLOAD_KEY) &&
              element is File;
        })
        .map((e) => e as File)
        .forEach((file) async {
          result.addAll(file.readAsLinesSync());
        });
    return result;
  }
}
