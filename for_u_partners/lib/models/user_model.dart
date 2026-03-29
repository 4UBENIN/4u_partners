class UserModel {
  final int id;
  final String? fcmToken;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String telephone;
  final String? adresse;
  final String? photoProfil;
  final String? dateNaissance;
  final String? genre;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.fcmToken,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.telephone,
    this.adresse,
    this.photoProfil,
    this.dateNaissance,
    this.genre,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fcmToken: json['fcm_token'] as String?,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      telephone: json['telephone'] as String,
      adresse: json['adresse'] as String?,
      photoProfil: json['photo_profil'] as String?,
      dateNaissance: json['date_naissance'] as String?,
      genre: json['genre'] as String?,
      isVerified: json['is_verified'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      if (adresse != null) 'adresse': adresse,
      if (dateNaissance != null) 'date_naissance': dateNaissance,
      if (genre != null) 'genre': genre,
    };
  }

  UserModel copyWith({
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? adresse,
    String? dateNaissance,
    String? genre,
  }) {
    return UserModel(
      id: id,
      fcmToken: fcmToken,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      role: role,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      photoProfil: photoProfil,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      genre: genre ?? this.genre,
      isVerified: isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
