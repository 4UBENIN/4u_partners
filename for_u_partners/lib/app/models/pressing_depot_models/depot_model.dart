class DepotDemandModel {
  List<Depot>? data;

  DepotDemandModel({this.data});

  DepotDemandModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Depot>[];
      json['data'].forEach((v) {
        data!.add(Depot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Depot {
  int? id;
  String? numero;
  String? dateRdv;
  String? statut;
  Client? client;

  Depot({this.id, this.numero, this.dateRdv, this.statut, this.client});

  Depot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    numero = json['numero'];
    dateRdv = json['date_rdv'];
    statut = json['statut'];
    client = json['client'] != null ? Client.fromJson(json['client']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['numero'] = numero;
    data['date_rdv'] = dateRdv;
    data['statut'] = statut;
    if (client != null) {
      data['client'] = client!.toJson();
    }
    return data;
  }
}

class Client {
  int? id;
  String? nom;
  String? prenom;

  Client({this.id, this.nom, this.prenom});

  Client.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    prenom = json['prenom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nom'] = nom;
    data['prenom'] = prenom;
    return data;
  }
}
