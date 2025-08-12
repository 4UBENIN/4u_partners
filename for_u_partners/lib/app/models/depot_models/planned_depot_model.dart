class PlannedDepotModel {
  String? message;
  String? statut;

  PlannedDepotModel({this.message, this.statut});

  PlannedDepotModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statut = json['statut'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['statut'] = this.statut;
    return data;
  }
}