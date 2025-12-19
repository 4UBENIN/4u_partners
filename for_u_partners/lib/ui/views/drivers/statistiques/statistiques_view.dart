import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'statistiques_viewmodel.dart';

class StatistiquesView extends StackedView<StatistiquesViewModel> {
  const StatistiquesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StatistiquesViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'Statistiques',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kcPrimaryColor),
      ),
      body: viewModel.isLoading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: kcPrimaryColor,
                size: 50,
              ),
            )
          : RefreshIndicator(
              onRefresh: viewModel.loadGlobalStats,
              color: kcPrimaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Section
                    const Text(
                      'Vue d\'ensemble',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Main Stats Cards
                    _buildMainStatCard(
                      icon: Icons.local_taxi_rounded,
                      title: 'Courses totales',
                      value: viewModel.globalStats?.totalActivities.toString() ?? '0',
                      color: kcPrimaryColor,
                    ),

                    const SizedBox(height: 12),

                    _buildMainStatCard(
                      icon: Icons.star_rounded,
                      title: 'Note moyenne',
                      value: viewModel.globalStats?.totalNotes.toString() ?? '0',
                      color: const Color(0xFFFFCC00),
                    ),

                    const SizedBox(height: 12),

                    _buildMainStatCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Revenus totaux',
                      value: _formatAmount(viewModel.globalStats?.totalEarnings.toDouble() ?? 0),
                      color: const Color(0xFF34C759),
                    ),

                    const SizedBox(height: 32),

                    // Additional Info
                    const Text(
                      'Détails',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildDetailCard(
                      context,
                      children: [
                        _buildDetailRow(
                          'Courses aujourd\'hui',
                          '0',
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Courses cette semaine',
                          '0',
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Courses ce mois',
                          '0',
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMainStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF3A3A3C),
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: kcPrimaryColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M F';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1).replaceAll('.0', '')}K F';
    } else {
      return '${amount.toStringAsFixed(0)} F';
    }
  }

  @override
  StatistiquesViewModel viewModelBuilder(BuildContext context) =>
      StatistiquesViewModel();
}
