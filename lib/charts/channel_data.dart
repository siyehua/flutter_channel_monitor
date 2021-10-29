import 'dart:async';
import 'dart:convert';
import 'dart:html' as webHtml;
import 'dart:math';

import 'package:channel_monitor/monitor/data_upload.dart';
import 'package:flutter/foundation.dart';

import '../monitor/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'base_chanel_data.dart';
import '../monitor/bean.dart';
import 'base_page.dart';
import 'method_data.dart';
import 'stack_data.dart';

class ChannelDataManager with BaseChannelData {
  static final ChannelDataManager instance = ChannelDataManager._();

  ChannelDataManager._();

  void dumpToChannelInfo(
      BuildContext context, int index, void Function() back) {
    String targetChanelName = listViewDataList[index].name;

    final channelInfoDataMap = <String, Map<String, List<ChannelItemInfo>>>{};

    int type = 0;

    allDataMap.forEach((dayStr, channelMap) {
      var singleDayMap = <String, List<ChannelItemInfo>>{};

      //某天，指定的渠道， 所有数据
      var allMethod = channelMap[targetChanelName];
      if (allMethod?.first.type == 1) {
        type = 1;
        //base channel
        allMethod?.forEach((element) {
          List<ChannelItemInfo> item = [];
          if (singleDayMap.containsKey(element.invokeStackStr)) {
            item = singleDayMap[element.invokeStackStr]!;
          } else {
            singleDayMap[element.invokeStackStr] = item;
          }
          item.add(element);
        });
      } else {
        allMethod?.forEach((element) {
          List<ChannelItemInfo> item = [];
          if (singleDayMap.containsKey(element.methodName)) {
            item = singleDayMap[element.methodName]!;
          } else {
            singleDayMap[element.methodName] = item;
          }
          item.add(element);
        });
      }
      channelInfoDataMap[dayStr] = singleDayMap;
    });
    // print("method $channelInfoDataMap");

    BaseChannelData dataManager =
        MethodDataManager(targetChanelName, channelInfoDataMap);
    if (type == 1) {
      dataManager = StackDataManager(targetChanelName, channelInfoDataMap);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => BasePage(dataManager)),
    ).then((value) {
      back();
    });
  }

  @override
  Future<void> startGetData()async {
   await _parseData();
  }

  @override
  String getTitle() {
    return "平台: ${getPlatformName()}";
  }

  @override
  String getListTitleDesc() {
    return "渠道";
  }

  Future<void> _parseData() async {
    resetAllData();

    List<String> dbData;
    if (kIsWeb) {
      dbData = await _readFileFromPC();
    } else {
      dbData = await _readCurrentAppChannelInfo();
    }
    dbData.forEach((element) {
      element = element.trim().replaceAll("\n", "");
      if (element.startsWith("MethodChannelObserver")) {
        //method channel
        element = element.replaceFirst("MethodChannelObserver", "");
        _channelData(element, 0);
      } else if (element.isNotEmpty) {
        //base channel
        element = element.replaceFirst("ChannelObserver", "");
        _channelData(element, 1);
      }
    });

    parseData(allDataMap, allLineShowList, lineShowList, singleItemSumCostMap,
        singleItemShowMap, listViewDataList);
  }

  /// read file data from your computer
  Future<List<String>> _readFileFromPC() async {
    Completer<List<String>> completer = Completer();
    List<String> result = [];

    webHtml.FileUploadInputElement uploadInput =
        webHtml.FileUploadInputElement()..multiple = true;
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      var allFiles = uploadInput.files ?? [];
      allFiles.asMap().forEach((index, file) {
        final reader = new webHtml.FileReader();
        reader.onLoadEnd.listen((e) {
          result.addAll(reader.result.toString().split("\n"));
          if (index == allFiles.length - 1) {
            print("web onLoadEnd: $result ");
            completer.complete(result);
          }
        });
        reader.readAsText(file);
      });
    });
    return completer.future;
  }

  Future<List<String>> _readCurrentAppChannelInfo() async {
    return DataManager.instance.readSaveChannel();
  }

  void _channelData(String element, int type) {
    dynamic result = jsonDecode(element);
    String dateStr = DateFormat("yyyy-MM-dd")
        .format(DateTime.fromMillisecondsSinceEpoch(result["startTime"]));
    Map<String, List<ChannelItemInfo>> currentDateData = {};
    if (allDataMap.containsKey(dateStr)) {
      currentDateData = allDataMap[dateStr]!;
    } else {
      allDataMap[dateStr] = currentDateData;
    }
    String channelName = result["channelName"];
    List<ChannelItemInfo> dataList = [];
    if (currentDateData.containsKey(channelName)) {
      dataList = currentDateData[channelName]!;
    } else {
      currentDateData[channelName] = dataList;
    }
    dataList.add(
      ChannelItemInfo(
        type,
        channelName,
        result["platform"],
        result["cost"],
        invokeStackStr: result["invokeStack"] ?? "",
        methodName: type == 0 ? result["methodName"] : "",
      ),
    );
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
              ..channelName = "com.tencent.xxx"
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
}
