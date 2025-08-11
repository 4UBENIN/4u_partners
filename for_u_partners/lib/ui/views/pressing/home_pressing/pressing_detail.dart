import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/models/ramassage_models/ramassage_model.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/home_pressing_viewmodel.dart';
import 'package:for_u_partners/ui/views/pressing/widgets/dialog_widget.dart';
import 'package:stacked/stacked.dart';

class PressingDetailView extends StackedView<HomePressingViewModel> {
  final bool isA;
  final String? currentStatus;
  final Ramassage ramassage;

  const PressingDetailView({
    Key? key,
    this.isA = false,
    this.currentStatus,
    required this.ramassage,
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
              viewModel.clearRamassageDetail();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        backgroundColor: kcWhiteColors,
        title: const TextComponent(
          "Détails de la demande",
          fontweight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: _PressingDetailContent(
        isAccepted: isA,
        currentStatus: currentStatus,
        ramassage: ramassage,
        viewModel: viewModel,
      ),
    );
  }

  @override
  HomePressingViewModel viewModelBuilder(BuildContext context) =>
      HomePressingViewModel();

  @override
  void onViewModelReady(HomePressingViewModel viewModel) {
    // Charger les détails du ramassage si nécessaire
    viewModel.getRamassageDetailComplet(ramassage.id!);
  }
}

class _PressingDetailContent extends ViewModelWidget<HomePressingViewModel> {
  final bool isAccepted;
  final String? currentStatus;
  final Ramassage ramassage;
  final HomePressingViewModel viewModel;

  const _PressingDetailContent({
    required this.isAccepted,
    this.currentStatus,
    required this.ramassage,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context, HomePressingViewModel viewModel) {
    if (viewModel.isBusy || viewModel.selectedRamassageDetail == null) {
      return const Center(
          child: CircularProgressIndicator(
        color: primaryColor,
      ));
    }
    final currentRamassage = viewModel.selectedRamassageDetail;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //* adresse ramassage
                  const TextComponent("Adresse de ramassage",
                      fontsize: 17, textcolor: kcLightGrey),
                  const SizedBox(height: 10),
                  TextComponent(currentRamassage!.adresseRamassage!,
                      fontsize: 16,
                      fontweight: FontWeight.bold,
                      textcolor: primaryColor),
                  const SizedBox(height: 20),

                  //* adresse livraison
                  const TextComponent("Adresse de livraison",
                      fontsize: 17, textcolor: kcLightGrey),
                  const SizedBox(height: 10),
                  TextComponent(currentRamassage.adresseLivraison!,
                      fontsize: 16,
                      fontweight: FontWeight.bold,
                      textcolor: primaryColor),
                  const SizedBox(height: 20),

                  //* date de ramassage
                  const TextComponent("Date de ramassage",
                      fontsize: 17, textcolor: kcLightGrey),
                  const SizedBox(height: 10),
                  TextComponent(
                    currentRamassage.dateRamassage != null
                        ? viewModel
                            .changeFormatDate(currentRamassage.dateRamassage!)
                        : "Date non disponible",
                    fontsize: 16,
                    fontweight: FontWeight.bold,
                    textcolor: primaryColor,
                  ),
                  const SizedBox(height: 20),

                  //* DETAILS Client
                  const TextComponent(
                    "Détails du client",
                    fontsize: 20,
                    textcolor: black,
                    fontweight: FontWeight.w500,
                  ),
                  const SizedBox(height: 15),

                  //* nom du client
                  const TextComponent("Client",
                      fontsize: 17, textcolor: kcLightGrey),
                  const SizedBox(height: 10),
                  TextComponent(
                    '${currentRamassage.client?.prenom ?? ''} ${currentRamassage.client?.nom ?? ''}'
                        .trim(),
                    fontsize: 16,
                    fontweight: FontWeight.bold,
                    textcolor: primaryColor,
                  ),
                  const SizedBox(height: 20),

                  //* telephone du client
                  const TextComponent("Numéro du client",
                      fontsize: 17, textcolor: kcLightGrey),
                  const SizedBox(height: 10),
                  TextComponent(
                    currentRamassage.client?.telephone ?? '',
                    fontsize: 16,
                    fontweight: FontWeight.bold,
                    textcolor: primaryColor,
                  ),
                  const SizedBox(height: 20),

                  //* mail du client
                  const TextComponent("Mail du client",
                      fontsize: 17, textcolor: kcLightGrey),
                  const SizedBox(height: 10),
                  TextComponent(
                    currentRamassage.client?.email ?? '',
                    fontsize: 16,
                    fontweight: FontWeight.bold,
                    textcolor: primaryColor,
                  ),

                  const SizedBox(height: 20),

                  //* numero de commande
                  const TextComponent("Numéro de commande",
                      fontsize: 17, textcolor: kcLightGrey),
                  const SizedBox(height: 10),
                  TextComponent(
                    currentRamassage.numero ?? "N/A",
                    fontsize: 16,
                    fontweight: FontWeight.bold,
                    textcolor: primaryColor,
                  ),
                  const SizedBox(height: 20),

                  //* DETAILS RAMASSEUR
                  const TextComponent(
                    "Détails du ramasseur",
                    fontsize: 20,
                    textcolor: black,
                    fontweight: FontWeight.w500,
                  ),
                  const SizedBox(height: 15),

                  //* nom du ramasseur
                  const TextComponent("Nom du ramasseur",
                      fontsize: 17, textcolor: kcLightGrey),
                  const SizedBox(height: 10),
                  TextComponent(
                    '${currentRamassage.ramasseur?.prenom ?? ''} ${currentRamassage.ramasseur?.nom ?? ''}'
                        .trim(),
                    fontsize: 16,
                    fontweight: FontWeight.bold,
                    textcolor: primaryColor,
                  ),
                  const SizedBox(height: 20),

                  //* telephone du ramassage
                  const TextComponent("Numéro du ramasseur",
                      fontsize: 17, textcolor: kcLightGrey),
                  const SizedBox(height: 10),
                  TextComponent(
                    currentRamassage.ramasseur?.telephone ?? '',
                    fontsize: 16,
                    fontweight: FontWeight.bold,
                    textcolor: primaryColor,
                  ),
                  const SizedBox(height: 20),

                  //* DETAILS VETEMENTS
                  const TextComponent(
                    "Détails du lavage",
                    fontsize: 20,
                    textcolor: black,
                    fontweight: FontWeight.w500,
                  ),
                  const SizedBox(height: 15),

                  const TextComponent("Vêtements",
                      fontsize: 17, textcolor: kcLightGrey),
                  const SizedBox(height: 10),
                  Container(
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
                          currentRamassage.details
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextComponent(
                            currentRamassage.servicesComplementaires
                                    ?.map((item) => '${item.libelle}')
                                    .join('\n') ??
                                'Aucun détail',
                            fontsize: 16,
                            textcolor: darkGreyColor),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 20),

                  //* Bouton principal
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDemandCompletedDialog(
                            context: context,
                            clientName:
                                '${currentRamassage.client?.prenom ?? ''} ${currentRamassage.client?.nom ?? ''}',
                            onAccept: () {
                              viewModel
                                  .validateSelectedRamassage(ramassage.id!);
                              Navigator.of(context).pop();
                              viewModel.clearRamassageDetail();
                              viewModel.navigationService
                                  .replaceWithNavBarPressingView();
                            },
                            onDecline: () {
                              Navigator.of(context).pop();
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF184E9C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.phone_outlined,
                            color: Colors.white),
                        label: const Text(
                          'Contacter le ramasseur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

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
            ),
    );
  }
}
