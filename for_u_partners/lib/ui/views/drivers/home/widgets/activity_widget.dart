import 'package:flutter/material.dart';
import 'package:for_u_partners/models/daily_stats_model.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';

class ActivityWidget extends StatelessWidget {
  final List<ActiviteRecenteTerminee>? recentActivities;
  final List<Evaluation>? evaluations;
  final VoidCallback? onActivityTap;
  final VoidCallback? onRatingTap;

  const ActivityWidget({
    super.key,
    this.recentActivities,
    this.evaluations,
    this.onActivityTap,
    this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    final activities = <Widget>[];

    // Ajouter les activités récentes
    if (recentActivities?.isNotEmpty ?? false) {
      activities.addAll(
          recentActivities!.take(2).map((activity) => _buildActivityItem(
                '💰',
                'Course terminée',
                '${activity.adresseDepart} → ${activity.adresseArrivee} • ${_formatTime(activity.heureArrivee)}',
                '${activity.adresseArrivee} FCFA',
                const Color(0xFFE8F5E8),
                const Color(0xFF4CAF50),
                onActivityTap,
              )));
    }

    // Ajouter les évaluations récentes
    if (evaluations?.isNotEmpty ?? false) {
      activities.add(_buildActivityItem(
        '⭐',
        'Nouvelle évaluation',
        '${evaluations!.first.etoiles} étoiles • "${evaluations!.first.commentaire ?? 'Aucun commentaire'}"',
        null,
        const Color(0xFFFFF3E0),
        const Color(0xFFFF9800),
        onRatingTap,
      ));
    }

    // Si pas d'activités ni d'évaluations
    if (activities.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: activities.asMap().entries.expand<Widget>((entry) {
          final isLast = entry.key == activities.length - 1;
          return [
            entry.value,
            if (!isLast) _buildDivider(),
          ];
        }).toList(),
      ),
    );
  }

  Widget _buildActivityItem(
    String icon,
    String title,
    String subtitle,
    String? value,
    Color bgColor,
    Color iconColor,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(fontSize: 16, color: iconColor),
                ),
              ),
            ),
            
            // Main content - FIX: Ajout d'Expanded pour éviter l'overflow
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Subtitle - FIX: Meilleure gestion du texte long
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                            height: 1.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  
                  // Value (if exists) - FIX: Mieux positionné à droite
                  if (value != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              size: 48,
              color: kcPrimaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune activité récente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Vos prochaines courses apparaîtront ici dès qu\'elles seront disponibles',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildDivider() =>
      Container(height: 1, color: const Color(0xFFF8F9FA));
}

// ALTERNATIVE PLUS COMPACTE - Si vous voulez une version plus simple
// Remplacez juste la méthode _buildActivityItem par celle-ci :

/* 
Widget _buildActivityItemCompact(
  String icon,
  String title,
  String subtitle,
  String? value,
  Color bgColor,
  Color iconColor,
  VoidCallback? onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Icon
          CircleAvatar(
            radius: 18,
            backgroundColor: bgColor,
            child: Text(icon, style: TextStyle(fontSize: 16)),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Value
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    ),
  );
}
*/