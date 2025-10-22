import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'profil_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';

class ProfilView extends StackedView<ProfilViewModel> {
  const ProfilView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProfilViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: viewModel.isLoading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: kcPrimaryColor,
                size: 50,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    // Avatar
                    Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF184E9C), Color(0xFF2A5BB8)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            viewModel.initials,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Stats Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              viewModel.globalStats?.totalActivities
                                      .toString() ??
                                  '0',
                              'Courses',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              viewModel.globalStats?.totalNotes.toString() ??
                                  '0',
                              'Note',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              _formatAmount(viewModel.globalStats?.totalEarnings
                                      .toDouble() ??
                                  0),
                              'Revenus',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: _buildUserIcon(),
                            text: 'Mon compte',
                            onTap: () {
                              viewModel.navigateToEditProfile(context);
                            },
                          ),
                          _buildMenuItem(
                            icon: _buildCarIcon(),
                            text: 'Mes véhicules',
                            onTap: () {
                              viewModel.navigationService.navigateTo(Routes.mesVehiculesView);
                            },
                          ),
                          _buildMenuItem(
                            icon: _buildDocumentsIcon(),
                            text: 'Documents',
                            onTap: () {
                              viewModel.navigationService.navigateToDocumentsView();
                            },
                          ),
                          _buildMenuItem(
                            icon: _buildHistoryIcon(),
                            text: 'Historique',
                            onTap: () {
                              viewModel.navigationService
                                  .navigateToActivityView();
                            },
                          ),
                          _buildMenuItem(
                            icon: _buildLogoutIcon(),
                            text: 'Déconnexion',
                            isLogout: true,
                            onTap: () {
                              viewModel.showLogoutConfirmationDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Fonction utilitaire pour formater les montants
  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M F';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1).replaceAll('.0', '')}K F';
    } else {
      return '${amount.toStringAsFixed(0)} F';
    }
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF184E9C),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildMenuItem({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: icon,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: isLogout
                        ? const Color(0xFFDC3545)
                        : const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '›',
                style: TextStyle(
                  fontSize: 18,
                  color: isLogout
                      ? const Color(0xFFDC3545)
                      : const Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserIcon() {
    return const Icon(Icons.person_outline, size: 24);
  }

  Widget _buildWalletIcon() {
    return const Icon(Icons.account_balance_wallet_outlined, size: 24);
  }

  Widget _buildCarIcon() {
    return const Icon(Icons.directions_car_outlined, size: 24);
  }

  Widget _buildDocumentsIcon() {
    return const Icon(Icons.description_outlined, size: 24);
  }

  Widget _buildHistoryIcon() {
    return const Icon(Icons.history_outlined, size: 24);
  }

  Widget _buildHelpIcon() {
    return const Icon(Icons.help_outline, size: 24);
  }

  Widget _buildLogoutIcon() {
    return const Icon(Icons.logout_outlined, size: 24);
  }

  @override
  ProfilViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ProfilViewModel();
}

// Custom Icons using Material Icons
