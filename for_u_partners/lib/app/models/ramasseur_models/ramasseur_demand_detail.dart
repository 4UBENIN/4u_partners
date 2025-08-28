class RamasseurDemandDetail {
  int? demandeId;
  List<VetementsAuKilo>? vetementsAuKilo;
  List<VetementsSpeciaux>? vetementsSpeciaux;
  List<ServicesComplementaires>? servicesComplementaires;
  String? adresseRamassage;
  String? adressePressing;
  String? nomPressing;
  int? prixRamassage;
  String? message;

  RamasseurDemandDetail(
      {this.demandeId,
      this.vetementsAuKilo,
      this.vetementsSpeciaux,
      this.servicesComplementaires,
      this.adresseRamassage,
      this.adressePressing,
      this.nomPressing,
      this.prixRamassage,
      this.message});

  RamasseurDemandDetail.fromJson(Map<String, dynamic> json) {
    demandeId = json['demande_id'];
    if (json['vetements_au_kilo'] != null) {
      vetementsAuKilo = <VetementsAuKilo>[];
      json['vetements_au_kilo'].forEach((v) {
        vetementsAuKilo!.add(new VetementsAuKilo.fromJson(v));
      });
    }
    if (json['vetements_speciaux'] != null) {
      vetementsSpeciaux = <VetementsSpeciaux>[];
      json['vetements_speciaux'].forEach((v) {
        vetementsSpeciaux!.add(new VetementsSpeciaux.fromJson(v));
      });
    }
    if (json['services_complementaires'] != null) {
      servicesComplementaires = <ServicesComplementaires>[];
      json['services_complementaires'].forEach((v) {
        servicesComplementaires!.add(new ServicesComplementaires.fromJson(v));
      });
    }
    adresseRamassage = json['adresse_ramassage'];
    adressePressing = json['adresse_pressing'];
    nomPressing = json['nom_pressing'];
    prixRamassage = json['prix_ramassage'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['demande_id'] = this.demandeId;
    if (this.vetementsAuKilo != null) {
      data['vetements_au_kilo'] =
          this.vetementsAuKilo!.map((v) => v.toJson()).toList();
    }
    if (this.vetementsSpeciaux != null) {
      data['vetements_speciaux'] =
          this.vetementsSpeciaux!.map((v) => v.toJson()).toList();
    }
    if (this.servicesComplementaires != null) {
      data['services_complementaires'] =
          this.servicesComplementaires!.map((v) => v.toJson()).toList();
    }
    data['adresse_ramassage'] = this.adresseRamassage;
    data['adresse_pressing'] = this.adressePressing;
    data['nom_pressing'] = this.nomPressing;
    data['prix_ramassage'] = this.prixRamassage;
    data['message'] = this.message;
    return data;
  }
}

class VetementsAuKilo {
  int? detailId;
  String? libelle;
  String? typeLavage;
  double? quantite;
  int? tarifUnitaire;

  VetementsAuKilo(
      {this.detailId,
      this.libelle,
      this.typeLavage,
      this.quantite,
      this.tarifUnitaire});

  VetementsAuKilo.fromJson(Map<String, dynamic> json) {
    try {
      // Conversion de detail_id
      if (json['detail_id'] != null) {
        if (json['detail_id'] is String) {
          detailId = int.tryParse(json['detail_id']) ?? 0;
        } else if (json['detail_id'] is num) {
          detailId = json['detail_id'].toInt();
        }
      }
      
      libelle = json['libelle']?.toString();
      typeLavage = json['type_lavage']?.toString();
      
      // Conversion de quantite
      if (json['quantite'] != null) {
        if (json['quantite'] is String) {
          quantite = double.tryParse(json['quantite']) ?? 0.0;
        } else if (json['quantite'] is num) {
          quantite = json['quantite'].toDouble();
        }
      }
      
      // Conversion de tarifUnitaire
      if (json['tarif_unitaire'] != null) {
        if (json['tarif_unitaire'] is String) {
          tarifUnitaire = int.tryParse(json['tarif_unitaire']) ?? 0;
        } else if (json['tarif_unitaire'] is num) {
          tarifUnitaire = json['tarif_unitaire'].toInt();
        }
      }
      
      print('✅ VetementsAuKilo.fromJson - Données parsées avec succès');
      print('   - detailId: $detailId');
      print('   - libelle: $libelle');
      print('   - typeLavage: $typeLavage');
      print('   - quantite: $quantite');
      print('   - tarifUnitaire: $tarifUnitaire');
      
    } catch (e, stackTrace) {
      print('❌ Erreur dans VetementsAuKilo.fromJson:');
      print('   - Erreur: $e');
      print('   - StackTrace: $stackTrace');
      print('   - Données reçues: $json');
      
      // Valeurs par défaut en cas d'erreur
      detailId = 0;
      libelle = '';
      typeLavage = '';
      quantite = 0.0;
      tarifUnitaire = 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['detail_id'] = this.detailId;
    data['libelle'] = this.libelle;
    data['type_lavage'] = this.typeLavage;
    data['quantite'] = this.quantite;
    data['tarif_unitaire'] = this.tarifUnitaire;
    return data;
  }
}

class VetementsSpeciaux {
  int? detailId;
  String? libelle;
  String? typeLavage;
  int? quantite;
  int? tarifUnitaire;

  VetementsSpeciaux(
      {this.detailId,
      this.libelle,
      this.typeLavage,
      this.quantite,
      this.tarifUnitaire});

  VetementsSpeciaux.fromJson(Map<String, dynamic> json) {
    detailId = json['detail_id'];
    libelle = json['libelle'];
    typeLavage = json['type_lavage'];
    quantite = json['quantite'];
    tarifUnitaire = json['tarif_unitaire'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['detail_id'] = this.detailId;
    data['libelle'] = this.libelle;
    data['type_lavage'] = this.typeLavage;
    data['quantite'] = this.quantite;
    data['tarif_unitaire'] = this.tarifUnitaire;
    return data;
  }
}

class ServicesComplementaires {
  int? serviceId;
  String? libelle;
  int? montant;

  ServicesComplementaires({this.serviceId, this.libelle, this.montant});

  ServicesComplementaires.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    libelle = json['libelle'];
    montant = json['montant'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['service_id'] = this.serviceId;
    data['libelle'] = this.libelle;
    data['montant'] = this.montant;
    return data;
  }
}
