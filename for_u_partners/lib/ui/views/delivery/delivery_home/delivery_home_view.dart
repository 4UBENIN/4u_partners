import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/views/delivery/delivery_home/widgets/current_ride_widget.dart';
import 'package:for_u_partners/ui/views/pressing/widgets/animated_dot.dart';
import 'package:stacked/stacked.dart';
import 'delivery_home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/delivery/delivery_home/widgets/wallet_widget.dart';
import 'package:for_u_partners/ui/views/delivery/delivery_home/widgets/summary_widget.dart';

class DeliveryHomeView extends StackedView<DeliveryHomeViewModel> {
  const DeliveryHomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DeliveryHomeViewModel viewModel,
    Widget? child,
  ) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kcWhiteColors,
        appBar: _buildCustomAppBar(viewModel),
        body: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DeliveryWalletWidget(
                        balance: viewModel.isBusy
                            ? "..."
                            : "${viewModel.wallet} FCFA",
                      ),
                      const SizedBox(height: 24),
                      const DeliverySummaryWidget(
                        todayCourses: 8,
                        todayEarnings: '32,500 FCFA',
                      ),
                      const SizedBox(height: 24),
                      const TabBar(
                        labelColor: primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: primaryColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelStyle: TextStyle(fontSize: 15),
                        tabs: [
                          Tab(text: 'Livraisons'),
                          Tab(text: 'Ramassages'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _TabBarContent(viewModel: viewModel),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(DeliveryHomeViewModel viewModel) {
    return AppBar(
      backgroundColor: kcWhiteColors,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Row(
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
                  child: Text(
                    viewModel.getUserInitials(),
                    style: const TextStyle(
                      color: kcWhiteColors,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  viewModel.isBusy
                      ? const DotsLoader()
                      : TextComponent(viewModel.userName),
                  if (viewModel.userRole.isNotEmpty)
                    Text(
                      viewModel.userRole,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }

  @override
  DeliveryHomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DeliveryHomeViewModel();
}

class _TabBarContent extends StatelessWidget {
  final DeliveryHomeViewModel viewModel;
  const _TabBarContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: TabBarView(
        children: [
          //* Tab LIVRAISON
          viewModel.userRole == "ramasseur"
              ? Center(
                  child: TextComponent("Aucune demandes de livraison"),
                )
              : Column(
                  children: [],
                ),

          //* Tab RAMASSAGE
          viewModel.userRole == "livreur"
              ? Center(
                  child: TextComponent("Aucune demandes de ramassage"),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                  ],
                ),
        ],
      ),
    );
  }
}
