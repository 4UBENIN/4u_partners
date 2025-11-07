// Modèle de données pour une activité
class PressingActivityModel {
  final String id;
  final String clientName;
  final String type; // 'pickup' ou 'deposit'
  final DateTime date;
  final String location;
  final String amount;
  final String weight;
  final List<String> services;
  final List<String> standardClothes;
  final List<String> specialClothes;

  PressingActivityModel({
    required this.id,
    required this.clientName,
    required this.type,
    required this.date,
    required this.location,
    required this.amount,
    required this.weight,
    required this.services,
    required this.standardClothes,
    required this.specialClothes,
  });

  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier ${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  bool isToday() {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1)));
  }
}
