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

class DashboardPeriodChanged extends DashboardEvent {
  final int days;
  
  DashboardPeriodChanged(this.days);
  
  @override
  List<Object?> get props => [days];
}

// States
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<ChartDataPoint> usersEvolution;
  final List<CategoryChartData> quizByCategory;
  final int signalements;
  final int selectedPeriod;

  DashboardLoaded({
    required this.stats,
    required this.usersEvolution,
    required this.quizByCategory,
    required this.signalements,
    this.selectedPeriod = 30,
  });

  @override
  List<Object?> get props => [stats, usersEvolution, quizByCategory, signalements, selectedPeriod];

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<ChartDataPoint>? usersEvolution,
    List<CategoryChartData>? quizByCategory,
    int? signalements,
    int? selectedPeriod,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      usersEvolution: usersEvolution ?? this.usersEvolution,
      quizByCategory: quizByCategory ?? this.quizByCategory,
      signalements: signalements ?? this.signalements,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
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
    on<DashboardPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadDashboard(emit, 30);
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    final period = currentState is DashboardLoaded ? currentState.selectedPeriod : 30;
    await _loadDashboard(emit, period);
  }

  Future<void> _onPeriodChanged(
    DashboardPeriodChanged event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      emit(DashboardLoading());
      await _loadDashboard(emit, event.days);
    }
  }

  Future<void> _loadDashboard(Emitter<DashboardState> emit, int days) async {
    try {
      final results = await Future.wait([
        _repository.getDashboardStats(),
        _repository.getActiveUsersEvolution(days: days),
        _repository.getQuizByCategory(days: days),
        _repository.getSignalementsCount(),
      ]);

      emit(DashboardLoaded(
        stats: results[0] as DashboardStats,
        usersEvolution: results[1] as List<ChartDataPoint>,
        quizByCategory: results[2] as List<CategoryChartData>,
        signalements: results[3] as int,
        selectedPeriod: days,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
