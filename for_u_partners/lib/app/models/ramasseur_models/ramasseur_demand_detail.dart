class RamasseurDemandDetail {
  int? demandeId;
  String? adresseLivraison;
  String? dateDemande;
  double? latRamassage;
  double? lngRamassage;
  double? latLivraison;
  double? lngLivraison;
  List<VetementsAuKilo>? vetementsAuKilo;
  List<VetementsSpeciaux>? vetementsSpeciaux;
  List<ServicesComplementaires>? servicesComplementaires;
  String? adresseRamassage;
  String? adressePressing;
  String? nomPressing;
  int? prixRamassage;
  String? message;

  RamasseurDemandDetail({
    this.demandeId,
    this.adresseLivraison,
    this.dateDemande,
    this.latRamassage,
    this.lngRamassage,
    this.latLivraison,
    this.lngLivraison,
    this.vetementsAuKilo,
    this.vetementsSpeciaux,
    this.servicesComplementaires,
    this.adresseRamassage,
    this.adressePressing,
    this.nomPressing,
    this.prixRamassage,
    this.message,
  });

  // Helper method to safely convert any value to double
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory RamasseurDemandDetail.fromJson(Map<String, dynamic> json) {
    final vetementsAuKilo = json['vetements_au_kilo'] != null
        ? (json['vetements_au_kilo'] as List)
            .map((v) => VetementsAuKilo.fromJson(v))
            .toList()
        : null;

    final vetementsSpeciaux = json['vetements_speciaux'] != null
        ? (json['vetements_speciaux'] as List)
            .map((v) => VetementsSpeciaux.fromJson(v))
            .toList()
        : null;

    final servicesComplementaires = json['services_complementaires'] != null
        ? (json['services_complementaires'] as List)
            .map((v) => ServicesComplementaires.fromJson(v))
            .toList()
        : null;

    return RamasseurDemandDetail(
      demandeId: json['demande_id'],
      adresseLivraison: json['adresse_livraison'],
      dateDemande: json['date_demande'],
      latRamassage: _toDouble(json['lat_ramassage']),
      lngRamassage: _toDouble(json['lng_ramassage']),
      latLivraison: _toDouble(json['lat_livraison']),
      lngLivraison: _toDouble(json['lng_livraison']),
      vetementsAuKilo: vetementsAuKilo,
      vetementsSpeciaux: vetementsSpeciaux,
      servicesComplementaires: servicesComplementaires,
      adresseRamassage: json['adresse_ramassage'],
      adressePressing: json['adresse_pressing'],
      nomPressing: json['nom_pressing'],
      prixRamassage: json['prix_ramassage'] is int
          ? json['prix_ramassage']
          : int.tryParse(json['prix_ramassage']?.toString() ?? '0') ?? 0,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'demande_id': demandeId,
        'adresse_livraison': adresseLivraison,
        'date_demande': dateDemande,
        'lat_ramassage': latRamassage,
        'lng_ramassage': lngRamassage,
        'lat_livraison': latLivraison,
        'lng_livraison': lngLivraison,
        'vetements_au_kilo': vetementsAuKilo?.map((v) => v.toJson()).toList(),
        'vetements_speciaux':
            vetementsSpeciaux?.map((v) => v.toJson()).toList(),
        'services_complementaires':
            servicesComplementaires?.map((v) => v.toJson()).toList(),
        'adresse_ramassage': adresseRamassage,
        'adresse_pressing': adressePressing,
        'nom_pressing': nomPressing,
        'prix_ramassage': prixRamassage,
        'message': message,
      };
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
          // First parse as double, then convert to int to handle decimal strings like "2500.00"
          final doubleValue = double.tryParse(json['tarif_unitaire']);
          tarifUnitaire = doubleValue?.toInt() ?? 0;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['detail_id'] = detailId;
    data['libelle'] = libelle;
    data['type_lavage'] = typeLavage;
    data['quantite'] = quantite;
    data['tarif_unitaire'] = tarifUnitaire;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['detail_id'] = detailId;
    data['libelle'] = libelle;
    data['type_lavage'] = typeLavage;
    data['quantite'] = quantite;
    data['tarif_unitaire'] = tarifUnitaire;
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

    // FIXED: Handle string decimal values for montant
    if (json['montant'] != null) {
      if (json['montant'] is String) {
        final doubleValue = double.tryParse(json['montant']);
        montant = doubleValue?.toInt() ?? 0;
      } else if (json['montant'] is num) {
        montant = json['montant'].toInt();
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'service_id': serviceId,
        'libelle': libelle,
        'montant': montant,
      };
}
