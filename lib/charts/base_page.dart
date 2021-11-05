import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'base_channel_data.dart';
import 'channel_data.dart';
import 'line_chart.dart';
import 'method_data.dart';
import 'stack_data.dart';

class BasePage extends StatefulWidget {
  BasePage(this._dataManager, {Key? key}) : super(key: key);

  final BaseChannelData _dataManager;

  @override
  _BasePageState createState() => _BasePageState(_dataManager);
}

class _BasePageState extends State<BasePage> {
  final BaseChannelData _dataManager;

  _BasePageState(this._dataManager);

  @override
  void initState() {
    super.initState();
    _dataManager.startGetData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: kIsWeb == true
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: _crateLineWidget(),
                    ),
                    Container(
                      width: 10,
                      color: Colors.blueGrey,
                    ),
                    Flexible(
                      child: Stack(
                        children: [
                          _createListTitle(),
                          _createList(),
                          _refreshWidget(),
                        ],
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    _crateLineWidget(),
                    _createListTitle(),
                    _createList(),
                    _refreshWidget(),
                  ],
                ),
        ),
      ),
    );
  }

  void dumpToMethodInfo(BuildContext context, int index) {
    if (_dataManager is ChannelDataManager) {
      (_dataManager as ChannelDataManager).dumpToChannelInfo(context, index,
          () {
        _dataManager.startGetData();
        setState(() {});
      });
    } else if (_dataManager is MethodDataManager) {
      (_dataManager as MethodDataManager).dumpToStackInfo(context, index);
    } else if (_dataManager is StackDataManager) {
      (_dataManager as StackDataManager).showStackDetails(context, index);
    }
  }

  Align _refreshWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: InkWell(
        onTap: () async {
          await _dataManager.startGetData();
          setState(() {});
        },
        child: Container(
          height: kIsWeb == true ? 80 : 40,
          color: Colors.blueGrey[50],
          child: Center(
            child: Text(
              kIsWeb ? "上传文件" : "加载当前 APP 数据",
              style: TextStyle(
                color: Colors.black,
                fontSize: kIsWeb == true ? 24 : 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createListTitle() {
    return Padding(
      padding: const EdgeInsets.only(
        top: kIsWeb == true ? 0 : 300,
      ),
      child: Container(
        color: Colors.blueGrey[50],
        padding: EdgeInsets.only(
          left: 8,
          top: 4,
          bottom: 4,
          right: 8,
        ),
        height: kIsWeb == true ? 80 : 40,
        child: Row(
          children: [
            Expanded(
              child: Text(
                _dataManager.getListTitleDesc(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: kIsWeb == true ? 24 : 12,
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                margin: EdgeInsets.only(
                  right: 4,
                ),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                color: Colors.blueAccent,
                height: kIsWeb == true ? 80 : 40,
                child: Center(
                  child: dropdownButtonItem(
                    platForms,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _dataManager.reverseData();
                setState(() {});
              },
              child: Text(
                "平均时长(ms)" + (desc ? "↓" : "↑"),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: kIsWeb == true ? 24 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dropdownButtonItem(
    List<String> data,
  ) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        items: data
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: kIsWeb == true ? 24 : 12,
                    ),
                  ),
                ))
            .toList(),
        hint: Text(currentPlatForms,
            style: TextStyle(
              color: Colors.black,
              fontSize: kIsWeb == true ? 24 : 12,
            )),
        onChanged: (v) {
          currentPlatForms = v!;
          _dataManager.startGetData();
          setState(() {});
        },
        value: currentPlatForms,
      ),
    );
  }

  Widget _createList() {
    return Padding(
      padding: EdgeInsets.only(
        top: kIsWeb == true ? 80 : 340,
        bottom: kIsWeb == true ? 80 : 40,
      ),
      child: ListView.builder(
        itemCount: _dataManager.listViewDataList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              dumpToMethodInfo(context, index);
            },
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: _dataManager.maxAverage == 0
                      ? 0
                      : _dataManager.listViewDataList[index].average /
                          _dataManager.maxAverage,
                  child: Container(
                    height: _dataManager.getListViewItemHeight().toDouble(),
                    color: _dataManager.getLineBgColor(index),
                  ),
                ),
                Container(
                  height: _dataManager.getListViewItemHeight().toDouble(),
                  child: Row(
                    children: [
                      Checkbox(
                          value: _dataManager.singleItemShowMap[
                                  _dataManager.listViewDataList[index].name] ??
                              true,
                          onChanged: (value) {
                            print("check: $value");
                            if (value == null) {
                              return;
                            }
                            _dataManager.showOrHideItem(
                                _dataManager.listViewDataList[index].name,
                                value);
                            setState(() {});
                          }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: _dataManager.getLineColor(index),
                          width: 20,
                          height: 5,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _dataManager.getListViewItemDesc(index),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          _dataManager.listViewDataList[index].average
                              .toStringAsFixed(2),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Column _crateLineWidget() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          color: Colors.blueGrey[50],
          padding: EdgeInsets.only(
            left: 8,
            top: 4,
            bottom: 4,
            right: 8,
          ),
          height: kIsWeb == true ? 80 : 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            verticalDirection: VerticalDirection.down,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) {
                        return _dataManager.days == 7
                            ? Colors.blue
                            : Colors.grey;
                      },
                    ),
                  ),
                  onPressed: () {
                    _dataManager.set7or30Days(true);
                    setState(() {});
                  },
                  child: Text(
                    '7 天数据',
                    style: TextStyle(
                      fontSize: kIsWeb == true ? 24 : 12,
                    ),
                  ),
                ),
              ),
              Container(
                width: 5,
              ),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) {
                        return _dataManager.days == 7
                            ? Colors.grey
                            : Colors.blue;
                      },
                    ),
                  ),
                  onPressed: () {
                    _dataManager.set7or30Days(false);
                    setState(() {});
                  },
                  child: Text('30 天数据',
                      style: TextStyle(
                        fontSize: kIsWeb == true ? 24 : 12,
                      )),
                ),
              ),
            ],
          ),
        ),
        kIsWeb == true
            ? Expanded(
                child: Container(
                  child: AreaAndLineChart(
                    _dataManager.lineShowList,
                    title: _dataManager.getTitle(),
                  ),
                ),
              )
            : Container(
                height: 260,
                child: AreaAndLineChart(_dataManager.lineShowList),
              ),
      ],
    );
  }
}
