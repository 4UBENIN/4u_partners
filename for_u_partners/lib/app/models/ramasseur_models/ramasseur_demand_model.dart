class RamasseurDemand {
  List<Demandes>? demandes;

  RamasseurDemand({this.demandes});

  RamasseurDemand.fromJson(Map<String, dynamic> json) {
    if (json['demandes'] != null) {
      demandes = <Demandes>[];
      json['demandes'].forEach((v) {
        demandes!.add(new Demandes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.demandes != null) {
      data['demandes'] = this.demandes!.map((v) => v.toJson()).toList();
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

  Demandes(
      {this.id,
      this.numero,
      this.adresseRamassage,
      this.adresseLivraison,
      this.dateDemande,
      this.statut});

  Demandes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    numero = json['numero'];
    adresseRamassage = json['adresse_ramassage'];
    adresseLivraison = json['adresse_livraison'];
    dateDemande = json['date_demande'];
    statut = json['statut'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['numero'] = this.numero;
    data['adresse_ramassage'] = this.adresseRamassage;
    data['adresse_livraison'] = this.adresseLivraison;
    data['date_demande'] = this.dateDemande;
    data['statut'] = this.statut;
    return data;
  }
}
