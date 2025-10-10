class Vehicle {
  final String id;
  final String model;
  final String marque; // Marque du véhicule
  final String immatriculation;
  final String? statut; // Ajout du champ statut pour le filtrage
  final String? categorie; // Catégorie du véhicule (ex: standard, premium)
  final String? couleur; // Couleur du véhicule
  bool courseHeure;
  bool clim;
  bool? basic;
  bool? premium;

  Vehicle({
    required this.id,
    required this.model,
    required this.marque,
    required this.immatriculation,
    this.statut,
    this.categorie,
    this.couleur,
    this.courseHeure = false,
    this.clim = false, 
    this.basic,
    this.premium,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      marque: json['marque']?.toString() ?? '',
      immatriculation: json['immatriculation']?.toString() ?? '',
      statut: json['statut']?.toString(),
      categorie: json['categorie']?.toString() ?? 'standard',
      couleur: json['couleur']?.toString() ?? 'Noire',
      courseHeure: json['courseHeure'] as bool? ?? false,
      clim: json['clim'] as bool? ?? false,
      basic: json['basic'] as bool? ?? false,
      premium: json['premium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model': model,
        'marque': marque,
        'immatriculation': immatriculation,
        'statut': statut,
        'categorie': categorie,
        'couleur': couleur,
        'courseHeure': courseHeure,
        'clim': clim,
      };
}
