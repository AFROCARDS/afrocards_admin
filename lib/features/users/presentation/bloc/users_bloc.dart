import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:afrocards_admin/features/users/data/models/user_admin_model.dart';
import 'package:afrocards_admin/features/users/data/repositories/users_repository.dart';

// Events
abstract class UsersEvent extends Equatable {
  const UsersEvent();
  @override
  List<Object?> get props => [];
}

class UsersLoadRequested extends UsersEvent {
  final int page;
  final String? typeFilter;
  final String? search;
  final bool refresh;

  const UsersLoadRequested({
    this.page = 1,
    this.typeFilter,
    this.search,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, typeFilter, search, refresh];
}

class UsersRoleUpdateRequested extends UsersEvent {
  final int userId;
  final String newRole;

  const UsersRoleUpdateRequested({
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [userId, newRole];
}

class UsersStatusUpdateRequested extends UsersEvent {
  final int userId;
  final String newStatus;

  const UsersStatusUpdateRequested({
    required this.userId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [userId, newStatus];
}

class UsersDeleteRequested extends UsersEvent {
  final int userId;
  const UsersDeleteRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UsersRoleChangesSubmitted extends UsersEvent {
  const UsersRoleChangesSubmitted();
}

class UsersLocalRoleChanged extends UsersEvent {
  final int userId;
  final String newRole;

  const UsersLocalRoleChanged({
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [userId, newRole];
}

class UsersClearPendingChanges extends UsersEvent {
  const UsersClearPendingChanges();
}

// State
enum UsersStatus { initial, loading, loaded, error }

class UsersState extends Equatable {
  final UsersStatus status;
  final List<UserAdmin> users;
  final int currentPage;
  final int totalPages;
  final int totalUsers;
  final String? typeFilter;
  final String? search;
  final String? errorMessage;
  final Map<int, String> pendingRoleChanges; // userId -> newRole
  final bool isSubmitting;

  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalUsers = 0,
    this.typeFilter,
    this.search,
    this.errorMessage,
    this.pendingRoleChanges = const {},
    this.isSubmitting = false,
  });

  UsersState copyWith({
    UsersStatus? status,
    List<UserAdmin>? users,
    int? currentPage,
    int? totalPages,
    int? totalUsers,
    String? typeFilter,
    String? search,
    String? errorMessage,
    Map<int, String>? pendingRoleChanges,
    bool? isSubmitting,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalUsers: totalUsers ?? this.totalUsers,
      typeFilter: typeFilter ?? this.typeFilter,
      search: search ?? this.search,
      errorMessage: errorMessage,
      pendingRoleChanges: pendingRoleChanges ?? this.pendingRoleChanges,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  bool get hasPendingChanges => pendingRoleChanges.isNotEmpty;

  @override
  List<Object?> get props => [
        status,
        users,
        currentPage,
        totalPages,
        totalUsers,
        typeFilter,
        search,
        errorMessage,
        pendingRoleChanges,
        isSubmitting,
      ];
}

// Bloc
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository _repository;

  UsersBloc({UsersRepository? repository})
      : _repository = repository ?? UsersRepository(),
        super(const UsersState()) {
    on<UsersLoadRequested>(_onLoadRequested);
    on<UsersRoleUpdateRequested>(_onRoleUpdateRequested);
    on<UsersStatusUpdateRequested>(_onStatusUpdateRequested);
    on<UsersDeleteRequested>(_onDeleteRequested);
    on<UsersLocalRoleChanged>(_onLocalRoleChanged);
    on<UsersRoleChangesSubmitted>(_onRoleChangesSubmitted);
    on<UsersClearPendingChanges>(_onClearPendingChanges);
  }

  Future<void> _onLoadRequested(
    UsersLoadRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(
      status: event.refresh ? UsersStatus.loading : state.status,
      typeFilter: event.typeFilter,
      search: event.search,
    ));

    try {
      final response = await _repository.getUsers(
        page: event.page,
        type: event.typeFilter,
        search: event.search,
      );

      emit(state.copyWith(
        status: UsersStatus.loaded,
        users: response.users,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        totalUsers: response.total,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UsersStatus.error,
        errorMessage: 'Erreur lors du chargement des utilisateurs',
      ));
    }
  }

  Future<void> _onRoleUpdateRequested(
    UsersRoleUpdateRequested event,
    Emitter<UsersState> emit,
  ) async {
    try {
      await _repository.updateUserRole(event.userId, event.newRole);
      
      // Mettre à jour localement
      final updatedUsers = state.users.map((u) {
        if (u.id == event.userId) {
          return u.copyWith(typeUtilisateur: event.newRole);
        }
        return u;
      }).toList();

      emit(state.copyWith(users: updatedUsers));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Erreur lors de la mise à jour du rôle',
      ));
    }
  }

  Future<void> _onStatusUpdateRequested(
    UsersStatusUpdateRequested event,
    Emitter<UsersState> emit,
  ) async {
    try {
      await _repository.updateUserStatus(event.userId, event.newStatus);
      
      // Mettre à jour localement
      final updatedUsers = state.users.map((u) {
        if (u.id == event.userId) {
          return u.copyWith(statutCompte: event.newStatus);
        }
        return u;
      }).toList();

      emit(state.copyWith(users: updatedUsers));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Erreur lors de la mise à jour du statut',
      ));
    }
  }

  Future<void> _onDeleteRequested(
    UsersDeleteRequested event,
    Emitter<UsersState> emit,
  ) async {
    try {
      await _repository.deleteUser(event.userId);
      
      // Retirer l'utilisateur de la liste ou marquer comme supprimé
      final updatedUsers = state.users.where((u) => u.id != event.userId).toList();
      emit(state.copyWith(users: updatedUsers, totalUsers: state.totalUsers - 1));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Erreur lors de la suppression',
      ));
    }
  }

  void _onLocalRoleChanged(
    UsersLocalRoleChanged event,
    Emitter<UsersState> emit,
  ) {
    final newChanges = Map<int, String>.from(state.pendingRoleChanges);
    
    // Trouver le rôle original de l'utilisateur
    final user = state.users.firstWhere((u) => u.id == event.userId);
    
    // Si le nouveau rôle est le même que l'original, retirer du pending
    if (user.typeUtilisateur == event.newRole) {
      newChanges.remove(event.userId);
    } else {
      newChanges[event.userId] = event.newRole;
    }
    
    emit(state.copyWith(pendingRoleChanges: newChanges));
  }

  Future<void> _onRoleChangesSubmitted(
    UsersRoleChangesSubmitted event,
    Emitter<UsersState> emit,
  ) async {
    if (state.pendingRoleChanges.isEmpty) return;

    emit(state.copyWith(isSubmitting: true));

    try {
      await _repository.updateMultipleRoles(state.pendingRoleChanges);
      
      // Mettre à jour les utilisateurs localement
      final updatedUsers = state.users.map((u) {
        if (state.pendingRoleChanges.containsKey(u.id)) {
          return u.copyWith(typeUtilisateur: state.pendingRoleChanges[u.id]);
        }
        return u;
      }).toList();

      emit(state.copyWith(
        users: updatedUsers,
        pendingRoleChanges: {},
        isSubmitting: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Erreur lors de l\'enregistrement des changements',
      ));
    }
  }

  void _onClearPendingChanges(
    UsersClearPendingChanges event,
    Emitter<UsersState> emit,
  ) {
    emit(state.copyWith(pendingRoleChanges: {}));
  }
}
