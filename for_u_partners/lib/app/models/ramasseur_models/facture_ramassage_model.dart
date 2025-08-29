class FactureRamassageModel {
  final String message;
  final Facture facture;

  FactureRamassageModel({
    required this.message,
    required this.facture,
  });

  factory FactureRamassageModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔄 Parsing FactureRamassageModel from JSON: $json');
      final message = json['message'] as String? ?? 'Facture générée';
      
      // Extract facture data from 'demande' field in the response
      final demandeJson = json['demande'] as Map<String, dynamic>?;
      
      if (demandeJson == null) {
        print('⚠️ Demande data is null in the response');
        return FactureRamassageModel(
          message: message,
          facture: Facture.fromJson({}),
        );
      }
      
      print('📄 Demande data type: ${demandeJson.runtimeType}');
      print('🔢 Demande ID: ${demandeJson['id']} (type: ${demandeJson['id']?.runtimeType})');
      
      // Create facture data from demande
      final factureData = {
        'id': demandeJson['id'],
        'total': demandeJson['montant_total'],
        'lignes': [
          {
            'description': 'Ramassage de vêtements',
            'quantite': 1,
            'prix_unitaire': demandeJson['montant_total'],
            'total_ligne': demandeJson['montant_total'],
          }
        ]
      };
      
      final facture = Facture.fromJson(factureData);
      return FactureRamassageModel(
        message: message,
        facture: facture,
      );
    } catch (e, stackTrace) {
      print('❌ Error in FactureRamassageModel.fromJson: $e');
      print('📝 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'facture': facture.toJson(),
    };
  }
}

class Facture {
  final int id;
  final int total;
  final List<LigneFacture> lignes;

  Facture({
    required this.id,
    required this.total,
    required this.lignes,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    print('🔄 Parsing Facture from JSON: $json');
    
    // Debug print for each field with type information
    print('🔍 Facture JSON keys: ${json.keys.join(', ')}');
    json.forEach((key, value) {
      print('   - $key: $value (${value?.runtimeType})');
    });
    
    try {
      final id = _parseInt(json['id']);
      print('✅ Parsed id: $id (${id.runtimeType})');
      
      final total = _parseInt(json['total'] ?? json['montant_total']);
      print('✅ Parsed total: $total (${total.runtimeType})');
      
      List<LigneFacture> lignes = [];
      if (json['lignes'] != null && json['lignes'] is List) {
        try {
          print('🔄 Parsing lignes...');
          lignes = (json['lignes'] as List).map((e) {
            print('   - Parsing ligne: $e');
            return LigneFacture.fromJson(e);
          }).toList();
          print('✅ Successfully parsed ${lignes.length} lignes');
        } catch (e, stackTrace) {
          print('❌ Error parsing lignes: $e');
          print('📝 Ligne stack trace: $stackTrace');
          // Continue with empty list if there's an error
        }
      } else {
        print('ℹ️ No lignes found or invalid format');
      }
      
      return Facture(
        id: id,
        total: total,
        lignes: lignes,
      );
    } catch (e, stackTrace) {
      print('❌ Error in Facture.fromJson: $e');
      print('📝 Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total': total,
      'lignes': lignes.map((e) => e.toJson()).toList(),
    };
  }
}

class LigneFacture {
  final String description;
  final int quantite;
  final int prixUnitaire;
  final int totalLigne;

  LigneFacture({
    required this.description,
    required this.quantite,
    required this.prixUnitaire,
    required this.totalLigne,
  });

  factory LigneFacture.fromJson(Map<String, dynamic> json) {
    print('🔄 Parsing LigneFacture from JSON: $json');
    
    // Log all fields and their types
    json.forEach((key, value) {
      print('   - $key: $value (${value?.runtimeType})');
    });
    
    try {
      final description = json['description'] as String? ?? 'Article';
      print('✅ Description: $description');
      
      final quantite = _parseInt(json['quantite']);
      print('✅ Quantité: $quantite (${quantite.runtimeType})');
      
      final prixUnitaire = _parseInt(json['prix_unitaire'] ?? json['montant_total']);
      print('✅ Prix unitaire: $prixUnitaire (${prixUnitaire.runtimeType})');
      
      final totalLigne = _parseInt(json['total_ligne'] ?? json['montant_total']);
      print('✅ Total ligne: $totalLigne (${totalLigne.runtimeType})');
      
      return LigneFacture(
        description: description,
        quantite: quantite,
        prixUnitaire: prixUnitaire,
        totalLigne: totalLigne,
      );
    } catch (e, stackTrace) {
      print('❌ Error in LigneFacture.fromJson: $e');
      print('📝 Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
      'total_ligne': totalLigne,
    };
  }
}
