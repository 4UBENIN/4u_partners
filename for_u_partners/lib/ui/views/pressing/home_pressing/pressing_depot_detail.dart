import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/depot_models/depot_model.dart';
import 'package:for_u_partners/ui/common/app_button_component.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/home_pressing_viewmodel.dart';
import 'package:stacked/stacked.dart';

class DepotDetailView extends StackedView<HomePressingViewModel> {
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
            viewModel.clearDepotDetail(); // Méthode à ajouter dans le ViewModel
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: kcWhiteColors,
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
      body: _DepotDetailContent(
        depot: depot,
        viewModel: viewModel,
      ),
    );
  }

  @override
  HomePressingViewModel viewModelBuilder(BuildContext context) =>
      HomePressingViewModel();

  @override
  void onViewModelReady(HomePressingViewModel viewModel) {
    // Charger les détails du dépôt
    viewModel.getDepotDetailComplet(depot.id!);
  }
}

class _DepotDetailContent extends ViewModelWidget<HomePressingViewModel> {
  final Depot depot;
  final HomePressingViewModel viewModel;

  const _DepotDetailContent({
    required this.depot,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context, HomePressingViewModel viewModel) {
    if (viewModel.isBusy || viewModel.selectedDepotDetail == null) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    final currentDepot = viewModel.selectedDepotDetail!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            label: "Date de passage",
            value: viewModel
                .changeFormatDate(currentDepot.dateRdv.toIso8601String()),
          ),

          // Détails du client
          const TextComponent(
            "Détails du lavage",
            fontsize: 20,
            textcolor: black,
            fontweight: FontWeight.w500,
          ),
          const SizedBox(height: 15),

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
                              child: _ServiceItem(text: service.libelle),
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
                            child: Text(
                              "${vetement.libelle} x ${vetement.quantiteClient.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6b7280),
                              ),
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
                            child: Text(
                              "${vetement.libelle} x ${vetement.quantiteClient.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6b7280),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),

          const SizedBox(height: 10),

          //button principal
          PrimaryButton(
              text: "Finaliser le rendez-vous",
              onPressed: () {
              }),
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
