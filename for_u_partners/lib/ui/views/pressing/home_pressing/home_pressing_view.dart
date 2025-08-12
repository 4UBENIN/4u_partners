import 'package:for_u_partners/ui/common/app_button_component.dart';
import 'package:for_u_partners/ui/common/app_textInput.dart';
import 'package:for_u_partners/ui/common/bottomsheet_component.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/pressing_detail.dart';
import 'package:for_u_partners/ui/views/pressing/widgets/animated_dot.dart';
import 'package:stacked/stacked.dart';
import 'home_pressing_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/views/pressing/widgets/wallet_widget.dart';
import 'package:for_u_partners/ui/views/pressing/widgets/pressing_demand_widget.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/pressing_depot_detail.dart';

class HomePressingView extends StackedView<HomePressingViewModel> {
  const HomePressingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomePressingViewModel viewModel,
    Widget? child,
  ) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kcWhiteColors,
        appBar: _buildCustomAppBar(viewModel),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WalletPressingWidget(
                balance: viewModel.isBusy ? "..." : "${viewModel.wallet} FCFA",
                onAdd: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => customBottomsheetComponent(
                      context,
                      column: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextComponent(
                            "Quel montant souhaitez-vous ajouter à votre portefeuille ?",
                            fontweight: FontWeight.bold,
                            fontsize: 18,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextInputField(
                            bigLabel: "Montant",
                            hintText: "1000 FCFA",
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          PrimaryButton(text: "Ajouter", onPressed: () {})
                        ],
                      ),
                    ),
                  );
                },
              ),
              const _TabBarSection(),
              Expanded(
                child: TabBarView(
                  children: [
                    // Premier onglet : Ramassage
                    _buildRamassageTab(viewModel),
                    // Deuxième onglet : Dépôt de vêtements
                    _buildDepotTab(viewModel, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //* BUILD RAMASSAGE TAB
  Widget _buildRamassageTab(HomePressingViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(
          child: CircularProgressIndicator(
        color: primaryColor,
      ));
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(viewModel.errorMessage!),
            ElevatedButton(
              onPressed: viewModel.retry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (viewModel.ramassages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune demande de ramassage trouvée'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const TextComponent(
          "Demandes récentes",
          fontweight: FontWeight.bold,
          fontsize: 19,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.ramassages.length,
            itemBuilder: (context, index) {
              final ramassage = viewModel.ramassages[index];
              return PressingDemandWidget(
                ramassage: ramassage,
                onTap: () async {
                  await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PressingDetailView(
                          isA: false,
                          currentStatus: "En attente",
                          ramassage: ramassage,
                        ),
                      ));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  //* BUILD DEPOT TAB
  Widget _buildDepotTab(HomePressingViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Filtres
        Row(
          children: [
            FilterChip(
              label: const Text("Demandes"),
              selected: viewModel.demands,
              onSelected: (value) {
                viewModel.toggleDemandsFilter();
              },
              backgroundColor: Colors.grey[100],
              selectedColor: const Color(0xFF184E9C).withOpacity(0.1),
              labelStyle: TextStyle(
                color: viewModel.demands
                    ? const Color(0xFF184E9C)
                    : Colors.grey[600],
                fontWeight:
                    viewModel.demands ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: viewModel.demands
                    ? const Color(0xFF184E9C)
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: const Text("Planifiés"),
              selected: viewModel.planified,
              onSelected: (value) {
                viewModel.togglePlanifiedFilter();
              },
              backgroundColor: Colors.grey[100],
              selectedColor: const Color(0xFF10B981).withOpacity(0.1),
              labelStyle: TextStyle(
                color: viewModel.planified
                    ? const Color(0xFF10B981)
                    : Colors.grey[600],
                fontWeight:
                    viewModel.planified ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: viewModel.planified
                    ? const Color(0xFF10B981)
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Contenu selon le filtre sélectionné
        Expanded(
          child: _buildDepotContent(viewModel, context),
        ),
      ],
    );
  }

  Widget _buildDepotContent(
      HomePressingViewModel viewModel, BuildContext context) {
    // Utiliser isLoadingDepots pour un loading plus précis
    if (viewModel.isLoadingDepots || 
        (viewModel.isBusy && viewModel.currentDepotList.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(viewModel.errorMessage!),
            ElevatedButton(
              onPressed: () {
                if (viewModel.demands) {
                  viewModel.getDepotList();
                } else {
                  viewModel.getPlanifiedDepotList();
                }
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final currentList = viewModel.currentDepotList;

    if (currentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              viewModel.demands ? Icons.inbox : Icons.schedule,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.demands
                  ? 'Aucune demande de dépôt trouvée'
                  : 'Aucun dépôt planifié trouvé',
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextComponent(
          viewModel.demands ? "Demandes de dépôt" : "Rendez-vous planifiés",
          fontweight: FontWeight.bold,
          fontsize: 19,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: currentList.length,
            itemBuilder: (context, index) {
              final depot = currentList[index];
              return _DepotDemandWidget(
                name:
                    '${depot.client?.prenom ?? ''} ${depot.client?.nom ?? ''}',
                date: viewModel.changeFormatDate(depot.dateRdv!),
                isPlanned: viewModel.planified,
                status: depot.statut,
                onTap: () async {
                  // Attendre le retour et vérifier s'il y a eu des changements
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DepotDetailView(depot: depot),
                    ),
                  );
                  
                  // Si result est true, cela signifie qu'un dépôt a été planifié
                  if (result == true) {
                    // Rafraîchir les listes
                    await viewModel.getDepotList();
                    await viewModel.getPlanifiedDepotList();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  //* BUILD APP BAR
  PreferredSizeWidget _buildCustomAppBar(HomePressingViewModel viewModel) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: Color(0xFFe5e7eb),
          )),
          color: Colors.white,
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF184E9C),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: viewModel.isBusy
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primaryColor),
                              )
                            : Text(
                                viewModel.pressingDetails?.nom.isNotEmpty ==
                                        true
                                    ? viewModel.pressingDetails!.nom[0]
                                        .toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    viewModel.isBusy
                        ? const DotsLoader()
                        : Text(
                            viewModel.pressingDetails?.nom.isNotEmpty == true
                                ? viewModel.pressingDetails!.nom
                                : '?',
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'EN LIGNE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  HomePressingViewModel viewModelBuilder(BuildContext context) =>
      HomePressingViewModel();
}

class _TabBarSection extends StatelessWidget {
  const _TabBarSection();

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Color(0xFF184E9C),
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(fontSize: 15),
      tabs: [
        Tab(text: 'Ramassage'),
        Tab(text: 'Dépot de vêtements'),
      ],
    );
  }
}

class _DepotDemandWidget extends StatelessWidget {
  final String name;
  final String date;
  final VoidCallback onTap;
  final bool isPlanned;
  final String? status;

  const _DepotDemandWidget({
    required this.name,
    required this.date,
    required this.onTap,
    this.isPlanned = false,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isPlanned
                  ? const Color(0xFF10B981).withOpacity(0.3)
                  : const Color(0xFFe5e7eb),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                  ),
                  if (status != null) _buildStatusChip(status!),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    isPlanned ? Icons.schedule : Icons.access_time,
                    size: 16,
                    color: isPlanned ? const Color(0xFF10B981) : primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: date,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isPlanned
                                  ? const Color(0xFF10B981)
                                  : primaryColor,
                            ),
                          )
                        ],
                        text:
                            isPlanned ? "Planifié pour le " : "Rendez-vous le ",
                        style: const TextStyle(
                          fontSize: 14,
                          color: mediumGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'en_attente':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        displayText = 'En attente';
        break;
      case 'confirme':
      case 'confirmed':
        backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
        textColor = const Color(0xFF10B981);
        displayText = 'Confirmé';
        break;
      case 'planifie':
      case 'planned':
        backgroundColor = const Color(0xFF184E9C).withOpacity(0.1);
        textColor = const Color(0xFF184E9C);
        displayText = 'Planifié';
        break;
      case 'termine':
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        displayText = 'Terminé';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[600]!;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}