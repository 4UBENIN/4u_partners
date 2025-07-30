import 'package:flutter/material.dart';

class PressingDemandWidget extends StatefulWidget {
  final String name;
  final String date;
  final String place;
  final bool isValid;
  final String status; // "En attente", "En attente de facturation", "Terminé"
  final VoidCallback? onClick;

  const PressingDemandWidget({
    super.key,
    required this.name,
    required this.isValid,
    required this.onClick,
    required this.date,
    required this.place,
    required this.status,
  });

  @override
  State<PressingDemandWidget> createState() => _PressingDemandWidgetState();
}

class _PressingDemandWidgetState extends State<PressingDemandWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.04),
          child: InkWell(
            onTap: widget.onClick,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFf1f3f4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10b981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_shipping_outlined,
                              color: Color(0xFF10b981),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1a1a1a),
                                ),
                              ),
                              const Text(
                                'Ramassage',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8e8e93),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildStatusBadge(),
                          const SizedBox(height: 4),
                          Text(
                            _getFormattedDate(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8e8e93),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF8e8e93),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.place,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8e8e93),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Services simulés
                  Wrap(
                    spacing: 8,
                    children: ['Lavage Xpress 24h', 'Repassage']
                        .take(2)
                        .map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf1f3f4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (widget.status) {
      case "En attente de facturation":
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        displayText = "À facturer";
        break;
      case "Terminé":
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        displayText = "Terminé";
        break;
      default: // "En attente"
        backgroundColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF6B7280);
        displayText = "En attente";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _getFormattedDate() {
    // Formatage simple de la date
    return widget.date.split(' ').take(3).join(' ');
  }
}
