import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'base_chanel_data.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'base_page.dart';
import 'stack_data.dart';

/// 某个渠道的所有方法数据管理
class MethodDataManager with BaseChannelData {
  final String channelName;

  MethodDataManager(
      this.channelName, Map<String, Map<String, List<ChannelItemInfo>>> data) {
    this.allDataMap.clear();
    this.allDataMap.addAll(data);
  }

  void dumpToStackInfo(BuildContext context, int index) {
    String targetMethodName = listViewDataList[index].name;

    final stackDataMap = <String, Map<String, List<ChannelItemInfo>>>{};

    allDataMap.forEach((dayStr, channelMap) {
      var stackMap = <String, List<ChannelItemInfo>>{};
      var allMethod = channelMap[targetMethodName];
      allMethod?.forEach((element) {
        List<ChannelItemInfo> item = [];
        if (stackMap.containsKey(element.invokeStackStr)) {
          item = stackMap[element.invokeStackStr]!;
        } else {
          stackMap[element.invokeStackStr] = item;
        }
        item.add(element);
      });
      stackDataMap[dayStr] = stackMap;
    });
    // print("stack $stackDataMap");

    StackDataManager dataManager =
        StackDataManager(targetMethodName, stackDataMap);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => BasePage(dataManager)),
    );
  }

  @override
  Future<void> startGetData() async {
    resetAllData(true);
    parseData(allDataMap, allLineShowList, lineShowList, singleItemSumCostMap,
        singleItemShowMap, listViewDataList);
  }

  @override
  String getTitle() {
    return "channelName: $channelName";
  }

  @override
  String getListTitleDesc() {
    return "方法";
  }
}
