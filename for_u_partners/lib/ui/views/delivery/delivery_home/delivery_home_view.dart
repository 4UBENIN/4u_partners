import 'package:stacked/stacked.dart';
import 'delivery_home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/delivery/delivery_home/widgets/wallet_widget.dart';
import 'package:for_u_partners/ui/views/delivery/delivery_home/widgets/summary_widget.dart';
import 'package:for_u_partners/ui/views/delivery/delivery_home/widgets/activity_widget.dart';
import 'package:for_u_partners/ui/views/delivery/delivery_home/widgets/current_ride_widget.dart';

class DeliveryHomeView extends StackedView<DeliveryHomeViewModel> {
  const DeliveryHomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DeliveryHomeViewModel viewModel,
    Widget? child,
  ) {
    return DefaultTabController(
      length: 2, // Nombre de tabs
      child: Scaffold(
        backgroundColor: kcWhiteColors,
        appBar: _buildCustomAppBar(),
        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeliveryWalletWidget(balance: '67,500 FCFA'),
                SizedBox(height: 24),
                DeliverySummaryWidget(
                  todayCourses: 8,
                  todayEarnings: '32,500 FCFA',
                ),
                SizedBox(height: 24),
                DeliveryCurrentRideWidget(),
                SizedBox(height: 30),
                Text(
                  'Activité récente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 15),
                DeliveryActivityWidget(),
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
                          'G',
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
                      'Gerard ',
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
  DeliveryHomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DeliveryHomeViewModel();
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
        Tab(text: 'Livraisons'),
        Tab(text: 'Ramassage'),
      ],
    );
  }
}

class _TabBarContent extends StatelessWidget {
  final DeliveryHomeViewModel viewModel;
  const _TabBarContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: TabBarView(
        children: [
          //* Tab LIVRAISON
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          ),

          //* Tab RAMASSAGE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          ),
        ],
      ),
    );
  }
}
