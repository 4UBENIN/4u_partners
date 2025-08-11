class RamassageStatutModel {
  String? message;
  String? statut;
  Demande? demande;

  RamassageStatutModel({this.message, this.statut, this.demande});

  RamassageStatutModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statut = json['statut'];
    demande =
        json['demande'] != null ? new Demande.fromJson(json['demande']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['statut'] = this.statut;
    if (this.demande != null) {
      data['demande'] = this.demande!.toJson();
    }
    return data;
  }
}

class Demande {
  int? id;
  String? statut;

  Demande({this.id, this.statut});

  Demande.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    statut = json['statut'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['statut'] = this.statut;
    return data;
  }
}
