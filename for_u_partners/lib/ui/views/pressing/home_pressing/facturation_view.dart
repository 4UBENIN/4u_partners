import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_textInput.dart';
import 'package:for_u_partners/ui/common/app_button_component.dart';

class FacturationView extends StatefulWidget {
  const FacturationView({Key? key}) : super(key: key);

  @override
  State<FacturationView> createState() => _FacturationViewState();
}

class _FacturationViewState extends State<FacturationView> {
  double poids = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Facturation',
          style: TextStyle(
            fontSize: 20,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Vêtements standards",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "T-Shirt x 4",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Pantalon x 3",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Boxer x 4",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Section poids
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFe5e7eb)),
                      ),
                      child: TextInputField(hintText: "Poids (kg)", bigLabel: "Poids",)
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Vêtements spéciaux
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFe5e7eb)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Vêtements spéciaux",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8e8e93),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Veste complète x2",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1a1a1a),
                                ),
                              ),
                              const Text(
                                "4000 Fcfa",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF184E9C),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Total
            Container(
              padding: const EdgeInsets.only(top: 16),
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFe5e7eb), width: 2),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  Text(
                    "5 000 Fcfa",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF184E9C),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            PrimaryButton(text: "Enregistrer", onPressed: () {}),
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
              fontSize: 14,
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