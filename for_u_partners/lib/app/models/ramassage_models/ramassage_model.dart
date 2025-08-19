class RamassageDemandModel {
  List<Ramassage>? ramassages;

  RamassageDemandModel({this.ramassages});

  RamassageDemandModel.fromJson(Map<String, dynamic> json) {
    if (json['ramassages'] != null) {
      ramassages = <Ramassage>[];
      json['ramassages'].forEach((v) {
        ramassages!.add(Ramassage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (ramassages != null) {
      data['ramassages'] = ramassages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Ramassage {
  int? id;
  String? numero;
  Client? client;
  String? dateRamassage;
  String? statut;

  Ramassage(
      {this.id, this.numero, this.client, this.dateRamassage, this.statut});

  Ramassage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    numero = json['numero'];
    client = json['client'] != null ? Client.fromJson(json['client']) : null;
    dateRamassage = json['date_ramassage'];
    statut = json['statut'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['numero'] = numero;
    if (client != null) {
      data['client'] = client!.toJson();
    }
    data['date_ramassage'] = dateRamassage;
    data['statut'] = statut;
    return data;
  }
}

class Client {
  String? nom;
  String? prenom;

  Client({this.nom, this.prenom});

  Client.fromJson(Map<String, dynamic> json) {
    nom = json['nom'];
    prenom = json['prenom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nom'] = nom;
    data['prenom'] = prenom;
    return data;
  }
}
