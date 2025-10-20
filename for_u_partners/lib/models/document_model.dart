// document_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum DocumentStatus {
  enAttente,
  approuve,
  rejete,
  expire,
  valide,
}

class Document {
  final String? id;
  final String? userId;
  final String? type;
  final String? category;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
  final DocumentStatus status;
  final DateTime? expirationDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;

  Document({
    this.id,
    this.userId,
    this.type,
    this.category,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.status = DocumentStatus.enAttente,
    this.expirationDate,
    this.createdAt,
    this.updatedAt,
    this.rejectionReason,
  });

  // Créer un Document depuis Firestore
  factory Document.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Document(
      id: doc.id,
      userId: data['userId'],
      type: data['type'],
      category: data['category'],
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      fileType: data['fileType'],
      status: _parseStatus(data['status']),
      expirationDate: data['expirationDate'] != null
          ? DateTime.parse(data['expirationDate'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason'],
    );
  }

  // Créer un Document depuis une Map
  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id']?.toString(),
      userId: map['userId']?.toString(),
      type: map['type']?.toString(),
      category: map['category']?.toString(),
      fileUrl: map['fileUrl']?.toString(),
      fileName: map['fileName']?.toString(),
      fileType: map['fileType']?.toString(),
      status: _parseStatus(map['status']?.toString()),
      expirationDate: map['expirationDate'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['expirationDate'])
          : map['expirationDate'] is String
              ? DateTime.tryParse(map['expirationDate'])
              : null,
      createdAt: map['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : map['createdAt'] is String
              ? DateTime.tryParse(map['createdAt'])
              : null,
      updatedAt: map['updatedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : map['updatedAt'] is String
              ? DateTime.tryParse(map['updatedAt'])
              : null,
      rejectionReason: map['rejectionReason']?.toString(),
    );
  }

  // Créer un Document depuis JSON
  factory Document.fromJson(Map<String, dynamic> json) => Document.fromMap(json);

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'category': category,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'status': status.toString(),
      'expirationDate': expirationDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'category': category,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'status': status.toString(),
      'expirationDate': expirationDate?.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'rejectionReason': rejectionReason,
    };
  }

  // Parser le status depuis une chaîne
  static DocumentStatus _parseStatus(String? statusString) {
    if (statusString == null) return DocumentStatus.enAttente;

    switch (statusString) {
      case 'DocumentStatus.approuve':
        return DocumentStatus.approuve;
      case 'DocumentStatus.rejete':
        return DocumentStatus.rejete;
      case 'DocumentStatus.expire':
        return DocumentStatus.expire;
      case 'DocumentStatus.valide':
        return DocumentStatus.valide;
      case 'DocumentStatus.enAttente':
      default:
        return DocumentStatus.enAttente;
    }
  }

  // Vérifier si le document est expiré
  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  // Vérifier si le document expire bientôt (dans les 30 jours)
  bool get expiresSoon {
    if (expirationDate == null) return false;
    final daysUntilExpiry = expirationDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  // Copier avec modifications
  Document copyWith({
    String? id,
    String? userId,
    String? type,
    String? category,
    String? fileUrl,
    String? fileName,
    String? fileType,
    DocumentStatus? status,
    DateTime? expirationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? rejectionReason,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      category: category ?? this.category,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      status: status ?? this.status,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

// Catégorie de documents
class DocumentCategory {
  final String name;
  final List<Document> documents;
  final String iconPath;

  DocumentCategory({
    required this.name,
    required this.documents,
    required this.iconPath,
  });

  // Nombre de documents dans la catégorie
  int get count => documents.length;

  // Documents en attente
  int get pendingCount =>
      documents.where((doc) => doc.status == DocumentStatus.enAttente).length;

  // Documents approuvés
  int get approvedCount =>
      documents.where((doc) => doc.status == DocumentStatus.approuve).length;

  // Documents rejetés
  int get rejectedCount =>
      documents.where((doc) => doc.status == DocumentStatus.rejete).length;
}