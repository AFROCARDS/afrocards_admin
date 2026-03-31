import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';
import 'chart_card.dart';

class RecentActivityCard extends StatelessWidget {
  final RecentActivity activity;

  const RecentActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final allActivities = <ActivityItem>[];
    
    // Ajouter inscriptions
    for (final inscription in activity.inscriptions) {
      allActivities.add(ActivityItem(
        type: 'inscription',
        title: inscription.pseudo ?? inscription.nom,
        subtitle: 'Nouvel utilisateur (${inscription.type})',
        date: inscription.date,
        avatar: inscription.avatar,
        icon: LucideIcons.userPlus,
        color: AppTheme.primaryGreen,
      ));
    }
    
    // Ajouter parties
    for (final partie in activity.parties) {
      allActivities.add(ActivityItem(
        type: 'partie',
        title: partie.pseudo ?? 'Joueur',
        subtitle: 'Partie terminée (${partie.score} pts)',
        date: partie.date,
        avatar: partie.avatar,
        icon: LucideIcons.gamepad2,
        color: AppTheme.primaryPurple,
      ));
    }
    
    // Trier par date
    allActivities.sort((a, b) => b.date.compareTo(a.date));

    return ChartCard(
      title: 'Activité Récente',
      subtitle: 'Dernières actions',
      height: 200,
      child: allActivities.isEmpty
          ? const Center(child: Text('Aucune activité récente'))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allActivities.take(5).length,
              itemBuilder: (context, index) {
                final item = allActivities[index];
                return ActivityListItem(item: item);
              },
            ),
    );
  }
}

class ActivityItem {
  final String type;
  final String title;
  final String subtitle;
  final DateTime date;
  final String? avatar;
  final IconData icon;
  final Color color;

  ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    this.avatar,
    required this.icon,
    required this.color,
  });
}

class ActivityListItem extends StatelessWidget {
  final ActivityItem item;

  const ActivityListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _formatTimeAgo(item.date),
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return DateFormat('dd/MM').format(date);
  }
}
