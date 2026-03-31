// Modèle utilisateur pour l'admin
class UserAdmin {
  final int id;
  final String nom;
  final String email;
  final String typeUtilisateur; // admin, joueur, partenaire, moderateur
  final String statutCompte; // actif, suspendu, supprime
  final DateTime dateCreation;
  final JoueurInfo? joueur;

  UserAdmin({
    required this.id,
    required this.nom,
    required this.email,
    required this.typeUtilisateur,
    required this.statutCompte,
    required this.dateCreation,
    this.joueur,
  });

  factory UserAdmin.fromJson(Map<String, dynamic> json) {
    return UserAdmin(
      id: json['idUtilisateur'] ?? json['id'] ?? 0,
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      typeUtilisateur: json['typeUtilisateur'] ?? 'joueur',
      statutCompte: json['statutCompte'] ?? 'actif',
      dateCreation: json['dateCreation'] != null 
          ? DateTime.parse(json['dateCreation']) 
          : DateTime.now(),
      joueur: json['Joueur'] != null ? JoueurInfo.fromJson(json['Joueur']) : null,
    );
  }

  String get displayName => joueur?.pseudo ?? nom;
  String get avatar => joueur?.avatar ?? '';
  String get pays => joueur?.pays ?? 'Non défini';
  int get niveau => joueur?.niveau ?? 0;
  int get xp => joueur?.xp ?? 0;
  int get partiesJouees => joueur?.partiesJouees ?? 0;
  int get partiesGagnees => joueur?.partiesGagnees ?? 0;
  int get ranking => joueur?.classement ?? 0;

  String get roleLabel {
    switch (typeUtilisateur) {
      case 'admin':
        return 'Administrateur';
      case 'moderateur':
        return 'Modérateur';
      case 'partenaire':
        return 'Partenaire';
      default:
        return 'Utilisateur';
    }
  }

  UserAdmin copyWith({
    int? id,
    String? nom,
    String? email,
    String? typeUtilisateur,
    String? statutCompte,
    DateTime? dateCreation,
    JoueurInfo? joueur,
  }) {
    return UserAdmin(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      typeUtilisateur: typeUtilisateur ?? this.typeUtilisateur,
      statutCompte: statutCompte ?? this.statutCompte,
      dateCreation: dateCreation ?? this.dateCreation,
      joueur: joueur ?? this.joueur,
    );
  }
}

class JoueurInfo {
  final int idJoueur;
  final String pseudo;
  final String? avatar;
  final int niveau;
  final int xp;
  final String pays;
  final int partiesJouees;
  final int partiesGagnees;
  final int classement;

  JoueurInfo({
    required this.idJoueur,
    required this.pseudo,
    this.avatar,
    required this.niveau,
    required this.xp,
    required this.pays,
    required this.partiesJouees,
    required this.partiesGagnees,
    required this.classement,
  });

  factory JoueurInfo.fromJson(Map<String, dynamic> json) {
    return JoueurInfo(
      idJoueur: json['idJoueur'] ?? 0,
      pseudo: json['pseudo'] ?? 'Anonyme',
      avatar: json['avatar'],
      niveau: json['niveau'] ?? 1,
      xp: json['xp'] ?? 0,
      pays: json['pays'] ?? 'Non défini',
      partiesJouees: json['partiesJouees'] ?? 0,
      partiesGagnees: json['partiesGagnees'] ?? 0,
      classement: json['classement'] ?? 0,
    );
  }
}

// Réponse paginée pour la liste des utilisateurs
class UsersResponse {
  final List<UserAdmin> users;
  final int total;
  final int totalPages;
  final int currentPage;

  UsersResponse({
    required this.users,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    return UsersResponse(
      users: (json['data'] as List<dynamic>?)
          ?.map((e) => UserAdmin.fromJson(e))
          .toList() ?? [],
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['currentPage'] ?? 1,
    );
  }
}

// Énumération des rôles disponibles (correspond à typeUtilisateur en BDD)
enum UserRole {
  joueur('joueur', 'Joueur'),
  moderateur('moderateur', 'Modérateur'), // Admin avec vue restreinte (pas d'édition/suppression)
  admin('admin', 'Administrateur'),
  partenaire('partenaire', 'Partenaire');

  final String value;
  final String label;
  const UserRole(this.value, this.label);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.joueur,
    );
  }

  /// Le modérateur peut voir mais pas éditer/supprimer
  bool get canEdit => this == UserRole.admin;
  bool get canDelete => this == UserRole.admin;
  bool get canChangeRoles => this == UserRole.admin;
}

// Énumération des statuts
enum UserStatus {
  actif('actif', 'Actif'),
  suspendu('suspendu', 'Suspendu'),
  supprime('supprime', 'Supprimé');

  final String value;
  final String label;
  const UserStatus(this.value, this.label);

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserStatus.actif,
    );
  }
}
