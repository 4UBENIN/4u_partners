class RamassageStatutModel {
  String? message;
  String? statut;
  Demande? demande;

  RamassageStatutModel({this.message, this.statut, this.demande});

  RamassageStatutModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statut = json['statut'];
    demande =
        json['demande'] != null ? Demande.fromJson(json['demande']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['statut'] = statut;
    if (demande != null) {
      data['demande'] = demande!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['statut'] = statut;
    return data;
  }
}
