class PickersDemandResponse {
  final List<Demand> demandes;

  PickersDemandResponse({required this.demandes});

  factory PickersDemandResponse.fromJson(Map<String, dynamic> json) {
    return PickersDemandResponse(
      demandes: List<Demand>.from(
        json['demandes'].map((x) => Demand.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'demandes': List<dynamic>.from(demandes.map((x) => x.toJson())),
      };
}

class Demand {
  final int id;
  final String numero;
  final String adresseRamassage;
  final String adresseLivraison;
  final DateTime dateDemande;
  final String statut;

  Demand({
    required this.id,
    required this.numero,
    required this.adresseRamassage,
    required this.adresseLivraison,
    required this.dateDemande,
    required this.statut,
  });

  factory Demand.fromJson(Map<String, dynamic> json) => Demand(
        id: json['id'],
        numero: json['numero'],
        adresseRamassage: json['adresse_ramassage'],
        adresseLivraison: json['adresse_livraison'],
        dateDemande: DateTime.parse(json['date_demande']),
        statut: json['statut'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'adresse_ramassage': adresseRamassage,
        'adresse_livraison': adresseLivraison,
        'date_demande': dateDemande.toIso8601String(),
        'statut': statut,
      };
}