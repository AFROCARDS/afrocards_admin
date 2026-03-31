import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';
import 'chart_card.dart';

class UsersDistributionChart extends StatelessWidget {
  final List<UserDistribution> data;

  const UsersDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Répartition Utilisateurs',
      subtitle: 'Par type de compte',
      height: 350,
      child: data.isEmpty
          ? const Center(child: Text('Aucune donnée disponible'))
          : _buildChart(),
    );
  }

  Widget _buildChart() {
    final total = data.fold(0, (sum, item) => sum + item.count);
    
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: data.map((item) {
                final percentage = total > 0 ? (item.count / total * 100) : 0;
                return PieChartSectionData(
                  value: item.count.toDouble(),
                  title: '${percentage.toStringAsFixed(0)}%',
                  color: _hexToColor(item.couleur),
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _hexToColor(item.couleur),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${_capitalizeFirst(item.type)} (${item.count})',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
