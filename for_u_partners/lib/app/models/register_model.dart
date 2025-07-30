class VehiculeModel {
  final String type;
  final String marque;
  final String modele;
  final String immatriculation;
  final int nombrePlaces;
  final String couleur;
  final String categorie;
  final String? cartegrise;
  final String? assurance;
  final int annee;

  VehiculeModel({
    required this.type,
    required this.marque,
    required this.modele,
    required this.immatriculation,
    required this.nombrePlaces,
    required this.couleur,
    required this.categorie,
    this.cartegrise,
    this.assurance,
    required this.annee,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'marque': marque,
        'modele': modele,
        'immatriculation': immatriculation,
        'nombre_places': nombrePlaces,
        'couleur': couleur,
        'categorie': categorie,
        'carte_grise': cartegrise,
        'assurance': assurance,
        'annee': annee,
      };
}

class RegistrationModel {
  final String type; // conducteur | garage | pressing
  final String telephone;
  final String email;
  final String code;
  final String motDePasse;
  final String motDePasseConfirmation;
  final String nom;
  final String adresse;
  final String? prenom;
  final String? genre;
  final String? dateNaissance; // Format: YYYY-MM-DD
  final String? numeroPermis;
  final String? dateExpirationPermis; // Format: YYYY-MM-DD
  final String? documentIdentite; // peut être un path ou une URL de fichier
  final int? possedeVehicule; // 1 = oui, 0 = non
  final int? typeConducteurId;
  final VehiculeModel? vehicule;

  RegistrationModel({
    required this.type,
    required this.telephone,
    required this.email,
    required this.code,
    required this.motDePasse,
    required this.motDePasseConfirmation,
    required this.nom,
    required this.adresse,
    this.prenom,
    this.genre,
    this.dateNaissance,
    this.numeroPermis,
    this.dateExpirationPermis,
    this.documentIdentite,
    this.possedeVehicule,
    this.typeConducteurId,
    this.vehicule,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'telephone': telephone,
      'email': email,
      'code': code,
      'mot_de_passe': motDePasse,
      'mot_de_passe_confirmation': motDePasseConfirmation,
      'nom': nom,
      'adresse': adresse,
      if (prenom != null) 'prenom': prenom,
      if (genre != null) 'genre': genre,
      if (dateNaissance != null) 'date_naissance': dateNaissance,
      if (numeroPermis != null) 'numero_permis': numeroPermis,
      if (dateExpirationPermis != null)
        'date_expiration_permis': dateExpirationPermis,
      if (documentIdentite != null) 'document_identite': documentIdentite,
      if (possedeVehicule != null) 'possedevehicule': possedeVehicule,
      if (typeConducteurId != null) 'type_conducteur_id': typeConducteurId,
      if (vehicule != null) 'vehicule': vehicule!.toJson(),
    };
  }
}
