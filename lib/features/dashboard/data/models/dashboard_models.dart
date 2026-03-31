class DashboardStats {
  final GlobalStats global;
  final MonthlyStats mensuel;

  DashboardStats({
    required this.global,
    required this.mensuel,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      global: GlobalStats.fromJson(json['global'] ?? {}),
      mensuel: MonthlyStats.fromJson(json['mensuel'] ?? {}),
    );
  }
}

class GlobalStats {
  final int utilisateurs;
  final int joueurs;
  final int quiz;
  final int partiesJouees;
  final int signalements;

  GlobalStats({
    required this.utilisateurs,
    required this.joueurs,
    required this.quiz,
    required this.partiesJouees,
    this.signalements = 0,
  });

  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    return GlobalStats(
      utilisateurs: json['utilisateurs'] ?? 0,
      joueurs: json['joueurs'] ?? 0,
      quiz: json['quiz'] ?? 0,
      partiesJouees: json['partiesJouees'] ?? 0,
      signalements: json['signalements'] ?? 0,
    );
  }
}

class MonthlyStats {
  final int nouveauxInscrits;

  MonthlyStats({
    required this.nouveauxInscrits,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      nouveauxInscrits: json['nouveauxInscrits'] ?? 0,
    );
  }
}

class ChartDataPoint {
  final DateTime date;
  final double value;
  final String? label;

  ChartDataPoint({
    required this.date,
    required this.value,
    this.label,
  });
}

class CategoryChartData {
  final String category;
  final double value;
  final String? color;

  CategoryChartData({
    required this.category,
    required this.value,
    this.color,
  });
}
