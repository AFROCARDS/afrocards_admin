import 'package:afrocards_admin/core/network/api_client.dart';
import 'package:afrocards_admin/features/auth/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/connexion', data: {
        'email': email,
        'motDePasse': password,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final user = UserModel.fromJson({
          ...data['utilisateur'],
          'profil': data['profil'],
        });

        // Vérifier que c'est un admin ou partenaire
        if (user.typeUtilisateur != 'admin' && user.typeUtilisateur != 'partenaire') {
          throw Exception('Accès refusé. Seuls les administrateurs et partenaires peuvent accéder à cette interface.');
        }

        // Sauvegarder le token
        _apiClient.setAuthToken(token);

        return AuthResult(user: user, token: token);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      if (e.toString().contains('Accès refusé')) {
        rethrow;
      }
      // Afficher l'erreur réelle pour le debug
      print('Erreur login: $e');
      rethrow;
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get('/auth/profil');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return UserModel.fromJson({
          ...data['utilisateur'],
          'profil': data['profil'],
        });
      } else {
        throw Exception('Erreur lors de la récupération du profil');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/deconnexion');
    } finally {
      _apiClient.clearAuthToken();
    }
  }
}

class AuthResult {
  final UserModel user;
  final String token;

  AuthResult({required this.user, required this.token});
}
