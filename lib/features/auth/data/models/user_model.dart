class UserModel {
  final int id;
  final String nom;
  final String email;
  final String typeUtilisateur;
  final String? statutCompte;
  final String? avatarURL;
  final DateTime? dateCreation;
  final JoueurProfile? joueur;
  final PartenaireProfile? partenaire;

  UserModel({
    required this.id,
    required this.nom,
    required this.email,
    required this.typeUtilisateur,
    this.statutCompte,
    this.avatarURL,
    this.dateCreation,
    this.joueur,
    this.partenaire,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['idUtilisateur'] ?? json['id'],
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      typeUtilisateur: json['typeUtilisateur'] ?? json['type'] ?? 'joueur',
      statutCompte: json['statutCompte'],
      avatarURL: json['avatarURL'],
      dateCreation: json['dateCreation'] != null 
          ? DateTime.parse(json['dateCreation']) 
          : null,
      joueur: json['Joueur'] != null || json['profil'] != null
          ? JoueurProfile.fromJson(json['Joueur'] ?? json['profil'] ?? {})
          : null,
      partenaire: json['Partenaire'] != null 
          ? PartenaireProfile.fromJson(json['Partenaire']) 
          : null,
    );
  }

  bool get isAdmin => typeUtilisateur == 'admin';
  bool get isPartenaire => typeUtilisateur == 'partenaire';
  bool get isJoueur => typeUtilisateur == 'joueur';
  
  String get displayName {
    if (joueur?.pseudo != null && joueur!.pseudo!.isNotEmpty) {
      return joueur!.pseudo!;
    }
    return nom;
  }
}

class JoueurProfile {
  final int? idJoueur;
  final String? pseudo;
  final int? niveau;
  final String? pays;
  final String? avatarURL;
  final int? xpTotal;
  final int? coins;

  JoueurProfile({
    this.idJoueur,
    this.pseudo,
    this.niveau,
    this.pays,
    this.avatarURL,
    this.xpTotal,
    this.coins,
  });

  factory JoueurProfile.fromJson(Map<String, dynamic> json) {
    return JoueurProfile(
      idJoueur: json['idJoueur'] ?? json['id'],
      pseudo: json['pseudo'],
      niveau: json['niveau'],
      pays: json['pays'],
      avatarURL: json['avatarURL'],
      xpTotal: json['xpTotal'],
      coins: json['coins'],
    );
  }
}

class PartenaireProfile {
  final int? idPartenaire;
  final String? entreprise;
  final String? description;
  final String? logoURL;
  final bool? estActif;

  PartenaireProfile({
    this.idPartenaire,
    this.entreprise,
    this.description,
    this.logoURL,
    this.estActif,
  });

  factory PartenaireProfile.fromJson(Map<String, dynamic> json) {
    return PartenaireProfile(
      idPartenaire: json['idPartenaire'] ?? json['id'],
      entreprise: json['entreprise'],
      description: json['description'],
      logoURL: json['logoURL'],
      estActif: json['estActif'],
    );
  }
}
