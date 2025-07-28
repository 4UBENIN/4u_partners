import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';

class DepotDetailView extends StatefulWidget {
  const DepotDetailView({Key? key}) : super(key: key);

  @override
  State<DepotDetailView> createState() => _DepotDetailViewState();
}

class _DepotDetailViewState extends State<DepotDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcWhiteColors,
      appBar: AppBar(
        backgroundColor: kcWhiteColors,
        elevation: 0,
        title: const Text(
          'Validation du dépôt',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date de passage
            _DetailSection(
              label: "Date de passage",
              value: "Mardi 26 Mars 15h 30",
            ),

            // Services additionnels
            _DetailSection(
              label: "Services additionnels",
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8f9fa),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ServiceItem(text: "Lavage Xpress 24h"),
                    SizedBox(height: 8),
                    _ServiceItem(text: "Repassage"),
                    SizedBox(height: 8),
                    _ServiceItem(text: "Traitement de taches"),
                  ],
                ),
              ),
            ),

            // Vêtements
            _DetailSection(
              label: "Vêtements",
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8f9fa),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "T-Shirt x 4",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Pantalon x 3",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Boxer x 4",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vêtements spéciaux
            _DetailSection(
              label: "Vêtements spéciaux",
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8f9fa),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Veste complète x2",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6b7280),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Boutons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10b981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Valider',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const TextComponent("Rejeter",
                        textcolor: red, fontsize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;

  const _DetailSection({
    required this.label,
    this.value,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF8e8e93),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF184E9C),
                fontWeight: FontWeight.w500,
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String text;

  const _ServiceItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF184E9C),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
