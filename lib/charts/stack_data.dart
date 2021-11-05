import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'base_channel_data.dart';

/// 某个渠道的所有方法数据管理
class StackDataManager with BaseChannelData {
  /// 方法或 basic 的堆栈
  final String name;

  StackDataManager(
      this.name, Map<String, Map<String, List<ChannelItemInfo>>> data) {
    this.allDataMap.clear();
    this.allDataMap.addAll(data);
  }

  @override
  Future<void> startGetData() async {
    resetAllData(true);
    parseData(allDataMap, allLineShowList, lineShowList, singleItemSumCostMap,
        singleItemShowMap, listViewDataList);
  }

  void showStackDetails(BuildContext showContext, int index) {
    String stack = listViewDataList[index].name;
    var allStr = stack.replaceAll("\\n", "\n");
    showDialog(
        context: showContext,
        builder: (context) {
          return Center(
            child: Container(
              color: Colors.white,
              child: Container(
                color: getLineBgColor(index),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: allStr,
                                ),
                              );
                              ScaffoldMessenger.of(showContext).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.blue,
                                  duration: Duration(
                                    seconds: 1,
                                  ),
                                  content: Text(
                                    "复制成功",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 10,
                                bottom: 10,
                              ),
                              color: Colors.blue,
                              child: Text(
                                "复制",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 10,
                                bottom: 10,
                              ),
                              color: Colors.blueGrey,
                              child: Text(
                                "关闭",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: kIsWeb ? null : 300,
                        child: SingleChildScrollView(
                          child: Text(
                            allStr,
                            // maxLines: 10,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  String getTitle() {
    return "name: $name";
  }

  @override
  String getListTitleDesc() {
    return "堆栈";
  }

  @override
  String getListViewItemDesc(int index) {
    String desc = super.getListViewItemDesc(index);
    var allStr = desc.replaceAll("\\n", "\n").split("\n");
    return allStr
        .sublist(3, 10)
        .reduce((value, element) => value + "\n" + element);
  }

  @override
  int getListViewItemHeight() {
    return super.getListViewItemHeight() * 4;
  }
}
