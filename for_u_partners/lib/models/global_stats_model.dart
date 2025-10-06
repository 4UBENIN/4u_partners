// Helper pour parser les valeurs numériques (String ou num)
double _parseDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  } else if (value is String) {
    return double.parse(value);
  }
  throw FormatException('Cannot parse $value to double');
}

class GlobalStats {
  final int totalActivities;
  final int totalNotes;
  final double totalEarnings;

  GlobalStats({
    required this.totalActivities,
    required this.totalNotes,
    required this.totalEarnings,
  });

  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    return GlobalStats(
      totalActivities: json['total_activities'] as int,
      totalNotes: json['total_notes'] as int,
      totalEarnings: _parseDouble(json['total_earnings']),
    );
  }
}
