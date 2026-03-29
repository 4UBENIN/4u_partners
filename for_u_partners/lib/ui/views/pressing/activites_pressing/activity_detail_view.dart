import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/pressing_depot_models/depot_detail_model.dart';
import 'package:for_u_partners/app/models/pressing_ramassage_models/ramassage_detail_model.dart';
import 'package:for_u_partners/services/pressing_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';

class ActivityDetailView extends StatelessWidget {
  final String type; // 'ramassage' ou 'depot'
  final int id;

  const ActivityDetailView({
    Key? key,
    required this.type,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcWhiteColors,
      appBar: AppBar(
        title: const Text("Détails de la demande"),
        backgroundColor: kcWhiteColors,
      ),
      body: FutureBuilder(
        future: PressingService().getActivityDetails(type: type, id: id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: primaryColor,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Aucune donnée trouvée"));
          }

          final data = snapshot.data;
          if (data is Rdv) {
            return _buildDepotDetails(data);
          } else if (data is RamassageDetail) {
            return _buildRamassageDetails(data);
          } else {
            return const Center(child: Text("Type de demande inconnu"));
          }
        },
      ),
    );
  }

  Widget _buildDepotDetails(Rdv rdv) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetailSection(label: "Numéro", value: rdv.numero),
        _DetailSection(
            label: "Client", value: "${rdv.client.prenom} ${rdv.client.nom}"),
        _DetailSection(label: "Date", value: rdv.dateRdv.toString()),
        _DetailSection(label: "Statut", value: rdv.statut),
        _DetailSection(
          label: "Vêtements au kilo",
          child: Column(
            children: rdv.details.vetementAuKilo
                .map((v) => Text("${v.libelle} - ${v.quantiteClient} kg"))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRamassageDetails(RamassageDetail ram) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const TextComponent(
          "Détails de la demande",
          fontsize: 18,
          textcolor: black,
          fontweight: FontWeight.w500,
        ),
        const SizedBox(height: 15),
        _DetailSection(label: "Numéro", value: ram.numero),
        _DetailSection(label: "Adresse ramassage", value: ram.adresseRamassage),
        _DetailSection(label: "Adresse livraison", value: ram.adresseLivraison),
        const TextComponent(
          "Détails du client",
          fontsize: 18,
          textcolor: black,
          fontweight: FontWeight.w500,
        ),
        const SizedBox(height: 15),
        _DetailSection(
            label: "Nom du Client",
            value: "${ram.client?.prenom} ${ram.client?.nom}"),
        _DetailSection(
            label: "Numéro Client", value: "${ram.client?.telephone}"),
        const TextComponent(
          "Détails du ramasseur",
          fontsize: 18,
          textcolor: black,
          fontweight: FontWeight.w500,
        ),
        const SizedBox(height: 15),
        _DetailSection(
            label: "Nom du ramasseur",
            value:
                '${ram.ramasseur?.prenom ?? ''} ${ram.ramasseur?.nom ?? ''}'),
        _DetailSection(
            label: "Téléphone du ramasseur",
            value: ram.ramasseur?.telephone ?? ''),
        const TextComponent(
          "Détails du lavage",
          fontsize: 18,
          textcolor: black,
          fontweight: FontWeight.w500,
        ),
        const SizedBox(height: 15),
        _DetailSection(
          label: "Vêtements au Kilo",
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundService,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextComponent(
                  ram.details
                          ?.map((item) =>
                              '${item.libelle} x${item.quantite?.toInt()}')
                          .join('\n') ??
                      'Aucun détail',
                  fontsize: 16,
                  textcolor: darkGreyColor,
                ),
              ],
            ),
          ),
        ),
        _DetailSection(
          label: "Services additionnels",
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundService,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextComponent(
                    ram.servicesComplementaires
                            ?.map((item) => '${item.libelle}')
                            .join('\n') ??
                        'Aucun détail',
                    fontsize: 16,
                    textcolor: darkGreyColor),
              ],
            ),
          ),
        ),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "1",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
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
                      "${ram.montant?.toInt() ?? 0} FCFA",
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {},
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
        ),
      ],
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
