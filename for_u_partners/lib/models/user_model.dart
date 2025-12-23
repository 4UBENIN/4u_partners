// Ajoutez ce champ à votre UserModel existant
class UserModel {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String? adresse;
  final String? dateNaissance;
  final String? genre;
  final String? photoUrl; 

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    this.adresse,
    this.dateNaissance,
    this.genre,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Clean photo URL by removing /storage if present
    String? cleanPhotoUrl = json['photo_url'];
    if (cleanPhotoUrl != null) {
      cleanPhotoUrl = cleanPhotoUrl.replaceAll('/storage', '');
    }

    return UserModel(
      id: json['id'].toString(),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      adresse: json['adresse'],
      dateNaissance: json['date_naissance'],
      genre: json['genre'],
      photoUrl: cleanPhotoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'date_naissance': dateNaissance,
      'genre': genre,
      'photo_url': photoUrl, 
    };
  }
}