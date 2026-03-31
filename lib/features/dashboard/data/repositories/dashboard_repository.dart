import 'package:afrocards_admin/core/network/api_client.dart';
import 'package:afrocards_admin/features/dashboard/data/models/dashboard_models.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

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

  Future<List<ChartDataPoint>> getActiveUsersEvolution({int days = 30}) async {
    try {
      // Endpoint personnalisé pour l'évolution des utilisateurs actifs
      final response = await _apiClient.get('/admin/stats/users-evolution', queryParameters: {
        'days': days,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => ChartDataPoint(
          date: DateTime.parse(item['date']),
          value: (item['count'] as num).toDouble(),
        )).toList();
      }
      
      // Données de fallback si l'endpoint n'existe pas encore
      return _generateMockEvolutionData(days);
    } catch (e) {
      // Retourner des données mock en cas d'erreur
      return _generateMockEvolutionData(days);
    }
  }

  Future<List<CategoryChartData>> getQuizByCategory({int days = 30}) async {
    try {
      final response = await _apiClient.get('/admin/stats/quiz-by-category', queryParameters: {
        'days': days,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => CategoryChartData(
          category: item['category'],
          value: (item['count'] as num).toDouble(),
        )).toList();
      }
      
      return _generateMockCategoryData();
    } catch (e) {
      return _generateMockCategoryData();
    }
  }

  Future<int> getSignalementsCount() async {
    try {
      final response = await _apiClient.get('/admin/signalements/count');

      if (response.data['success'] == true) {
        return response.data['data']['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Données mock pour le développement
  List<ChartDataPoint> _generateMockEvolutionData(int days) {
    final now = DateTime.now();
    final data = <ChartDataPoint>[];
    
    for (int i = days; i >= 0; i -= 7) {
      final date = now.subtract(Duration(days: i));
      final value = 1000 + (i * 50) + (i % 3 * 200);
      data.add(ChartDataPoint(date: date, value: value.toDouble()));
    }
    
    return data;
  }

  List<CategoryChartData> _generateMockCategoryData() {
    return [
      CategoryChartData(category: 'Histoire', value: 15000),
      CategoryChartData(category: 'Géographie', value: 22000),
      CategoryChartData(category: 'Culture', value: 44500),
    ];
  }
}
