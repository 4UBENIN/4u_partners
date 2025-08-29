class RamasseurDemand {
  List<Demandes>? demandes;

  RamasseurDemand({this.demandes});

  RamasseurDemand.fromJson(Map<String, dynamic> json) {
    if (json['demandes'] != null) {
      demandes = <Demandes>[];
      json['demandes'].forEach((v) {
        demandes!.add(Demandes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (demandes != null) {
      data['demandes'] = demandes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Demandes {
  int? id;
  String? numero;
  String? adresseRamassage;
  String? adresseLivraison;
  String? dateDemande;
  String? statut;
  String? latRamassage;
  String? lngRamassage;
  String? latLivraison;
  String? lngLivraison;
  dynamic pressing; // Can be null or a Map

  Demandes({
    this.id,
    this.numero,
    this.adresseRamassage,
    this.adresseLivraison,
    this.dateDemande,
    this.statut,
    this.latRamassage,
    this.lngRamassage,
    this.latLivraison,
    this.lngLivraison,
    this.pressing,
  });

  factory Demandes.fromJson(Map<String, dynamic> json) => Demandes(
        id: json['id'],
        numero: json['numero'],
        adresseRamassage: json['adresse_ramassage'],
        adresseLivraison: json['adresse_livraison'],
        dateDemande: json['date_demande'],
        statut: json['statut'],
        latRamassage: json['lat_ramassage']?.toString(),
        lngRamassage: json['lng_ramassage']?.toString(),
        latLivraison: json['lat_livraison']?.toString(),
        lngLivraison: json['lng_livraison']?.toString(),
        pressing: json['pressing'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'adresse_ramassage': adresseRamassage,
        'adresse_livraison': adresseLivraison,
        'date_demande': dateDemande,
        'statut': statut,
        'lat_ramassage': latRamassage,
        'lng_ramassage': lngRamassage,
        'lat_livraison': latLivraison,
        'lng_livraison': lngLivraison,
        'pressing': pressing,
      };
}
