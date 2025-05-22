import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import 'utils.dart';


Widget uChartLine(
  List<double> x,
  List<List<double>> y,
  String xTitle,
  String yTitle,
) {
  List<Color> colors = [];

  for (var i = 0; i < y.length; i++) {
    colors.add(
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
    );
  }

  List<FlSpot> spots = [];
  List<LineChartBarData> llbd = [];
  for (var i = 0; i < y.length; i++) {
    spots = [];
    for (var j = 0; j < x.length; j++) {
      spots.add(FlSpot(x[j], y[i][j]));
    }
    llbd.add(LineChartBarData(spots: spots, color: colors[i]));
  }
  return uFlex(
    LineChart(
      LineChartData(
        lineBarsData: llbd,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(axisNameWidget: Text(yTitle)),
          bottomTitles: AxisTitles(axisNameWidget: Text(xTitle)),
        ),
      ),
    ),
  );
}

Widget uChartBar(
  List<String> xNames,
  List<List<double>> y,
  String xTitle,
  String yTitle,
) {
  List<Color> colors = [];

  for (var i = 0; i < y.length; i++) {
    colors.add(
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
    );
  }

  List<BarChartGroupData> lbc = [];
  for (var j = 0; j < xNames.length; j++) {
    BarChartRodData bcrd;
    List<BarChartRodData> lbcrd = [];
    for (var i = 0; i < y.length; i++) {
      bcrd = BarChartRodData(toY: y[i][j], color: colors[i]);
      lbcrd.add(bcrd);
    }
    lbc.add(BarChartGroupData(x: j, barRods: lbcrd));
  }
  Widget getTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(xNames[value.toInt()], style: TextStyle(color: Colors.black)),
    );
  }

  return uFlex(
    BarChart(
      BarChartData(
        barGroups: lbc,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(axisNameWidget: Text(yTitle)),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(xTitle),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getTitles,
            ),
          ),
        ),
      ),
    ),
  );
}
