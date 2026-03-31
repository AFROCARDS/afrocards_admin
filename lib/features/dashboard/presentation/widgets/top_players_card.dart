import 'package:flutter/material.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';
import 'chart_card.dart';

class TopPlayersCard extends StatelessWidget {
  final List<TopPlayer> players;

  const TopPlayersCard({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Top Joueurs',
      subtitle: 'Par score total',
      height: 300,
      child: players.isEmpty
          ? const Center(child: Text('Aucun joueur'))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return PlayerListItem(player: player, index: index);
              },
            ),
    );
  }
}

class PlayerListItem extends StatelessWidget {
  final TopPlayer player;
  final int index;

  const PlayerListItem({super.key, required this.player, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
      AppTheme.textMuted,
      AppTheme.textMuted,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: index < 3 ? colors[index].withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Rang
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors[index < 5 ? index : 4],
              shape: BoxShape.circle,
            ),
            child: Text(
              '${player.rang}',
              style: TextStyle(
                color: index < 3 ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundImage: player.avatar != null ? NetworkImage(player.avatar!) : null,
            backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
            child: player.avatar == null
                ? Text(
                    player.pseudo.isNotEmpty ? player.pseudo[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.pseudo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Niv. ${player.niveau} • ${player.tauxVictoire}% victoires',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Score
          Text(
            '${_formatScore(player.score)} pts',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}k';
    }
    return score.toString();
  }
}
