import 'package:flutter/material.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';
import 'chart_card.dart';

class SignalementsCard extends StatelessWidget {
  final SignalementsStats stats;

  const SignalementsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Signalements',
      subtitle: 'Modération',
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: SignalementCategory(
              title: 'Utilisateurs',
              stats: stats.utilisateurs,
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          Expanded(
            child: SignalementCategory(
              title: 'Questions',
              stats: stats.questions,
            ),
          ),
        ],
      ),
    );
  }
}

class SignalementCategory extends StatelessWidget {
  final String title;
  final SignalementDetail stats;

  const SignalementCategory({
    super.key,
    required this.title,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: SignalementStat(
                value: stats.enAttente,
                label: 'En attente',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: SignalementStat(
                value: stats.traite,
                label: 'Traités',
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SignalementStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const SignalementStat({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
