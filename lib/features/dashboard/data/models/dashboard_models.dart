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

// Evolution des inscriptions par mois
class UserEvolutionData {
  final String mois;
  final int annee;
  final String label;
  final int inscriptions;

  UserEvolutionData({
    required this.mois,
    required this.annee,
    required this.label,
    required this.inscriptions,
  });

  factory UserEvolutionData.fromJson(Map<String, dynamic> json) {
    return UserEvolutionData(
      mois: json['mois'] ?? '',
      annee: json['annee'] ?? 0,
      label: json['label'] ?? '',
      inscriptions: json['inscriptions'] ?? 0,
    );
  }
}

// Evolution des parties par jour
class PartiesEvolutionData {
  final String date;
  final int jour;
  final int parties;

  PartiesEvolutionData({
    required this.date,
    required this.jour,
    required this.parties,
  });

  factory PartiesEvolutionData.fromJson(Map<String, dynamic> json) {
    return PartiesEvolutionData(
      date: json['date'] ?? '',
      jour: json['jour'] ?? 0,
      parties: json['parties'] ?? 0,
    );
  }
}

// Questions par catégorie
class CategoryStats {
  final int id;
  final String nom;
  final String couleur;
  final String? icone;
  final int questions;

  CategoryStats({
    required this.id,
    required this.nom,
    required this.couleur,
    this.icone,
    required this.questions,
  });

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      couleur: json['couleur'] ?? '#4CAF50',
      icone: json['icone'],
      questions: json['questions'] ?? 0,
    );
  }
}

// Top joueurs
class TopPlayer {
  final int rang;
  final int id;
  final String pseudo;
  final String? avatar;
  final int score;
  final int niveau;
  final int partiesJouees;
  final int partiesGagnees;
  final int tauxVictoire;

  TopPlayer({
    required this.rang,
    required this.id,
    required this.pseudo,
    this.avatar,
    required this.score,
    required this.niveau,
    required this.partiesJouees,
    required this.partiesGagnees,
    required this.tauxVictoire,
  });

  factory TopPlayer.fromJson(Map<String, dynamic> json) {
    return TopPlayer(
      rang: json['rang'] ?? 0,
      id: json['id'] ?? 0,
      pseudo: json['pseudo'] ?? 'Anonyme',
      avatar: json['avatar'],
      score: json['score'] ?? 0,
      niveau: json['niveau'] ?? 1,
      partiesJouees: json['partiesJouees'] ?? 0,
      partiesGagnees: json['partiesGagnees'] ?? 0,
      tauxVictoire: json['tauxVictoire'] ?? 0,
    );
  }
}

// Distribution utilisateurs par type
class UserDistribution {
  final String type;
  final int count;
  final String couleur;

  UserDistribution({
    required this.type,
    required this.count,
    required this.couleur,
  });

  factory UserDistribution.fromJson(Map<String, dynamic> json) {
    return UserDistribution(
      type: json['type'] ?? '',
      count: json['count'] ?? 0,
      couleur: json['couleur'] ?? '#9E9E9E',
    );
  }
}

// Joueurs par pays
class CountryStats {
  final String pays;
  final int joueurs;

  CountryStats({
    required this.pays,
    required this.joueurs,
  });

  factory CountryStats.fromJson(Map<String, dynamic> json) {
    return CountryStats(
      pays: json['pays'] ?? 'Inconnu',
      joueurs: json['joueurs'] ?? 0,
    );
  }
}

// Signalements stats
class SignalementsStats {
  final SignalementDetail utilisateurs;
  final SignalementDetail questions;
  final int totalEnAttente;

  SignalementsStats({
    required this.utilisateurs,
    required this.questions,
    required this.totalEnAttente,
  });

  factory SignalementsStats.fromJson(Map<String, dynamic> json) {
    return SignalementsStats(
      utilisateurs: SignalementDetail.fromJson(json['utilisateurs'] ?? {}),
      questions: SignalementDetail.fromJson(json['questions'] ?? {}),
      totalEnAttente: json['totalEnAttente'] ?? 0,
    );
  }
}

class SignalementDetail {
  final int enAttente;
  final int traite;
  final int rejete;
  final int total;

  SignalementDetail({
    required this.enAttente,
    required this.traite,
    required this.rejete,
    required this.total,
  });

  factory SignalementDetail.fromJson(Map<String, dynamic> json) {
    return SignalementDetail(
      enAttente: json['en_attente'] ?? 0,
      traite: json['traite'] ?? 0,
      rejete: json['rejete'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

// Challenges sponsorisés stats
class ChallengesSponsorisesStats {
  final int total;
  final int actifs;
  final int termines;
  final int aVenir;
  final int partenairesActifs;

  ChallengesSponsorisesStats({
    required this.total,
    required this.actifs,
    required this.termines,
    required this.aVenir,
    required this.partenairesActifs,
  });

  factory ChallengesSponsorisesStats.fromJson(Map<String, dynamic> json) {
    return ChallengesSponsorisesStats(
      total: json['total'] ?? 0,
      actifs: json['actifs'] ?? 0,
      termines: json['termines'] ?? 0,
      aVenir: json['aVenir'] ?? 0,
      partenairesActifs: json['partenairesActifs'] ?? 0,
    );
  }
}

// Activité récente
class RecentActivity {
  final List<RecentInscription> inscriptions;
  final List<RecentPartie> parties;

  RecentActivity({
    required this.inscriptions,
    required this.parties,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      inscriptions: (json['inscriptions'] as List?)
              ?.map((e) => RecentInscription.fromJson(e))
              .toList() ??
          [],
      parties: (json['parties'] as List?)
              ?.map((e) => RecentPartie.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RecentInscription {
  final int id;
  final String nom;
  final String email;
  final String type;
  final String? pseudo;
  final String? avatar;
  final DateTime date;

  RecentInscription({
    required this.id,
    required this.nom,
    required this.email,
    required this.type,
    this.pseudo,
    this.avatar,
    required this.date,
  });

  factory RecentInscription.fromJson(Map<String, dynamic> json) {
    return RecentInscription(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      type: json['type'] ?? 'joueur',
      pseudo: json['pseudo'],
      avatar: json['avatar'],
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}

class RecentPartie {
  final int id;
  final String? pseudo;
  final String? avatar;
  final int score;
  final DateTime date;

  RecentPartie({
    required this.id,
    this.pseudo,
    this.avatar,
    required this.score,
    required this.date,
  });

  factory RecentPartie.fromJson(Map<String, dynamic> json) {
    return RecentPartie(
      id: json['id'] ?? 0,
      pseudo: json['pseudo'],
      avatar: json['avatar'],
      score: json['score'] ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}
