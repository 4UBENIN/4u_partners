class Rdv {
  final int id;
  final String numero;
  final Client client;
  final DateTime dateRdv;
  final String statut;
  final Details details;
  final List<ServiceAdditionnel> servicesAdditionnel;

  Rdv({
    required this.id,
    required this.numero,
    required this.client,
    required this.dateRdv,
    required this.statut,
    required this.details,
    required this.servicesAdditionnel,
  });

  factory Rdv.fromJson(Map<String, dynamic> json) {
    return Rdv(
      id: json['id'],
      numero: json['numero'],
      client: Client.fromJson(json['client']),
      dateRdv: DateTime.parse(json['date_rdv']),
      statut: json['statut'],
      details: Details.fromJson(json['details']),
      servicesAdditionnel: (json['services_additionnel'] as List)
          .map((e) => ServiceAdditionnel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'client': client.toJson(),
      'date_rdv': dateRdv.toIso8601String(),
      'statut': statut,
      'details': details.toJson(),
      'services_additionnel':
          servicesAdditionnel.map((e) => e.toJson()).toList(),
    };
  }
}

class Client {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String email;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
    };
  }
}

class Details {
  final List<Vetement> vetementAuKilo;
  final List<Vetement> vetementSpeciaux;

  Details({
    required this.vetementAuKilo,
    required this.vetementSpeciaux,
  });

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      vetementAuKilo: (json['vetement_au_kilo'] as List)
          .map((e) => Vetement.fromJson(e))
          .toList(),
      vetementSpeciaux: (json['vetement_speciaux'] as List)
          .map((e) => Vetement.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vetement_au_kilo': vetementAuKilo.map((e) => e.toJson()).toList(),
      'vetement_speciaux': vetementSpeciaux.map((e) => e.toJson()).toList(),
    };
  }
}

class Vetement {
  final String libelle;
  final int quantiteClient;
  final int montant;

  Vetement({
    required this.libelle,
    required this.quantiteClient,
    required this.montant,
  });

  factory Vetement.fromJson(Map<String, dynamic> json) {
    return Vetement(
      libelle: json['libelle'],
      quantiteClient: json['quantite_client'],
      montant: json['montant'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libelle': libelle,
      'quantite_client': quantiteClient,
      'montant': montant,
    };
  }
}

class ServiceAdditionnel {
  final int id;
  final String libelle;
  final int montant;

  ServiceAdditionnel({
    required this.id,
    required this.libelle,
    required this.montant,
  });

  factory ServiceAdditionnel.fromJson(Map<String, dynamic> json) {
    return ServiceAdditionnel(
      id: json['id'],
      libelle: json['libelle'],
      montant: json['montant'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'montant': montant,
    };
  }
}
