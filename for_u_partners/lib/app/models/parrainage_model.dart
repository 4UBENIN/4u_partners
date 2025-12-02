class ParrainageModel {
  int? id;
  int? montant;
  String? status;
  bool? conducteurRembourse;
  String? createdAt;
  String? updatedAt;

  ParrainageModel({
    this.id,
    this.montant,
    this.status,
    this.conducteurRembourse,
    this.createdAt,
    this.updatedAt,
  });

  ParrainageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    montant = json['montant'];
    status = json['status'];
    conducteurRembourse = json['conducteur_rembourse'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['montant'] = montant;
    data['status'] = status;
    data['conducteur_rembourse'] = conducteurRembourse;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  bool get canCollect => conducteurRembourse == false && montant != null && montant! > 0;
}
