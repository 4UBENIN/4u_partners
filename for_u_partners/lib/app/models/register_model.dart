import 'dart:io';

class VehiculeModel {
  final String? type;
  final String? marque;
  final String? modele;
  final String? immatriculation;
  final int? nombrePlaces;
  final String? couleur;
  final String? categorie;
  final File? cartegrise; // fichier image ou PDF
  final File? assurance; // fichier image ou PDF
  final File? permis; // fichier image ou PDF
  final int? annee;

  VehiculeModel({
    this.type,
    this.marque,
    this.modele,
    this.immatriculation,
    this.nombrePlaces,
    this.couleur,
    this.categorie,
    this.cartegrise,
    this.assurance,
    this.permis,
    this.annee,
  });

  // Ne pas utiliser toJson() pour envoyer les fichiers
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
  final String? dateNaissance; // YYYY-MM-DD
  final String? numeroPermis;
  final String? dateExpirationPermis; // YYYY-MM-DD
  final File? documentIdentite; // fichier image ou PDF
  final int? possedeVehicule; // 1 ou 0
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

  // Pas de toJson() direct pour envoyer les fichiers
}
