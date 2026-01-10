class RatingModel {
  final int id;
  final int auteurId;
  final String auteurType;
  final int cibleId;
  final String cibleType;
  final int serviceId;
  final int serviceObjectId;
  final int note;
  final String? commentaire;
  final String createdAt;
  final String updatedAt;

  RatingModel({
    required this.id,
    required this.auteurId,
    required this.auteurType,
    required this.cibleId,
    required this.cibleType,
    required this.serviceId,
    required this.serviceObjectId,
    required this.note,
    this.commentaire,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      auteurId: json['auteur_id'],
      auteurType: json['auteur_type'],
      cibleId: json['cible_id'],
      cibleType: json['cible_type'],
      serviceId: json['service_id'],
      serviceObjectId: json['service_object_id'],
      note: json['note'],
      commentaire: json['commentaire'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_object_id': serviceObjectId,
      'note': note,
      'commentaire': commentaire,
    };
  }
}
