import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/core/network/api_client.dart';
import 'package:afrocards_admin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(ApiClient())..add(DashboardLoadRequested()),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryGreen),
                SizedBox(height: 16),
                Text('Chargement du tableau de bord...'),
              ],
            ),
          );
        }
        
        if (state is DashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.alertCircle, size: 48, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<DashboardBloc>().add(DashboardLoadRequested()),
                  icon: const Icon(LucideIcons.refreshCw),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }
        
        if (state is DashboardLoaded) {
          return _buildDashboard(context, state);
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(DashboardRefreshRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec titre et bouton refresh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tableau de bord',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => context.read<DashboardBloc>().add(DashboardRefreshRequested()),
                  icon: const Icon(LucideIcons.refreshCw),
                  tooltip: 'Actualiser',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // ========== SECTION 1: STATS CARDS ==========
            _buildStatsSection(state),
            
            const SizedBox(height: 32),
            
            // ========== SECTION 2: GRAPHES PRINCIPAUX ==========
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Evolution des inscriptions (Line Chart)
                Expanded(
                  flex: 2,
                  child: _UsersEvolutionChart(data: state.usersEvolution),
                ),
                const SizedBox(width: 24),
                // Distribution utilisateurs (Pie Chart)
                Expanded(
                  child: _UsersDistributionChart(data: state.usersDistribution),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // ========== SECTION 3: GRAPHES SECONDAIRES ==========
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Questions par catégorie (Bar Chart)
                Expanded(
                  child: _QuestionsByCategoryChart(data: state.questionsByCategory),
                ),
                const SizedBox(width: 24),
                // Joueurs par pays (Bar Chart horizontal)
                Expanded(
                  child: _PlayersByCountryChart(data: state.playersByCountry),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // ========== SECTION 4: PARTIES + TOP JOUEURS ==========
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Evolution des parties (Area Chart)
                Expanded(
                  flex: 2,
                  child: _PartiesEvolutionChart(data: state.partiesEvolution),
                ),
                const SizedBox(width: 24),
                // Top joueurs
                Expanded(
                  child: _TopPlayersCard(players: state.topPlayers),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // ========== SECTION 5: CHALLENGES + ACTIVITÉ ==========
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats challenges sponsorisés
                if (state.challengesStats != null)
                  Expanded(
                    child: _ChallengesStatsCard(stats: state.challengesStats!),
                  ),
                if (state.challengesStats != null) const SizedBox(width: 24),
                // Signalements
                if (state.signalements != null)
                  Expanded(
                    child: _SignalementsCard(stats: state.signalements!),
                  ),
                if (state.signalements != null) const SizedBox(width: 24),
                // Activité récente
                if (state.recentActivity != null)
                  Expanded(
                    flex: 2,
                    child: _RecentActivityCard(activity: state.recentActivity!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(DashboardLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Utilisateurs Totaux',
            value: _formatNumber(state.stats.global.utilisateurs),
            subtitle: '+${state.stats.mensuel.nouveauxInscrits} ce mois',
            icon: LucideIcons.users,
            backgroundColor: const Color(0xFFE8F5E9),
            iconColor: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Joueurs Actifs',
            value: _formatNumber(state.stats.global.joueurs),
            subtitle: 'Comptes joueurs',
            icon: LucideIcons.gamepad2,
            backgroundColor: const Color(0xFFFFF3E0),
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Parties Jouées',
            value: _formatNumber(state.stats.global.partiesJouees),
            subtitle: 'Parties terminées',
            icon: LucideIcons.trophy,
            backgroundColor: const Color(0xFFE3F2FD),
            iconColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Quiz Disponibles',
            value: _formatNumber(state.stats.global.quiz),
            subtitle: 'Dans la base',
            icon: LucideIcons.helpCircle,
            backgroundColor: const Color(0xFFF3E5F5),
            iconColor: AppTheme.primaryPurple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Signalements',
            value: _formatNumber(state.signalements?.totalEnAttente ?? 0),
            subtitle: 'En attente',
            icon: LucideIcons.flag,
            backgroundColor: const Color(0xFFFFEBEE),
            iconColor: AppTheme.error,
            isAlert: (state.signalements?.totalEnAttente ?? 0) > 0,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

// ============================================
// WIDGETS STAT CARD
// ============================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool isAlert;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: isAlert ? Border.all(color: AppTheme.error, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isAlert ? AppTheme.error : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isAlert ? AppTheme.error : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// CHART CARD WRAPPER
// ============================================

class _ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final double height;

  const _ChartCard({
    required this.title,
    this.subtitle,
    required this.child,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ============================================
// USERS EVOLUTION LINE CHART
// ============================================

class _UsersEvolutionChart extends StatelessWidget {
  final List<UserEvolutionData> data;

  const _UsersEvolutionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Evolution des Inscriptions',
      subtitle: '12 derniers mois',
      height: 350,
      child: data.isEmpty
          ? const Center(child: Text('Aucune donnée disponible'))
          : _buildChart(),
    );
  }

  Widget _buildChart() {
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.inscriptions.toDouble());
    }).toList();

    final maxY = data.isEmpty ? 1.0 : data.map((d) => d.inscriptions).reduce((a, b) => a > b ? a : b).toDouble();

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
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length && index % 2 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index].mois,
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
            curveSmoothness: 0.3,
            color: AppTheme.primaryGreen,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppTheme.primaryGreen,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.3),
                  AppTheme.primaryGreen.withValues(alpha: 0.0),
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
                final label = index < data.length ? data[index].label : '';
                return LineTooltipItem(
                  '$label\n${spot.y.toInt()} inscriptions',
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

// ============================================
// USERS DISTRIBUTION PIE CHART
// ============================================

class _UsersDistributionChart extends StatelessWidget {
  final List<UserDistribution> data;

  const _UsersDistributionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
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
        Column(
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
                  Text(
                    '${_capitalizeFirst(item.type)} (${item.count})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
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

// ============================================
// QUESTIONS BY CATEGORY BAR CHART
// ============================================

class _QuestionsByCategoryChart extends StatelessWidget {
  final List<CategoryStats> data;

  const _QuestionsByCategoryChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Questions par Catégorie',
      subtitle: 'Répartition du contenu',
      height: 350,
      child: data.isEmpty
          ? const Center(child: Text('Aucune donnée disponible'))
          : _buildChart(),
    );
  }

  Widget _buildChart() {
    final maxY = data.isEmpty ? 1.0 : data.map((d) => d.questions).reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppTheme.textPrimary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[groupIndex].nom}\n${rod.toY.toInt()} questions',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
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
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index].nom.length > 10 
                          ? '${data[index].nom.substring(0, 10)}...'
                          : data[index].nom,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
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
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.questions.toDouble(),
                color: _hexToColor(entry.value.couleur),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

// ============================================
// PLAYERS BY COUNTRY HORIZONTAL BAR CHART
// ============================================

class _PlayersByCountryChart extends StatelessWidget {
  final List<CountryStats> data;

  const _PlayersByCountryChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
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

// ============================================
// PARTIES EVOLUTION AREA CHART
// ============================================

class _PartiesEvolutionChart extends StatelessWidget {
  final List<PartiesEvolutionData> data;

  const _PartiesEvolutionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
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

// ============================================
// TOP PLAYERS CARD
// ============================================

class _TopPlayersCard extends StatelessWidget {
  final List<TopPlayer> players;

  const _TopPlayersCard({required this.players});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
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
                return _PlayerListItem(player: player, index: index);
              },
            ),
    );
  }
}

class _PlayerListItem extends StatelessWidget {
  final TopPlayer player;
  final int index;

  const _PlayerListItem({required this.player, required this.index});

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

// ============================================
// CHALLENGES STATS CARD
// ============================================

class _ChallengesStatsCard extends StatelessWidget {
  final ChallengesSponsorisesStats stats;

  const _ChallengesStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Challenges Sponsorisés',
      subtitle: 'Partenariats actifs',
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: stats.actifs.toString(),
            label: 'Actifs',
            color: AppTheme.primaryGreen,
            icon: LucideIcons.zap,
          ),
          _StatItem(
            value: stats.aVenir.toString(),
            label: 'À venir',
            color: AppTheme.primaryPurple,
            icon: LucideIcons.calendar,
          ),
          _StatItem(
            value: stats.termines.toString(),
            label: 'Terminés',
            color: AppTheme.textMuted,
            icon: LucideIcons.checkCircle,
          ),
          _StatItem(
            value: stats.partenairesActifs.toString(),
            label: 'Partenaires',
            color: Colors.orange,
            icon: LucideIcons.building2,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatItem({
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
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

// ============================================
// SIGNALEMENTS CARD
// ============================================

class _SignalementsCard extends StatelessWidget {
  final SignalementsStats stats;

  const _SignalementsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Signalements',
      subtitle: 'Modération',
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: _SignalementCategory(
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
            child: _SignalementCategory(
              title: 'Questions',
              stats: stats.questions,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalementCategory extends StatelessWidget {
  final String title;
  final SignalementDetail stats;

  const _SignalementCategory({
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
            _SignalementStat(
              value: stats.enAttente,
              label: 'En attente',
              color: Colors.orange,
            ),
            const SizedBox(width: 16),
            _SignalementStat(
              value: stats.traite,
              label: 'Traités',
              color: AppTheme.primaryGreen,
            ),
          ],
        ),
      ],
    );
  }
}

class _SignalementStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _SignalementStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

// ============================================
// RECENT ACTIVITY CARD
// ============================================

class _RecentActivityCard extends StatelessWidget {
  final RecentActivity activity;

  const _RecentActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final allActivities = <_ActivityItem>[];
    
    // Ajouter inscriptions
    for (final inscription in activity.inscriptions) {
      allActivities.add(_ActivityItem(
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
      allActivities.add(_ActivityItem(
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

    return _ChartCard(
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
                return _ActivityListItem(item: item);
              },
            ),
    );
  }
}

class _ActivityItem {
  final String type;
  final String title;
  final String subtitle;
  final DateTime date;
  final String? avatar;
  final IconData icon;
  final Color color;

  _ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    this.avatar,
    required this.icon,
    required this.color,
  });
}

class _ActivityListItem extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityListItem({required this.item});

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
                ),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
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
