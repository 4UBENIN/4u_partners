import 'package:flutter/material.dart';

class ActivityWidget extends StatelessWidget {
  const ActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          _buildActivityItem(
              '💰',
              'Course terminée',
              'Seme City → Aéroport • 18:32',
              '2,500 FCFA',
              const Color(0xFFE8F5E8),
              const Color(0xFF4CAF50)),
          _buildDivider(),
          _buildActivityItem(
              '⭐',
              'Nouvelle évaluation',
              '5 étoiles • "Service excellent"',
              null,
              const Color(0xFFFFF3E0),
              const Color(0xFFFF9800)),
          _buildDivider(),
          _buildActivityItem(
              '🎯',
              'Bonus hebdomadaire',
              '15 courses complétées',
              '+3,000 FCFA',
              const Color(0xFFF8F9FA),
              const Color(0xFF4CAF50)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String icon, String title, String subtitle,
      String? value, Color bgColor, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(
              child:
                  Text(icon, style: TextStyle(fontSize: 16, color: iconColor)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF666666))),
              ],
            ),
          ),
          if (value != null)
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50))),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(height: 1, color: const Color(0xFFF8F9FA));
}
