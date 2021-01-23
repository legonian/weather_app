import 'package:flutter/material.dart';

import 'package:bezier_chart/bezier_chart.dart';

import 'weather.dart';

class PlotGraph extends StatelessWidget {
  const PlotGraph({@required this.database});

  final List<Weather> database;

  @override
  Widget build(BuildContext context) {
    DateTime fromDate = database[0].time;
    DateTime toDate = database[0].time;
    for (var i in database) {
      if (i.time.isBefore(fromDate)) {
        fromDate = i.time;
      }
      if (i.time.isAfter(toDate)) {
        toDate = i.time;
      }
    }

    final height = MediaQuery.of(context).orientation.index == 1
        ? MediaQuery.of(context).size.height * 0.7
        : MediaQuery.of(context).size.width * 0.7;

    return Container(
      color: Colors.red,
      height: height,
      child: BezierChart(
        bezierChartScale: BezierChartScale.CUSTOM,
        xAxisCustomValues: [for (var i in database) i.time.day.toDouble()],
        // fromDate: fromDate,
        // toDate: toDate,
        onIndicatorVisible: (val) {
          print("Indicator Visible :$val");
        },
        // onDateTimeSelected: (datetime) {
        //   print("selected datetime: $datetime");
        // },
        onScaleChanged: (scale) {
          print("Scale: $scale");
        },
        // selectedDate: toDate,
        // //this is optional
        // footerDateTimeBuilder: (DateTime value, BezierChartScale scaleType) {
        //   final newFormat = intl.DateFormat('dd/MM');
        //   return newFormat.format(value);
        // },
        series: [
          BezierLine(
            label: "Temp",
            data: [
              for (var i in database)
                DataPoint<double>(value: i.temp, xAxis: i.time.day.toDouble())
            ],
          ),
          BezierLine(
            label: "Humidity",
            lineColor: Colors.black26,
            onMissingValue: (dateTime) {
              if (dateTime.month.isEven) {
                return 10.0;
              }
              return 3.0;
            },
            data: [
              for (var i in database)
                DataPoint<double>(
                    value: i.humidity, xAxis: i.time.day.toDouble())
            ],
          ),
        ],
        config: BezierChartConfig(
          // footerHeight: 35.0,
          displayYAxis: true,
          stepsYAxis: 10,
          backgroundColor: Colors.lightBlue,
          snap: false,
        ),
      ),
    );
  }
}
