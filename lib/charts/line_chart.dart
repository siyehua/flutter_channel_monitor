/// Line chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'base_chanel_data.dart';

class AreaAndLineChart extends StatelessWidget {
  final List<charts.Series<LinearSales, DateTime>> seriesList;
  final bool animate;
  final String title;

  AreaAndLineChart(this.seriesList, {this.title = "", this.animate = false});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      behaviors: [
        charts.ChartTitle(title,
            behaviorPosition: charts.BehaviorPosition.top,
            titleOutsideJustification: charts.OutsideJustification.start,
            // Set a larger inner padding than the default (10) to avoid
            // rendering the text too close to the top measure axis tick label.
            // The top tick label may extend upwards into the top margin region
            // if it is located at the top of the draw area.
            innerPadding: 18),
        charts.SelectNearest(
          eventTrigger: charts.SelectionTrigger.tapAndDrag,
        ),
        charts.LinePointHighlighter(
          //被选中时，显示横纵坐标
          showHorizontalFollowLine:
              charts.LinePointHighlighterFollowLineType.nearest,
          showVerticalFollowLine:
              charts.LinePointHighlighterFollowLineType.nearest,
        ),
      ],
      // behaviors: [
      //   //这里的操作是修改的图例
      //   charts.SeriesLegend(
      //     // 图例位置 在左侧start 和右侧end
      //     position: charts.BehaviorPosition.bottom,
      //     outsideJustification: charts.OutsideJustification.start,
      //     // 图例条目  [horizontalFirst]设置为false，图例条目将首先作为新行而不是新列增长
      //     horizontalFirst: false,
      //     // 每个图例条目周围的填充Padding
      //     cellPadding: EdgeInsets.only(left: 16, right: 16, bottom: 4.0),
      //     // 显示度量
      //     showMeasures: true,
      //     // 度量格式
      //     // measureFormatter: (num value) {
      //     //  return value == null ? '-' : '${value}k';
      //     // },
      //   ),
      //
      selectionModels: [
        charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: (model) {
            //被选中回调
          },
        ),
      ],
      domainAxis: charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.BasicDateTimeTickFormatterSpec(
          (time) {
            return DateFormat("MM-dd").format(time);
          },
        ),
      ),
      customSeriesRenderers: [
        charts.LineRendererConfig(
            // ID used to link series to this renderer.
            customRendererId: 'customArea',
            includeArea: true,
            stacked: true),
      ],
    );
  }

  /// Create one series with sample hard coded data.
}
