import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';

class CustomDropdown extends StatelessWidget {
  final String title;
  final List<String> items;
  final String value;
  final void Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.title,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextComponent(
          title,
          fontsize: 16,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            // color: AppColors.bgColor,
          color: Colors.white,
            border: Border.all(color: greybutton),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            
            child: DropdownButton<String>(
              focusColor: Colors.white,
              isExpanded: true,
              borderRadius: BorderRadius.circular(20),
              value: value,
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: TextComponent(
                          item,
                          textcolor: textinputcolor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
