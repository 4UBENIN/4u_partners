import 'package:flutter/material.dart';

//* PRESSING BOTTOMSHEET

Widget customBottomsheetComponent(
  BuildContext context, {
  Column? column,
  Function()? onContinuePressed,
  Function()? onRelaunchPressed,
}) {
  return GestureDetector(
    onTap: () => Navigator.of(context).pop(),
    behavior: HitTestBehavior.opaque,
    child: DraggableScrollableSheet(
      initialChildSize: 0.35, // Taille initiale (40% de l'écran)
      minChildSize: 0.25, // Taille minimale (25% de l'écran)
      maxChildSize: 0.9, // Taille maximale (90% de l'écran)
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: column,
            ),
          ),
        );
      },
    ),
  );
}
