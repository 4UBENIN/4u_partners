import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';

class ClientPickupDialog extends StatelessWidget {
  final String clientName;
  final VoidCallback onAccept;
  final VoidCallback? onDecline;

  const ClientPickupDialog({
    Key? key,
    required this.clientName,
    required this.onAccept,
    this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicateur bleu en haut
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: kcPrimaryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 20),

            // Image du client avec valise
            Image.asset(
              'assets/delivery.png', // Remplacez par le chemin de votre image
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 24),

            // Texte principal
            Text(
              'Souhaitez-vous prendre $clientName ?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            // Bouton "Oui"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onAccept();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Oui',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bouton "Non"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: kcPrimaryColor,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Non',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: kcPrimaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fonction utilitaire pour afficher le dialogue
void showClientPickupDialog({
  required BuildContext context,
  required String clientName,
  required VoidCallback onAccept,
  VoidCallback? onDecline,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ClientPickupDialog(
        clientName: clientName,
        onAccept: onAccept,
        onDecline: onDecline,
      );
    },
  );
}
