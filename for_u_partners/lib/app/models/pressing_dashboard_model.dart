class PressingResponse {
  final Pressing pressing;
  final String message;

  PressingResponse({required this.pressing, required this.message});

  factory PressingResponse.fromJson(Map<String, dynamic> json) {
    return PressingResponse(
      pressing: Pressing.fromJson(json['pressing']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pressing': pressing.toJson(),
      'message': message,
    };
  }
}

class Pressing {
  final int id;
  final String nom;
  final String email;
  final String telephone;
  final String adresse;
  final String statutValidation;
  final DateTime createdAt;

  Pressing({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.statutValidation,
    required this.createdAt,
  });

  factory Pressing.fromJson(Map<String, dynamic> json) {
    return Pressing(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      statutValidation: json['statut_validation'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'statut_validation': statutValidation,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
