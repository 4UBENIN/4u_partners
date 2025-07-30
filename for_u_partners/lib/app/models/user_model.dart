class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String telephone;
  final String adresse;
  final String? photoProfil;
  final String? dateNaissance;
  final String? genre;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.telephone,
    required this.adresse,
    this.photoProfil,
    this.dateNaissance,
    this.genre,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: json['role'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      photoProfil: json['photo_profil'],
      dateNaissance: json['date_naissance'],
      genre: json['genre'],
      isVerified: json['is_verified'] == 1,
    );
  }
}
