enum DocumentStatus {
  enAttente('en_attente'),
  approuve('approuve'),
  rejete('rejete'),
  valide('valide');

  final String value;
  const DocumentStatus(this.value);

  static DocumentStatus fromString(String value) {
    return DocumentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DocumentStatus.enAttente,
    );
  }

  @override
  String toString() => value;
}

class DocumentCategory {
  final String id;
  final String name;
  final String iconPath;
  final List<Document> documents;
  bool isExpanded;

  DocumentCategory({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.documents,
    this.isExpanded = false,
  });

  // Add a document to this category
  DocumentCategory copyWithAddedDocument(Document document) {
    return DocumentCategory(
      id: id,
      name: name,
      iconPath: iconPath,
      documents: List<Document>.from(documents)..add(document),
      isExpanded: isExpanded,
    );
  }

  // Remove a document from this category
  DocumentCategory copyWithRemovedDocument(String documentId) {
    return DocumentCategory(
      id: id,
      name: name,
      iconPath: iconPath,
      documents: documents.where((doc) => doc.id != documentId).toList(),
      isExpanded: isExpanded,
    );
  }
}

class Document {
  final String id;
  final String driverId;
  final String type;
  final String fileUrl;
  final DateTime expirationDate;
  final DateTime uploadedAt;
  final DocumentStatus status;
  final String? rejectionReason;

  Document({
    required this.id,
    required this.driverId,
    required this.type,
    required this.fileUrl,
    required this.expirationDate,
    required this.uploadedAt,
    DocumentStatus? status,
    this.rejectionReason,
  }) : status = status ?? DocumentStatus.enAttente;

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      type: json['type'] as String,
      fileUrl: json['file_url'] as String,
      expirationDate: DateTime.parse(json['expiration_date'] as String),
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      status: json['status'] != null 
          ? DocumentStatus.fromString(json['status'] as String)
          : DocumentStatus.enAttente,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'type': type,
      'file_url': fileUrl,
      'expiration_date': expirationDate.toIso8601String(),
      'uploaded_at': uploadedAt.toIso8601String(),
      'status': status.value,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    };
  }
}
