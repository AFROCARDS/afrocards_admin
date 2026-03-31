import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';
import 'chart_card.dart';

class ChallengesStatsCard extends StatelessWidget {
  final ChallengesSponsorisesStats stats;

  const ChallengesStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Challenges Sponsorisés',
      subtitle: 'Partenariats actifs',
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: StatItem(
              value: stats.actifs.toString(),
              label: 'Actifs',
              color: AppTheme.primaryGreen,
              icon: LucideIcons.zap,
            ),
          ),
          Flexible(
            child: StatItem(
              value: stats.aVenir.toString(),
              label: 'À venir',
              color: AppTheme.primaryPurple,
              icon: LucideIcons.calendar,
            ),
          ),
          Flexible(
            child: StatItem(
              value: stats.termines.toString(),
              label: 'Terminés',
              color: AppTheme.textMuted,
              icon: LucideIcons.checkCircle,
            ),
          ),
          Flexible(
            child: StatItem(
              value: stats.partenairesActifs.toString(),
              label: 'Partenaires',
              color: Colors.orange,
              icon: LucideIcons.building2,
            ),
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
