import 'package:flutter/material.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';
import 'chart_card.dart';

class PlayersByCountryChart extends StatelessWidget {
  final List<CountryStats> data;

  const PlayersByCountryChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Joueurs par Pays',
      subtitle: 'Top 8 des pays',
      height: 350,
      child: data.isEmpty
          ? const Center(child: Text('Aucune donnée disponible'))
          : _buildList(),
    );
  }

  Widget _buildList() {
    final maxValue = data.isEmpty ? 1 : data.map((d) => d.joueurs).reduce((a, b) => a > b ? a : b);
    final colors = [
      AppTheme.primaryGreen,
      const Color(0xFF4CAF50),
      const Color(0xFF66BB6A),
      const Color(0xFF81C784),
      const Color(0xFFA5D6A7),
      const Color(0xFFC8E6C9),
      const Color(0xFFE8F5E9),
      const Color(0xFFF1F8E9),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final percentage = maxValue > 0 ? item.joueurs / maxValue : 0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  item.pays,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage.toDouble(),
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  item.joueurs.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
