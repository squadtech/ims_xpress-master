import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/models/GraphModel.dart';

class ProfitChart extends StatelessWidget {
  // this class creates the graph that we see at the dashboard
  final List<GraphModel> _data;

  ProfitChart(this._data);

  @override
  Widget build(BuildContext context) {
    List<charts.Series<GraphModel, String>> _series = [
      charts.Series(
          id: 'Profit',
          data: _data,
          domainFn: (obj, _) => obj.monthName,
          measureFn: (obj, _) => obj.profit,
          colorFn: (obj, _) =>
              charts.ColorUtil.fromDartColor(Constants.redLight))
    ];
    return charts.BarChart(
      _series,
      animate: true,
    );
  }
}
