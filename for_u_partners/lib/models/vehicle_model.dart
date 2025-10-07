class Vehicle {
  final String id;
  final String model;
  final String immatriculation;
  final String? statut; // Ajout du champ statut pour le filtrage
  bool courseHeure;
  bool clim;

  Vehicle({
    required this.id,
    required this.model,
    required this.immatriculation,
    this.statut,
    this.courseHeure = false,
    this.clim = false,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      immatriculation: json['immatriculation']?.toString() ?? '',
      statut: json['statut']?.toString(),
      courseHeure: json['courseHeure'] as bool? ?? false,
      clim: json['clim'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model': model,
        'immatriculation': immatriculation,
        'statut': statut,
        'courseHeure': courseHeure,
        'clim': clim,
      };
}
