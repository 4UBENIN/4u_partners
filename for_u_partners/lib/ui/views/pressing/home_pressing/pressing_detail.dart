import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/common/app_button_component.dart';
import 'package:for_u_partners/ui/views/pressing/widgets/dialog_widget.dart';

class PressingDetailView extends StatelessWidget {
  final bool isA;
  const PressingDetailView({
    super.key,
    this.isA = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcWhiteColors,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: kcWhiteColors,
        title: const TextComponent(
          "Détails de la demande",
          fontweight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: _PressingDetailContent(isAccepted: isA),
    );
  }
}

class _PressingDetailContent extends StatefulWidget {
  final bool isAccepted;
  const _PressingDetailContent({required this.isAccepted});

  @override
  State<_PressingDetailContent> createState() => _PressingDetailContentState();
}

class _PressingDetailContentState extends State<_PressingDetailContent> {
  String _selectedMethod = 'Espèces';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextComponent("Destination",
                fontsize: 17, textcolor: kcLightGrey),
            const SizedBox(height: 10),
            const TextComponent("EREVAN, Cadjehoun Aeroport",
                fontsize: 18, fontweight: FontWeight.bold),
            const SizedBox(height: 20),
            const TextComponent("Date de ramassage",
                fontsize: 17, textcolor: kcLightGrey),
            const SizedBox(height: 10),
            const TextComponent("Mardi 12 Décembre à 15h 30",
                fontsize: 18,
                fontweight: FontWeight.bold,
                textcolor: primaryColor),
            const SizedBox(height: 20),
            const TextComponent("Adresse de ramassage",
                fontsize: 17, textcolor: kcLightGrey),
            const SizedBox(height: 10),
            const TextComponent("Cadjehoun, Place centrale, 123-B403",
                fontsize: 18,
                fontweight: FontWeight.bold,
                textcolor: primaryColor),

            //* VETEMENTS LAVES
            const SizedBox(height: 20),
            const TextComponent("Vêtements lavés",
                fontsize: 17, textcolor: kcLightGrey),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundService,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextComponent(
                    "Tshirt x5",
                    fontsize: 16,
                    textcolor: mediumGrey,
                  ),
                  SizedBox(height: 5),
                  TextComponent("Jupe x2", fontsize: 16, textcolor: mediumGrey),
                  SizedBox(height: 5),
                  TextComponent("Pantalon x2",
                      fontsize: 16, textcolor: mediumGrey),
                ],
              ),
            ),
            const SizedBox(height: 20),

            //* SERVICES ADDITIONNELS
            const TextComponent("Services additionnels",
                fontsize: 17, textcolor: kcLightGrey),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundService,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  TextComponent("Repassage",
                      fontsize: 16,
                      textcolor: primaryColor,
                      fontweight: FontWeight.bold),
                  SizedBox(height: 5),
                  TextComponent("Traitement de taches",
                      fontsize: 16,
                      textcolor: primaryColor,
                      fontweight: FontWeight.bold),
                ],
              ),
            ),
            // const SizedBox(height: 20),
            // const TextComponent("Moyen de Paiement",
            //     fontsize: 17, textcolor: kcLightGrey),
            // const SizedBox(height: 10),
            // _buildRadioOption("Portefeuille"),
            // _buildRadioOption("Espèces"),
            const SizedBox(height: 20),
            if (widget.isAccepted)
              PrimaryButton(
                text: "Finaliser la demande",
                onPressed: () {
                  showDemandCompletedDialog(
                    context: context,
                    clientName: "Teddy TOSSOU",
                    onAccept: () {
                      Navigator.pop(context, true); // retourne vrai
                    },
                    onDecline: () {
                      Navigator.pop(context);
                    },
                  );
                },
              )
            else
              PrimaryButton(
                text: "Accepter la demande",
                onPressed: () {
                  Navigator.pop(context, true); // retourne vrai
                },
              ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const TextComponent("Rejeter",
                    textcolor: red, fontsize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String label) {
    final bool isSelected = _selectedMethod == label;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMethod = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xF0F4F9FF) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: primaryColor, width: 1)
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: label,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value!;
                  });
                },
                activeColor: primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              )
            ],
          ),
        ),
      ),
    );
  }
}
