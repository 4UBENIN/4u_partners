import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/views/pressing/activites_pressing/models/pressing_activities_models.dart';

class ActivityDetailView extends StatelessWidget {
  final PressingActivityModel activity;

  const ActivityDetailView({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détail ${activity.type == 'pickup' ? 'ramassage' : 'dépôt'}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec statut
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: activity.type == 'pickup' 
                      ? [const Color(0xFF10b981), const Color(0xFF059669)]
                      : [const Color(0xFF184E9C), const Color(0xFF2563eb)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    activity.type == 'pickup' 
                        ? Icons.local_shipping
                        : Icons.local_laundry_service,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activity.clientName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'TERMINÉ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Informations générales
            _DetailSection(
              label: "Date de ${activity.type == 'pickup' ? 'ramassage' : 'dépôt'}",
              value: activity.getFormattedDate(),
            ),

            _DetailSection(
              label: "Adresse",
              value: activity.location,
            ),

            // Services additionnels
            if (activity.services.isNotEmpty)
              _DetailSection(
                label: "Services additionnels",
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf8f9fa),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: activity.services.map((service) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF184E9C),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              service,
                              style: const TextStyle(
                                color: Color(0xFF184E9C),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Vêtements
            _DetailSection(
              label: "Vêtements lavés",
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
                    if (activity.standardClothes.isNotEmpty) ...[
                      const Text(
                        "Vêtements standards",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...activity.standardClothes.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        );
                      }),
                    ],
                    if (activity.specialClothes.isNotEmpty) ...[
                      if (activity.standardClothes.isNotEmpty) 
                        const SizedBox(height: 16),
                      const Text(
                        "Vêtements spéciaux",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...activity.specialClothes.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            // Poids et prix
            Row(
              children: [
                Expanded(
                  child: _DetailSection(
                    label: "Poids total",
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf8f9fa),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            activity.weight,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1a1a1a),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'kg',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DetailSection(
                    label: "Montant total",
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF184E9C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          activity.amount,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF184E9C),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Bouton d'action (optionnel)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Logique pour contacter le client ou autre action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF184E9C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.phone_outlined, color: Colors.white),
                label: const Text(
                  'Contacter le client',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

// Widget helper pour les sections de détail
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
