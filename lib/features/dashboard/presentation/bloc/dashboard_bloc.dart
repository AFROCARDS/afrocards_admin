import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:afrocards_admin/core/network/api_client.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';
import 'package:afrocards_admin/features/dashboard/data/repositories/dashboard_repository.dart';

// Events
abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {}

class DashboardRefreshRequested extends DashboardEvent {}

// States
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<UserEvolutionData> usersEvolution;
  final List<PartiesEvolutionData> partiesEvolution;
  final List<CategoryStats> questionsByCategory;
  final List<TopPlayer> topPlayers;
  final List<UserDistribution> usersDistribution;
  final List<CountryStats> playersByCountry;
  final SignalementsStats? signalements;
  final RecentActivity? recentActivity;
  final ChallengesSponsorisesStats? challengesStats;

  DashboardLoaded({
    required this.stats,
    required this.usersEvolution,
    required this.partiesEvolution,
    required this.questionsByCategory,
    required this.topPlayers,
    required this.usersDistribution,
    required this.playersByCountry,
    this.signalements,
    this.recentActivity,
    this.challengesStats,
  });

  @override
  List<Object?> get props => [
    stats, usersEvolution, partiesEvolution, questionsByCategory, 
    topPlayers, usersDistribution, playersByCountry, signalements,
    recentActivity, challengesStats
  ];
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;
  
  DashboardBloc(ApiClient apiClient) 
      : _repository = DashboardRepository(apiClient),
        super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadDashboard(emit);
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadDashboard(emit);
  }

  Future<void> _loadDashboard(Emitter<DashboardState> emit) async {
    try {
      // Charger toutes les données en parallèle
      final results = await Future.wait([
        _repository.getDashboardStats(),
        _repository.getUsersEvolution(months: 12),
        _repository.getPartiesEvolution(days: 30),
        _repository.getQuestionsByCategory(),
        _repository.getTopPlayers(limit: 5),
        _repository.getUsersDistribution(),
        _repository.getPlayersByCountry(limit: 8),
        _repository.getSignalementsStats(),
        _repository.getRecentActivity(limit: 5),
        _repository.getChallengesSponsorisesStats(),
      ]);

      emit(DashboardLoaded(
        stats: results[0] as DashboardStats,
        usersEvolution: results[1] as List<UserEvolutionData>,
        partiesEvolution: results[2] as List<PartiesEvolutionData>,
        questionsByCategory: results[3] as List<CategoryStats>,
        topPlayers: results[4] as List<TopPlayer>,
        usersDistribution: results[5] as List<UserDistribution>,
        playersByCountry: results[6] as List<CountryStats>,
        signalements: results[7] as SignalementsStats?,
        recentActivity: results[8] as RecentActivity?,
        challengesStats: results[9] as ChallengesSponsorisesStats?,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
