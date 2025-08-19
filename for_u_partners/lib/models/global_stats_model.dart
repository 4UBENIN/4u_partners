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
      totalEarnings: (json['total_earnings'] as num).toDouble(),
    );
  }
}
