import 'package:for_u_partners/ui/views/delivery/courses_delivery/model/client_model.dart';

class DeliveryRequestData {
  final String? livraisonId;
  final String? clientId;
  final String? clientNom;
  final String? clientPrenom;
  final double? departLat;
  final double? departLng;
  final String? adresseDepart;

  DeliveryRequestData({
    this.livraisonId,
    this.clientId,
    this.clientNom,
    this.clientPrenom,
    this.departLat,
    this.departLng,
    this.adresseDepart,
  });

  // Factory pour créer depuis JSON
  factory DeliveryRequestData.fromJson(Map<String, dynamic> json) {
    return DeliveryRequestData(
      livraisonId: json['livraison_id']?.toString(),
      clientId: json['client_id']?.toString(),
      clientNom: json['client_nom']?.toString(),
      clientPrenom: json['client_prenom']?.toString(),
      departLat: json['depart_lat']?.toDouble(),
      departLng: json['depart_lng']?.toDouble(),
      adresseDepart: json['adresse_depart']?.toString(),
    );
  }

  // Méthode pour convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'livraison_id': livraisonId,
      'client_id': clientId,
      'client_nom': clientNom,
      'client_prenom': clientPrenom,
      'depart_lat': departLat,
      'depart_lng': departLng,
      'adresse_depart': adresseDepart,
    };
  }

  // Getters utilitaires
  String get fullName => '${clientPrenom ?? ''} ${clientNom ?? ''}'.trim();

  String get initials {
    final prenom = clientPrenom?.isNotEmpty == true ? clientPrenom![0] : '';
    final nom = clientNom?.isNotEmpty == true ? clientNom![0] : '';
    return '$prenom$nom'.toUpperCase();
  }

  bool get hasValidDeliveryId => livraisonId != null && livraisonId!.isNotEmpty;

  bool get hasValidCoordinates =>
      departLat != null &&
      departLng != null &&
      departLat != 0.0 &&
      departLng != 0.0;

  // Méthode pour convertir vers l'ancien modèle DeliveryClientData si nécessaire
  DeliveryClientData toDeliveryClientData() {
    return DeliveryClientData(
      name: fullName,
      timeInfo: 'Nouvelle demande', // Ou calculer la distance/temps
      position: adresseDepart ?? 'Adresse non disponible',
      destination: 'Destination à définir', // Si tu as cette info dans l'API
      details: ['Livraison en attente'], // Adapter selon tes besoins
      initials: initials,
      type: 'Livraison',
    );
  }

  @override
  String toString() {
    return 'DeliveryRequestData(id: $livraisonId, client: $fullName, adresse: $adresseDepart)';
  }
}

// Modèle pour la réponse API complète
class DeliveryRequestResponse {
  final List<DeliveryRequestData> data;

  DeliveryRequestResponse({required this.data});

  factory DeliveryRequestResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryRequestResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((item) =>
                  DeliveryRequestData.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
