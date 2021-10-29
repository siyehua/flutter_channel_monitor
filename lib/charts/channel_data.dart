import 'dart:async';
import 'dart:convert';

import '../monitor/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'base_chanel_data.dart';
import 'base_page.dart';
import 'method_data.dart';
import 'native_parse_data.dart' if (kIsWeb) 'web_parse_data.dart' as parse;
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
  Future<void> startGetData() async {
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
    dbData = await parse.getChannelData();
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
}
