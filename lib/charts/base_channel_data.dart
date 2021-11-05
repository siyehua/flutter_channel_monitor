import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

final platForms = ["全平台"];
String currentPlatForms = "全平台";

///是否倒序，默认是倒序的
bool desc = true;

/// 基础数据处理类
/// 当前包括三种类型 1. 渠道， 2: 方法， 3:堆栈
abstract class BaseChannelData {
  ///所有数据
  ///1. 渠道格式: 日期 → 渠道 → 每日的渠道信息
  ///2. 方法格式: 日期 → 方法 → 每日的方法信息
  ///3. 堆栈格式: 日期 → 堆栈 → 每日的堆栈信息
  final allDataMap = <String, Map<String, List<ChannelItemInfo>>>{};

  /// 单个条目的总耗时，不分日期
  final singleItemSumCostMap = <String, int>{};

  ///折线图显示数据 折线的按照每个 条目 分割，每个 条目 里面有它最近多天的数据
  final List<charts.Series<LinearSales, DateTime>> lineShowList = [];

  /// 跟上面不同的是这个是没有被过滤的这个数据是没有被过滤的
  final List<charts.Series<LinearSales, DateTime>> allLineShowList = [];

  ///列表数据
  final List<LineListItemBean> listViewDataList = [];

  /// 控制每个 条目 是否显示
  final Map<String, bool> singleItemShowMap = {};

  /// 条目 最大的平均值
  double maxAverage = 0;

  ///默认展示七天数据
  var days = 7;

  /// 获取 listview item 的高度，默认等于 40， stack 需要高一点，用来显示更多信息
  int getListViewItemHeight() {
    return 40;
  }

  /// 获取 listview 的 item 描述
  String getListViewItemDesc(int index) {
    return listViewDataList[index].name;
  }

  /// 获取当前线的背景颜色
  Color getLineBgColor(int index) {
    return Color.fromARGB(
      255 ~/ 4,
      listViewDataList[index].lineColor.r,
      listViewDataList[index].lineColor.g,
      listViewDataList[index].lineColor.b,
    );
  }

  /// 获取当前线的颜色
  Color getLineColor(int index) {
    return Color.fromARGB(
      listViewDataList[index].lineColor.a,
      listViewDataList[index].lineColor.r,
      listViewDataList[index].lineColor.g,
      listViewDataList[index].lineColor.b,
    );
  }

  /// 30天或7 天
  void set7or30Days(bool day7) {
    days = day7 ? 7 : 30;
    startGetData();
  }

  Future<void> startGetData();

  String getTitle();

  /// 获取列表的 title 描述
  String getListTitleDesc();

  ///显示或隐藏某个条目
  void showOrHideItem(String name, bool show) {
    singleItemShowMap[name] = show;
    filterLine(allLineShowList, singleItemShowMap, lineShowList);
  }

  /// 翻转数据
  void reverseData() {
    desc = !desc;
    sortData(listViewDataList, desc);
  }

  ///重置所有的数据
  void resetAllData([bool allDataIgnore = false]) {
    if (!allDataIgnore) {
      allDataMap.clear();
    }
    singleItemSumCostMap.clear();
    lineShowList.clear();
    allLineShowList.clear();
    listViewDataList.clear();

    maxAverage = 0;
  }

  /// 解析处理数据
  void parseData(
    Map<String, Map<String, List<ChannelItemInfo>>> allDataMap,
    List<charts.Series<LinearSales, DateTime>> allLineShowList,
    List<charts.Series<LinearSales, DateTime>> lineShowList,
    Map<String, int> singleItemSumCostMap,
    Map<String, bool> singleItemShowMap,
    List<LineListItemBean> listViewDataList,
  ) {
    Map<String, List<LinearSales>> lineData = {};
    int i = 0;
    var keys = allDataMap.keys.take(days);
    keys.forEach((dateStr) {
      var dayItem = allDataMap[dateStr]!;
      dayItem.forEach((channelName, value) {
        var filterList = value.where((element) {
          if (!platForms.contains(element.platformName)) {
            platForms.add(element.platformName);
          }
          if (currentPlatForms == "全平台") {
            return true;
          } else {
            return element.platformName == currentPlatForms;
          }
        }).map((e) => e.cost);

        int sumCost = 0;
        if (filterList.length > 0) {
          sumCost = filterList.reduce((value, element) => value + element);
        }
        int averageCost = sumCost ~/ value.length;

        //get all cost time
        if (singleItemSumCostMap.containsKey(channelName)) {
          singleItemSumCostMap[channelName] =
              singleItemSumCostMap[channelName]! + averageCost;
        } else {
          singleItemSumCostMap[channelName] = averageCost;
        }
        if (!lineData.containsKey(channelName)) {
          lineData[channelName] = [];
        }

        var chanNameLine = LinearSales(channelName, i, dateStr, averageCost);
        lineData[channelName]!.add(chanNameLine);
      });
      i++;
    });

    i = 0;
    singleItemSumCostMap.forEach((channelName, sumCost) {
      double average = sumCost / allDataMap.length;
      if (average > maxAverage) {
        maxAverage = average;
      }
      listViewDataList.add(LineListItemBean(
          channelName, linesColors[i++ % linesColors.length], average));
    });
    lineData.forEach((channelName, value) {
      allLineShowList.add(charts.Series<LinearSales, DateTime>(
        id: channelName,
        colorFn: (LinearSales sales, __) {
          return listViewDataList
              .firstWhere((element) => element.name == channelName)
              .lineColor;
        },
        domainFn: (LinearSales sales, _) {
          var dateTime = DateFormat("yyyy-MM-dd").parse(sales.x);
          return dateTime;
        },
        measureFn: (LinearSales sales, _) => sales.value,
        data: value,
      ));
    });

    sortData(listViewDataList, desc);
    filterLine(allLineShowList, singleItemShowMap, lineShowList);
  }

  /// 过滤
  void filterLine(
    List<charts.Series<LinearSales, DateTime>> allLineShowList,
    Map<String, bool> singleItemShowMap,
    List<charts.Series<LinearSales, DateTime>> lineShowList,
  ) {
    var filter = allLineShowList
        .where((element) => singleItemShowMap[element.id] != false)
        .toList();
    lineShowList.clear();
    lineShowList.addAll(filter);
  }

  /// 排序 [desc] 是否倒序
  void sortData(List<LineListItemBean> listViewDataList, bool desc) {
    listViewDataList.sort((a, b) {
      var result = b.average - a.average;
      if (!desc) {
        //正序
        result = a.average - b.average;
      }
      if (result > 0) {
        return 1;
      } else if (result < 0) {
        return -1;
      } else {
        return 0;
      }
    });
  }
}

/// lines color
final linesColors = <charts.Color>[
  charts.MaterialPalette.blue.shadeDefault,
  charts.MaterialPalette.red.shadeDefault,
  charts.MaterialPalette.yellow.shadeDefault,
  charts.MaterialPalette.green.shadeDefault,
  charts.MaterialPalette.purple.shadeDefault,
  charts.MaterialPalette.cyan.shadeDefault,
  charts.MaterialPalette.deepOrange.shadeDefault,
  charts.MaterialPalette.lime.shadeDefault,
  charts.MaterialPalette.indigo.shadeDefault,
  charts.MaterialPalette.pink.shadeDefault,
  charts.MaterialPalette.teal.shadeDefault,
  charts.MaterialPalette.gray.shadeDefault,
];

/// Sample linear data type.
class LinearSales {
  final int index;
  final String x;
  final int value;
  final String channelName;

  LinearSales(this.channelName, this.index, this.x, this.value);
}

/// 渠道数据
class ChannelItemInfo {
  String channelName = "";
  int cost = 0;
  int type = 0;
  String platformName = "";

  String invokeStackStr = "";

  String methodName = "";

  ChannelItemInfo(
    this.type,
    this.channelName,
    this.platformName,
    this.cost, {
    this.invokeStackStr = "",
    this.methodName = "",
  });
}

/// 列表 bean
class LineListItemBean {
  String name = "";
  charts.Color lineColor;

  /// 平均耗时
  double average = 0;

  LineListItemBean(this.name, this.lineColor, this.average);
}
