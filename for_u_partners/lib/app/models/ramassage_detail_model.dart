// ramassage_detail_model.dart
class RamassageDetail {
  int? id;
  String? numero;
  ClientDetail? client;
  String? dateRamassage;
  String? adresseRamassage;
  String? adresseLivraison;
  double? montant;
  String? statut;
  Ramasseur? ramasseur;
  List<DetailItem>? details;
  List<ServiceComplementaire>? servicesComplementaires;

  RamassageDetail({
    this.id,
    this.numero,
    this.client,
    this.dateRamassage,
    this.adresseRamassage,
    this.adresseLivraison,
    this.montant,
    this.statut,
    this.ramasseur,
    this.details,
    this.servicesComplementaires,
  });

  RamassageDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString());
    numero = json['numero'];
    client =
        json['client'] != null ? ClientDetail.fromJson(json['client']) : null;
    dateRamassage = json['date_ramassage'];
    adresseRamassage = json['adresse_ramassage'];
    adresseLivraison = json['adresse_livraison'];

    montant = json['montant'] != null
        ? double.tryParse(json['montant'].toString())
        : null;

    statut = json['statut'];
    ramasseur = json['ramasseur'] != null
        ? Ramasseur.fromJson(json['ramasseur'])
        : null;

    if (json['details'] != null) {
      details = <DetailItem>[];
      json['details'].forEach((v) {
        details!.add(DetailItem.fromJson(v));
      });
    }

    if (json['services_complementaires'] != null) {
      servicesComplementaires = <ServiceComplementaire>[];
      json['services_complementaires'].forEach((v) {
        servicesComplementaires!.add(ServiceComplementaire.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['numero'] = numero;
    if (client != null) {
      data['client'] = client!.toJson();
    }
    data['date_ramassage'] = dateRamassage;
    data['adresse_ramassage'] = adresseRamassage;
    data['adresse_livraison'] = adresseLivraison;
    data['montant'] = montant;
    data['statut'] = statut;
    if (ramasseur != null) {
      data['ramasseur'] = ramasseur!.toJson();
    }
    if (details != null) {
      data['details'] = details!.map((v) => v.toJson()).toList();
    }
    if (servicesComplementaires != null) {
      data['services_complementaires'] =
          servicesComplementaires!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ClientDetail {
  String? nom;
  String? prenom;
  String? telephone;
  String? email;

  ClientDetail({this.nom, this.prenom, this.telephone, this.email});

  ClientDetail.fromJson(Map<String, dynamic> json) {
    nom = json['nom'];
    prenom = json['prenom'];
    telephone = json['telephone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['nom'] = nom;
    data['prenom'] = prenom;
    data['telephone'] = telephone;
    data['email'] = email;
    return data;
  }
}

class Ramasseur {
  String? nom;
  String? prenom;
  String? telephone;

  Ramasseur({this.nom, this.prenom, this.telephone});

  Ramasseur.fromJson(Map<String, dynamic> json) {
    nom = json['nom'];
    prenom = json['prenom'];
    telephone = json['telephone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['nom'] = nom;
    data['prenom'] = prenom;
    data['telephone'] = telephone;
    return data;
  }
}

class DetailItem {
  String? libelle;
  String? typeLavage;
  double? quantite;
  double? montant;

  DetailItem({this.libelle, this.typeLavage, this.quantite, this.montant});

  DetailItem.fromJson(Map<String, dynamic> json) {
    libelle = json['libelle'];
    typeLavage = json['type_lavage'];

    quantite = json['quantite'] != null
        ? double.tryParse(json['quantite'].toString())
        : null;

    montant = json['montant'] != null
        ? double.tryParse(json['montant'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['libelle'] = libelle;
    data['type_lavage'] = typeLavage;
    data['quantite'] = quantite;
    data['montant'] = montant;
    return data;
  }
}

class ServiceComplementaire {
  String? libelle;
  double? montant;

  ServiceComplementaire({this.libelle, this.montant});

  ServiceComplementaire.fromJson(Map<String, dynamic> json) {
    libelle = json['libelle'];
    montant = json['montant'] != null
        ? double.tryParse(json['montant'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['libelle'] = libelle;
    data['montant'] = montant;
    return data;
  }
}
