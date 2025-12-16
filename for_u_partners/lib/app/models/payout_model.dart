class PayoutModel {
  final int id;
  final String payoutId;
  final String reference;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? liveStatus;
  final Map<String, dynamic>? payload;
  final Map<String, dynamic>? live;

  PayoutModel({
    required this.id,
    required this.payoutId,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.liveStatus,
    this.payload,
    this.live,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: json['id'] ?? 0,
      payoutId: json['payout_id']?.toString() ?? '',
      reference: json['reference'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      liveStatus: json['live_status'],
      payload: json['payload'],
      live: json['live'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payout_id': payoutId,
      'reference': reference,
      'amount': amount,
      'currency': currency,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'live_status': liveStatus,
      'payload': payload,
      'live': live,
    };
  }

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'started':
        return 'En cours';
      case 'sent':
        return 'Envoyé';
      case 'success':
        return 'Réussi';
      case 'failed':
        return 'Échoué';
      default:
        return status;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isStarted => status.toLowerCase() == 'started';
  bool get isSent => status.toLowerCase() == 'sent';
  bool get isSuccess => status.toLowerCase() == 'success';
  bool get isFailed => status.toLowerCase() == 'failed';
}

class PayoutListResponse {
  final int currentPage;
  final int perPage;
  final int total;
  final List<PayoutModel> data;

  PayoutListResponse({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.data,
  });

  factory PayoutListResponse.fromJson(Map<String, dynamic> json) {
    return PayoutListResponse(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => PayoutModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PayoutCreateRequest {
  final int utilisateurId;
  final String password;
  final double amount;
  final String provider;
  final String recipientType;

  PayoutCreateRequest({
    required this.utilisateurId,
    required this.password,
    required this.amount,
    required this.provider,
    required this.recipientType,
  });

  Map<String, dynamic> toJson() {
    return {
      'utilisateur_id': utilisateurId,
      'password': password,
      'amount': amount,
      'provider': provider,
      'recipient_type': recipientType,
    };
  }
}

class PayoutCreateResponse {
  final String message;
  final PayoutData payout;

  PayoutCreateResponse({
    required this.message,
    required this.payout,
  });

  factory PayoutCreateResponse.fromJson(Map<String, dynamic> json) {
    return PayoutCreateResponse(
      message: json['message'] ?? '',
      payout: PayoutData.fromJson(json['payout'] ?? {}),
    );
  }
}

class PayoutData {
  final String id;
  final String reference;
  final double amount;
  final String currency;
  final String status;

  PayoutData({
    required this.id,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory PayoutData.fromJson(Map<String, dynamic> json) {
    return PayoutData(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      status: json['status'] ?? '',
    );
  }
}
