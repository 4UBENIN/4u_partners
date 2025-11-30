import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/app/models/notification_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget notificationsCard(
  NotificationModel notification, {
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle_rounded,
                color: notification.isRead ? Colors.grey : kcPrimaryColor,
                size: 10,
              ),
              const SizedBox(
                width: 10,
              ),
              TextComponent(
                notification.sentAt,
                textcolor: notification.isRead ? Colors.grey : kcPrimaryColor,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextComponent(
                  notification.type,
                  fontsize: 12,
                  textcolor: _getTypeColor(notification.type),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          TextComponent(
            notification.titre,
            fontweight: FontWeight.bold,
            textcolor: notification.isRead ? Colors.grey : Colors.black,
          ),
          const SizedBox(
            height: 5,
          ),
          TextComponent(
            notification.message,
            fontsize: 14,
            textcolor: notification.isRead ? Colors.grey : Colors.black87,
          ),
          if (notification.image != null) ...[
            const SizedBox(
              height: 10,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: notification.image!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ],
          const SizedBox(
            height: 10,
          ),
          const Divider()
        ],
      ),
    ),
  );
}

Color _getTypeColor(String type) {
  switch (type.toLowerCase()) {
    case 'alerte':
      return Colors.red;
    case 'info':
      return Colors.blue;
    case 'success':
      return Colors.green;
    case 'warning':
      return Colors.orange;
    default:
      return kcPrimaryColor;
  }
}
