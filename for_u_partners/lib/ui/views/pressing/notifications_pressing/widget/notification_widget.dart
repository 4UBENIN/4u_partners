import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';

Widget pressingNotificationsCard(
  String date,
  String text,
) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.circle_rounded,
                color: kcPrimaryColor,
                size: 10,
              ),
              const SizedBox(
                width: 10,
              ),
              TextComponent(
                date,
                textcolor: kcPrimaryColor,
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          TextComponent(
            text,
            fontweight: FontWeight.bold,
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider()
        ],
      ));
}
