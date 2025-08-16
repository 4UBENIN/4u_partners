class WalletModel {
  int? solde;

  WalletModel({this.solde});

  WalletModel.fromJson(Map<String, dynamic> json) {
    solde = json['solde'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['solde'] = solde;
    return data;
  }
}
