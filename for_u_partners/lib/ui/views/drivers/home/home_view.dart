import 'package:for_u_partners/ui/views/pressing/widgets/animated_dot.dart';

import 'home_viewmodel.dart';
import 'widgets/wallet_widget.dart';
import 'widgets/summary_widget.dart';
import 'package:stacked/stacked.dart';
import 'widgets/activity_widget.dart';
import 'package:flutter/material.dart';
import 'widgets/current_ride_widget.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcWhiteColors,
      appBar: _buildCustomAppBar(viewModel),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WalletWidget(balance: '67,500 FCFA'),
              SizedBox(height: 24),
              SummaryWidget(
                todayCourses: 8,
                todayEarnings: '32,500 FCFA',
              ),
              SizedBox(height: 24),
              CurrentRideWidget(),
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
              ActivityWidget(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(HomeViewModel model) {
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
                        child: model.isBusy
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primaryColor),
                              )
                            : Text(
                                model.name!.isNotEmpty == true
                                    ? model.name![0].toUpperCase()
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
                   model.isBusy
                        ? const DotsLoader()
                        : Text(
                            model.name!.isNotEmpty == true
                                ? model.name!
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
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
