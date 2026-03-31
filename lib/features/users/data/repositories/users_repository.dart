import 'package:afrocards_admin/core/network/api_client.dart';
import 'package:afrocards_admin/features/users/data/models/user_admin_model.dart';

class UsersRepository {
  final ApiClient _apiClient;

  UsersRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Récupérer la liste des utilisateurs avec pagination et filtres
  Future<UsersResponse> getUsers({
    int page = 1,
    int limit = 20,
    String? type, // admin, joueur, partenaire, moderateur
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get('/admin/users', queryParameters: queryParams);
      return UsersResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Erreur getUsers: $e');
      rethrow;
    }
  }

  // Récupérer un utilisateur par ID
  Future<UserAdmin> getUserById(int userId) async {
    try {
      final response = await _apiClient.get('/admin/users/$userId');
      final data = response.data as Map<String, dynamic>;
      return UserAdmin.fromJson(data['data']);
    } catch (e) {
      print('Erreur getUserById: $e');
      rethrow;
    }
  }

  // Modifier le rôle d'un utilisateur
  Future<void> updateUserRole(int userId, String newRole) async {
    try {
      await _apiClient.put('/admin/users/$userId/role', data: {'role': newRole});
    } catch (e) {
      print('Erreur updateUserRole: $e');
      rethrow;
    }
  }

  // Modifier le statut d'un utilisateur (actif, suspendu, supprimé)
  Future<void> updateUserStatus(int userId, String newStatus) async {
    try {
      await _apiClient.put('/admin/users/$userId/status', data: {'statut': newStatus});
    } catch (e) {
      print('Erreur updateUserStatus: $e');
      rethrow;
    }
  }

  // Supprimer un utilisateur (soft delete via statut)
  Future<void> deleteUser(int userId) async {
    try {
      await _apiClient.put('/admin/users/$userId/status', data: {'statut': 'supprime'});
    } catch (e) {
      print('Erreur deleteUser: $e');
      rethrow;
    }
  }

  // Mettre à jour plusieurs rôles en batch
  Future<void> updateMultipleRoles(Map<int, String> roleChanges) async {
    try {
      // On fait les appels séquentiellement pour éviter les problèmes
      for (final entry in roleChanges.entries) {
        await updateUserRole(entry.key, entry.value);
      }
    } catch (e) {
      print('Erreur updateMultipleRoles: $e');
      rethrow;
    }
  }
}
