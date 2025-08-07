class DeliveryClientData {
  final String name;
  final String type;
  final String timeInfo;
  final String position;
  final String destination;
  final List<String> details;
  final String initials;

  DeliveryClientData({
    required this.name,
    required this.type,
    required this.timeInfo,
    required this.position,
    required this.destination,
    required this.details,
    required this.initials,
  });
}
