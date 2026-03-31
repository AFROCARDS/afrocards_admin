import 'package:afrocards_admin/core/network/api_client.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  // Stats globales du dashboard
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _apiClient.get('/admin/dashboard');

      if (response.data['success'] == true) {
        return DashboardStats.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la récupération des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }

  // Evolution des inscriptions par mois
  Future<List<UserEvolutionData>> getUsersEvolution({int months = 12}) async {
    try {
      final response = await _apiClient.get('/admin/stats/users-evolution', queryParameters: {
        'months': months,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => UserEvolutionData.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur getUsersEvolution: $e');
      return [];
    }
  }

  // Evolution des parties par jour
  Future<List<PartiesEvolutionData>> getPartiesEvolution({int days = 30}) async {
    try {
      final response = await _apiClient.get('/admin/stats/parties-evolution', queryParameters: {
        'days': days,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => PartiesEvolutionData.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur getPartiesEvolution: $e');
      return [];
    }
  }

  // Questions par catégorie
  Future<List<CategoryStats>> getQuestionsByCategory() async {
    try {
      final response = await _apiClient.get('/admin/stats/questions-by-category');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => CategoryStats.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur getQuestionsByCategory: $e');
      return [];
    }
  }

  // Top joueurs
  Future<List<TopPlayer>> getTopPlayers({int limit = 10}) async {
    try {
      final response = await _apiClient.get('/admin/stats/top-players', queryParameters: {
        'limit': limit,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => TopPlayer.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur getTopPlayers: $e');
      return [];
    }
  }

  // Stats signalements
  Future<SignalementsStats?> getSignalementsStats() async {
    try {
      final response = await _apiClient.get('/admin/stats/signalements');

      if (response.data['success'] == true) {
        return SignalementsStats.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Erreur getSignalementsStats: $e');
      return null;
    }
  }

  // Distribution utilisateurs par type
  Future<List<UserDistribution>> getUsersDistribution() async {
    try {
      final response = await _apiClient.get('/admin/stats/users-distribution');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => UserDistribution.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur getUsersDistribution: $e');
      return [];
    }
  }

  // Joueurs par pays
  Future<List<CountryStats>> getPlayersByCountry({int limit = 10}) async {
    try {
      final response = await _apiClient.get('/admin/stats/players-by-country', queryParameters: {
        'limit': limit,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => CountryStats.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur getPlayersByCountry: $e');
      return [];
    }
  }

  // Activité récente
  Future<RecentActivity?> getRecentActivity({int limit = 10}) async {
    try {
      final response = await _apiClient.get('/admin/stats/recent-activity', queryParameters: {
        'limit': limit,
      });

      if (response.data['success'] == true) {
        return RecentActivity.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Erreur getRecentActivity: $e');
      return null;
    }
  }

  // Stats challenges sponsorisés
  Future<ChallengesSponsorisesStats?> getChallengesSponsorisesStats() async {
    try {
      final response = await _apiClient.get('/admin/stats/challenges-sponsorises');

      if (response.data['success'] == true) {
        return ChallengesSponsorisesStats.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Erreur getChallengesSponsorisesStats: $e');
      return null;
    }
  }
}
