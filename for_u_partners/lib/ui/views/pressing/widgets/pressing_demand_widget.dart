import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';

class PressingDemandWidget extends StatefulWidget {
  final String name;
  final String date;
  final String place;
  final bool isValid;
  final VoidCallback? onClick;

  const PressingDemandWidget(
      {super.key,
      required this.name,
      required this.isValid,
      required this.onClick,
      required this.date,
      required this.place});

  @override
  State<PressingDemandWidget> createState() => _PressingDemandWidgetState();
}

class _PressingDemandWidgetState extends State<PressingDemandWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: greybutton),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextComponent(
                widget.name,
                fontweight: FontWeight.bold,
                fontsize: 16,
              ),
              const SizedBox(height: 10),
              TextComponent(
                "Prévu pour le ${widget.date} à 15h 30",
                fontsize: 16,
                maxLines: 2,
                textcolor: kcLightGrey
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const TextComponent("📍"),
                  const SizedBox(width: 10),
                  TextComponent(
                    widget.place,
                    fontweight: FontWeight.bold,
                    textcolor: primaryColor,
                    fontsize: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
