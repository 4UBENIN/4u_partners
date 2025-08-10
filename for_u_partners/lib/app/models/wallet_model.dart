class WalletModel {
  int? solde;

  WalletModel({this.solde});

  WalletModel.fromJson(Map<String, dynamic> json) {
    solde = json['solde'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['solde'] = this.solde;
    return data;
  }
}
