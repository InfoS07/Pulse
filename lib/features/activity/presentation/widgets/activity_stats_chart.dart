import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/theme/app_pallete.dart';

class ActivityStatsChart extends StatelessWidget {
  final List<ActivityStats> stats;

  ActivityStatsChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPallete.backgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temps de réaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _createSpots(stats),
                    isCurved: true,
                    color: AppPallete.thirdColor,
                    barWidth: 1,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      'Temps en ms',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, titleMeta) {
                        return Text(
                          value.toInt().toString(),
                          style:
                              const TextStyle(color: Colors.white, fontSize: 8),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      'Répétitions',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, titleMeta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          );
                        },
                        interval: 10),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                lineTouchData: LineTouchData(enabled: true),
                minX: 1,
                maxX: stats.length.toDouble(),
                minY: 0,
                maxY: _getMaxY(stats),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _createSpots(List<ActivityStats> stats) {
    List<FlSpot> spots = [];

    for (int i = 0; i < stats.length; i++) {
      final xValue = (i + 1).toDouble(); // Repetition number
      final yValue = stats[i].reactionTime.toDouble(); // Time in milliseconds
      spots.add(FlSpot(xValue, yValue));
    }

    return spots;
  }

  double _getMaxY(List<ActivityStats> stats) {
    double maxY = 0;
    double maxYarrondi = 0;
    for (var stat in stats) {
      if (stat.reactionTime.toDouble() > maxY) {
        maxY = stat.reactionTime.toDouble();
        //maxYarrondi = maxY.ceil().toDouble();
      }
    }
    return maxY;
  }
}
