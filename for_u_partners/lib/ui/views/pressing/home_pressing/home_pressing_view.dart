import 'package:stacked/stacked.dart';
import 'home_pressing_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/views/pressing/widgets/wallet_widget.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/pressing_detail.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/facturation_view.dart';
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
        appBar: _buildCustomAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WalletPressingWidget(balance: "67,500 FCFA"),
                const _TabBarSection(),
                _TabBarContent(viewModel: viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
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
                      child: const Center(
                        child: Text(
                          'O',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Olivier ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
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

class _TabBarContent extends StatelessWidget {
  final HomePressingViewModel viewModel;
  const _TabBarContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: TabBarView(
        children: [
          //* Tab Ramassage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const TextComponent(
                "Demandes récentes",
                fontweight: FontWeight.bold,
                fontsize: 19,
              ),
              PressingDemandWidget(
                name: "Teddy TOUSSOU",
                isValid: true,
                status: viewModel.ramassageStatus,
                onClick: () async {
                  if (viewModel.ramassageStatus == "En attente") {
                    // Premier clic - aller à la page de détail pour accepter
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PressingDetailView(isA: viewModel.isAccepted),
                      ),
                    );

                    if (result == true) {
                      viewModel.setAccepted(true);
                    }
                  } else if (viewModel.ramassageStatus ==
                      "En attente de facturation") {
                    // Deuxième clic - aller à la page avec bouton "Finaliser"
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FacturationView(),
                      ),
                    );

                    if (result == true) {
                      viewModel.finalizeRamassage();
                    }
                  }
                  // Si "Terminé", on peut aller vers une page de détail ou ne rien faire
                },
                date: "Mardi 12 Décembre 2025",
                place: "EREVAN, Cadjehoun Aeroport",
              ),
            ],
          ),

          //* Tab Dépôt de vêtements
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const TextComponent(
                "Demandes de dépôt",
                fontweight: FontWeight.bold,
                fontsize: 19,
              ),
              _DepotDemandWidget(
                name: "Teddy TOSSOU",
                date: "Mardi 26 Mars à 15h30",
                status: viewModel.depotStatus,
                onTap: () async {
                  if (viewModel.depotStatus == "Validé") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FacturationView()),
                    );
                  } else {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DepotDetailView()),
                    );

                    if (result == true) {
                      viewModel.setDepotStatus("Validé");
                    } else if (result == false) {
                      viewModel.setDepotStatus("Rejeté");
                    }
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _DepotDemandWidget extends StatelessWidget {
  final String name;
  final String date;
  final String status;
  final VoidCallback onTap;

  const _DepotDemandWidget({
    required this.name,
    required this.date,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color textColor;

    switch (status) {
      case "Validé":
        bgColor = const Color.fromARGB(37, 16, 185, 129);
        textColor = Colors.green;
        break;
      case "Rejeté":
        bgColor = const Color.fromARGB(32, 239, 68, 68);
        textColor = Colors.red;
        break;
      default:
        bgColor = null;
        textColor = const Color(0xFF6b7280);
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFe5e7eb)),
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
              // Nom et date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8e8e93),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status
              bgColor != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
