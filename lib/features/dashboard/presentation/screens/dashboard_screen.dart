import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/core/network/api_client.dart';
import 'package:afrocards_admin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:afrocards_admin/features/dashboard/presentation/widgets/widgets.dart';

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
            // Header
            _buildHeader(context),
            const SizedBox(height: 24),
            
            // Stats Cards
            _buildStatsSection(state),
            const SizedBox(height: 32),
            
            // Graphes principaux
            _buildMainChartsSection(state),
            const SizedBox(height: 24),
            
            // Graphes secondaires
            _buildSecondaryChartsSection(state),
            const SizedBox(height: 24),
            
            // Parties + Top Joueurs
            _buildPartiesSection(state),
            const SizedBox(height: 24),
            
            // Challenges + Activité
            _buildBottomSection(state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
    );
  }

  Widget _buildStatsSection(DashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Pour les petits écrans, utiliser un wrap
        if (constraints.maxWidth < 800) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _buildStatCards(state).map((card) => 
              SizedBox(width: (constraints.maxWidth - 16) / 2, child: card)
            ).toList(),
          );
        }
        
        return Row(
          children: _buildStatCards(state).map((card) => 
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: card,
            ))
          ).toList(),
        );
      },
    );
  }

  List<Widget> _buildStatCards(DashboardLoaded state) {
    return [
      StatCard(
        title: 'Utilisateurs Totaux',
        value: _formatNumber(state.stats.global.utilisateurs),
        subtitle: '+${state.stats.mensuel.nouveauxInscrits} ce mois',
        icon: LucideIcons.users,
        backgroundColor: const Color(0xFFE8F5E9),
        iconColor: AppTheme.primaryGreen,
      ),
      StatCard(
        title: 'Joueurs Actifs',
        value: _formatNumber(state.stats.global.joueurs),
        subtitle: 'Comptes joueurs',
        icon: LucideIcons.gamepad2,
        backgroundColor: const Color(0xFFFFF3E0),
        iconColor: Colors.orange,
      ),
      StatCard(
        title: 'Parties Jouées',
        value: _formatNumber(state.stats.global.partiesJouees),
        subtitle: 'Parties terminées',
        icon: LucideIcons.trophy,
        backgroundColor: const Color(0xFFE3F2FD),
        iconColor: Colors.blue,
      ),
      StatCard(
        title: 'Quiz Disponibles',
        value: _formatNumber(state.stats.global.quiz),
        subtitle: 'Dans la base',
        icon: LucideIcons.helpCircle,
        backgroundColor: const Color(0xFFF3E5F5),
        iconColor: AppTheme.primaryPurple,
      ),
      StatCard(
        title: 'Signalements',
        value: _formatNumber(state.signalements?.totalEnAttente ?? 0),
        subtitle: 'En attente',
        icon: LucideIcons.flag,
        backgroundColor: const Color(0xFFFFEBEE),
        iconColor: AppTheme.error,
        isAlert: (state.signalements?.totalEnAttente ?? 0) > 0,
      ),
    ];
  }

  Widget _buildMainChartsSection(DashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              UsersEvolutionChart(data: state.usersEvolution),
              const SizedBox(height: 24),
              UsersDistributionChart(data: state.usersDistribution),
            ],
          );
        }
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: UsersEvolutionChart(data: state.usersEvolution),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: UsersDistributionChart(data: state.usersDistribution),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecondaryChartsSection(DashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              QuestionsByCategoryChart(data: state.questionsByCategory),
              const SizedBox(height: 24),
              PlayersByCountryChart(data: state.playersByCountry),
            ],
          );
        }
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: QuestionsByCategoryChart(data: state.questionsByCategory),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PlayersByCountryChart(data: state.playersByCountry),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPartiesSection(DashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              PartiesEvolutionChart(data: state.partiesEvolution),
              const SizedBox(height: 24),
              TopPlayersCard(players: state.topPlayers),
            ],
          );
        }
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: PartiesEvolutionChart(data: state.partiesEvolution),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: TopPlayersCard(players: state.topPlayers),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(DashboardLoaded state) {
    final widgets = <Widget>[];
    
    if (state.challengesStats != null) {
      widgets.add(ChallengesStatsCard(stats: state.challengesStats!));
    }
    
    if (state.signalements != null) {
      widgets.add(SignalementsCard(stats: state.signalements!));
    }
    
    if (state.recentActivity != null) {
      widgets.add(RecentActivityCard(activity: state.recentActivity!));
    }
    
    if (widgets.isEmpty) return const SizedBox.shrink();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: widgets.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: w,
            )).toList(),
          );
        }
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.challengesStats != null)
                Expanded(child: ChallengesStatsCard(stats: state.challengesStats!)),
              if (state.challengesStats != null) const SizedBox(width: 24),
              if (state.signalements != null)
                Expanded(child: SignalementsCard(stats: state.signalements!)),
              if (state.signalements != null) const SizedBox(width: 24),
              if (state.recentActivity != null)
                Expanded(
                  flex: 2,
                  child: RecentActivityCard(activity: state.recentActivity!),
                ),
            ],
          ),
        );
      },
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
