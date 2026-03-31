import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';
import 'chart_card.dart';

class PartiesEvolutionChart extends StatelessWidget {
  final List<PartiesEvolutionData> data;

  const PartiesEvolutionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Activité de Jeu',
      subtitle: '30 derniers jours - Parties jouées',
      height: 300,
      child: data.isEmpty
          ? const Center(child: Text('Aucune donnée disponible'))
          : _buildChart(),
    );
  }

  Widget _buildChart() {
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.parties.toDouble());
    }).toList();

    final maxY = data.isEmpty ? 1.0 : data.map((d) => d.parties).reduce((a, b) => a > b ? a : b).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${data[index].jour}',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: data.isEmpty ? 1 : (data.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            color: AppTheme.primaryPurple,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryPurple.withValues(alpha: 0.4),
                  AppTheme.primaryPurple.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => AppTheme.textPrimary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final date = index < data.length ? data[index].date : '';
                return LineTooltipItem(
                  '$date\n${spot.y.toInt()} parties',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
