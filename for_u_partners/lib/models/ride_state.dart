class RideState {
  final int courseId;
  final String status;
  final String timestamp;

  RideState({
    required this.courseId,
    required this.status,
    required this.timestamp,
  });

  // Convert a RideState into a Map
  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'status': status,
    'timestamp': timestamp,
  };

  // Create a RideState from a Map
  factory RideState.fromJson(Map<String, dynamic> json) => RideState(
    courseId: json['courseId'] as int,
    status: json['status'] as String,
    timestamp: json['timestamp'] as String,
  );
}
