import 'package:flutter/material.dart';
import 'pressing_depot_detail.form.dart';
import 'package:for_u_partners/app/models/depot_models/depot_model.dart';
import 'package:for_u_partners/ui/common/app_button_component.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/home_pressing_viewmodel.dart';
import 'package:stacked/stacked.dart';

class DepotDetailView extends StackedView<HomePressingViewModel>
    with $DepotDetailView {
  final Depot depot;

  const DepotDetailView({
    Key? key,
    required this.depot,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomePressingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcWhiteColors,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            viewModel.clearDepotDetail();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: kcWhiteColors,
        title: Text(
          _isDepotPlanned(depot.statut)
              ? 'Facturation du dépôt'
              : 'Validation du dépôt',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
        centerTitle: true,
      ),
      body: _DepotDetailContent(
        depot: depot,
        viewModel: viewModel,
      ),
    );
  }

  bool _isDepotPlanned(String? statut) {
    return statut?.toLowerCase() == 'planifie' ||
        statut?.toLowerCase() == 'planned' ||
        statut?.toLowerCase() == 'confirme' ||
        statut?.toLowerCase() == 'confirmed';
  }

  @override
  HomePressingViewModel viewModelBuilder(BuildContext context) =>
      HomePressingViewModel();

  @override
  void onViewModelReady(HomePressingViewModel viewModel) {
    // Charger les détails du dépôt
    viewModel.getDepotDetailComplet(depot.id!);
    syncFormWithViewModel(viewModel);
  }
}

class _DepotDetailContent extends ViewModelWidget<HomePressingViewModel> {
  final Depot depot;
  final HomePressingViewModel viewModel;

  const _DepotDetailContent({
    required this.depot,
    required this.viewModel,
  });

  bool _isDepotPlanned(String? statut) {
    return statut?.toLowerCase() == 'planifié';
  }

  Color _getStatusColor(String? statut) {
    if (_isDepotPlanned(statut)) {
      return const Color(0xFF10B981); // Vert pour planifié
    }
    return const Color(0xFFF59E0B); // Orange pour en attente
  }

  String _getStatusText(String? statut) {
    if (_isDepotPlanned(statut)) {
      return "Cette demande est planifiée et est en attente de facturation";
    }
    return "Cette demande est en attente de planification";
  }

  IconData _getStatusIcon(String? statut) {
    if (_isDepotPlanned(statut)) {
      return Icons.schedule_rounded;
    }
    return Icons.pending_actions_rounded;
  }

  @override
  Widget build(BuildContext context, HomePressingViewModel viewModel) {
    if (viewModel.isBusy || viewModel.selectedDepotDetail == null) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    final currentDepot = viewModel.selectedDepotDetail!;
    final isPlanned = _isDepotPlanned(currentDepot.statut);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statut de la demande
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(currentDepot.statut).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(currentDepot.statut).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(currentDepot.statut),
                  color: _getStatusColor(currentDepot.statut),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStatusText(currentDepot.statut),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(currentDepot.statut),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Détails du client
          const TextComponent(
            "Détails du client",
            fontsize: 20,
            textcolor: black,
            fontweight: FontWeight.w500,
          ),
          const SizedBox(height: 15),

          // Nom du client
          _DetailSection(
            label: "Client",
            value: '${currentDepot.client.prenom} ${currentDepot.client.nom}',
          ),

          // Téléphone du client
          _DetailSection(
            label: "Numéro du client",
            value: currentDepot.client.telephone,
          ),

          // Email du client
          _DetailSection(
            label: "Mail du client",
            value: currentDepot.client.email,
          ),

          // Numéro de commande
          _DetailSection(
            label: "Numéro de commande",
            value: currentDepot.numero,
          ),

          // Date de passage
          _DetailSection(
            label: isPlanned ? "Date planifiée" : "Date de passage souhaitée",
            value: viewModel.changeFormatDateHour(currentDepot.dateRdv),
          ),

          // Détails du lavage
          const TextComponent(
            "Détails du lavage",
            fontsize: 20,
            textcolor: black,
            fontweight: FontWeight.w500,
          ),
          const SizedBox(height: 15),

          // Vêtements au kilo
          if (currentDepot.details.vetementAuKilo.isNotEmpty)
            _DetailSection(
              label: "Vêtements au kilo",
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8f9fa),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: currentDepot.details.vetementAuKilo
                      .map((vetement) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${vetement.libelle} x ${vetement.quantiteClient.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF6b7280),
                                  ),
                                ),
                                if (isPlanned &&
                                    vetement.montant != null &&
                                    vetement.montant! > 0)
                                  Text(
                                    "${vetement.montant!.toStringAsFixed(0)} FCFA",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),

          // Vêtements spéciaux
          if (currentDepot.details.vetementSpeciaux.isNotEmpty)
            _DetailSection(
              label: "Vêtements spéciaux",
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8f9fa),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: currentDepot.details.vetementSpeciaux
                      .map((vetement) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${vetement.libelle} x ${vetement.quantiteClient.toStringAsFixed(0)} => ${vetement.montant} FCFA",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF6b7280),
                                  ),
                                ),
                                if (isPlanned &&
                                    vetement.montant != null &&
                                    vetement.montant! > 0)
                                  Text(
                                    "${vetement.montant!.toStringAsFixed(0)} FCFA",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: currentDepot.servicesAdditionnel.isNotEmpty
                    ? currentDepot.servicesAdditionnel
                        .map((service) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _ServiceItem(
                                text: service.libelle,
                                montant: service.montant,
                                showPrice: isPlanned,
                              ),
                            ))
                        .toList()
                    : [
                        const Text(
                          "Aucun service additionnel",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6b7280),
                          ),
                        )
                      ],
              ),
            ),
          ),

          // Montant total si planifié
          if (isPlanned) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Montant total",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    "${_calculateTotal(currentDepot)} FCFA",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 25),

          // Bouton principal
          PrimaryButton(
            text:
                isPlanned ? "Facturer la demande" : "Planifier le rendez-vous",
            onPressed: () async {
              if (isPlanned) {
                // Aller vers la facturation
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => FacturationDepotView(depot: depot),
                //   ),
                // );
              } else {
                // Planifier la demande
                final result = await viewModel.planifierDepot(depot.id!);

                if (result != null && result.message != null) {
                  // Afficher le message de succès
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        result.message!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );

                  // Retourner à la page précédente après un court délai
                  await Future.delayed(const Duration(milliseconds: 1500));
                  if (context.mounted) {
                    Navigator.pop(context,
                        true); // Retourner true pour indiquer un changement
                  }
                } else if (viewModel.errorMessage != null) {
                  // Afficher l'erreur
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 20),

          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  double _calculateTotal(dynamic depot) {
    double total = 0.0;

    // Ajouter le montant des services additionnels
    if (depot.servicesAdditionnel != null) {
      for (var service in depot.servicesAdditionnel) {
        total += service.montant ?? 0.0;
      }
    }

    // Ajouter le montant des vêtements au kilo
    if (depot.details?.vetementAuKilo != null) {
      for (var vetement in depot.details.vetementAuKilo) {
        total += vetement.montant ?? 0.0;
      }
    }

    // Ajouter le montant des vêtements spéciaux
    if (depot.details?.vetementSpeciaux != null) {
      for (var vetement in depot.details.vetementSpeciaux) {
        total += vetement.montant ?? 0.0;
      }
    }

    return total;
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
  final double? montant;
  final bool showPrice;

  const _ServiceItem({
    required this.text,
    this.montant,
    this.showPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF184E9C),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (showPrice && montant != null && montant! > 0)
          Text(
            "${montant!.toStringAsFixed(0)} FCFA",
            style: const TextStyle(
              fontSize: 14,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
