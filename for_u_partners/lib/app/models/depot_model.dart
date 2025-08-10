class DepotDemandModel {
  List<Depot>? data;

  DepotDemandModel({this.data});

  DepotDemandModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Depot>[];
      json['data'].forEach((v) {
        data!.add(new Depot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    client =
        json['client'] != null ? new Client.fromJson(json['client']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['numero'] = this.numero;
    data['date_rdv'] = this.dateRdv;
    data['statut'] = this.statut;
    if (this.client != null) {
      data['client'] = this.client!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nom'] = this.nom;
    data['prenom'] = this.prenom;
    return data;
  }
}
