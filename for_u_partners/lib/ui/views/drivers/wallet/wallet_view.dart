import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'wallet_viewmodel.dart';

class WalletView extends StackedView<WalletViewModel> {
  const WalletView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    WalletViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverAppBar(
                    expandedHeight: 100,
                    floating: false,
                    pinned: true,
                    backgroundColor: Color(0xFFF5F5F7),
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                      title: Text(
                        'Portefeuille',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildBalanceCard(context, viewModel),
                          const SizedBox(height: 16),
                          if (viewModel.hasUncollectedBonuses) ...[
                            _buildBonusCard(context, viewModel),
                            const SizedBox(height: 16),
                          ],
                          _buildQuickActions(context, viewModel),
                          const SizedBox(height: 24),
                          const Text(
                            'Activité',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  viewModel.transactions.isEmpty && !viewModel.isLoadingPayouts
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                // Show actual transactions
                                if (index < viewModel.transactions.length) {
                                  final transaction = viewModel.transactions[index];
                                  return _buildTransactionItem(transaction);
                                }
                                // Show shimmer placeholders for loading payouts
                                else if (viewModel.isLoadingPayouts) {
                                  return _buildShimmerTransactionItem();
                                }
                                return const SizedBox.shrink();
                              },
                              childCount: viewModel.transactions.length +
                                  (viewModel.isLoadingPayouts ? 3 : 0), // Show 3 shimmer items while loading
                            ),
                          ),
                        ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletViewModel viewModel) {
    final bool isNegativeOrZero = viewModel.balance <= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNegativeOrZero
              ? [
                  const Color(0xFFDC2626),
                  const Color(0xFFB91C1C),
                ]
              : [
                  const Color(0xFF007AFF),
                  const Color(0xFF0051D5),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isNegativeOrZero
                ? const Color(0xFFDC2626).withOpacity(0.3)
                : const Color(0xFF007AFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Solde disponible',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${viewModel.balance.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusCard(BuildContext context, WalletViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFFFF9500),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Bonus disponibles',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${viewModel.totalUncollectedAmount.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${viewModel.uncollectedBonuses.length} bonus non collecté${viewModel.uncollectedBonuses.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: viewModel.isCollecting
                    ? null
                    : () => viewModel.collectAllBonuses(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9500),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: viewModel.isCollecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Collecter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WalletViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(4),
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
          Expanded(
            child: _buildActionButton(
              icon: Icons.add_rounded,
              label: 'Recharger',
              color: const Color(0xFF007AFF),
              onPressed: () => viewModel.rechargeWallet(context),
            ),
          ),
          Expanded(
            child: _buildActionButton(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Retrait',
              color: const Color(0xFF34C759),
              onPressed: () => viewModel.navigateToRetrait(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isCredit = transaction['type'] == 'credit';
    final status = transaction['status'] ?? 'completed';
    final amount = transaction['amount'] ?? '0';
    final reference = transaction['reference'];
    final createdAt = transaction['created_at'];

    // Format date
    String formattedDate = '';
    if (createdAt != null) {
      try {
        final DateTime dateTime = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(dateTime);

        if (difference.inDays == 0) {
          formattedDate = 'Aujourd\'hui à ${DateFormat('HH:mm').format(dateTime)}';
        } else if (difference.inDays == 1) {
          formattedDate = 'Hier à ${DateFormat('HH:mm').format(dateTime)}';
        } else if (difference.inDays < 7) {
          formattedDate = '${difference.inDays} jours';
        } else {
          formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
        }
      } catch (e) {
        formattedDate = createdAt.toString();
      }
    }

    // Get transaction description
    String description;
    if (isCredit) {
      description = 'Recharge'; // Show "Recharge" for all credit transactions
    } else {
      // For debits, use reference if available, otherwise show "Débit"
      description = (reference != null && reference.toString().isNotEmpty)
          ? reference.toString()
          : 'Débit';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCredit
                      ? const Color(0xFF34C759).withOpacity(0.1)
                      : const Color(0xFFFF3B30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isCredit ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            description,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(status),
                      ],
                    ),
                    if (formattedDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (transaction['id'] != null)
                Text(
                  '#${transaction['id']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              Text(
                '${isCredit ? '+' : '-'}${_formatAmount(amount)} FCFA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? const Color(0xFF34C759) : const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'sent':
        backgroundColor = const Color(0xFF34C759).withOpacity(0.1);
        textColor = const Color(0xFF34C759);
        label = status.toLowerCase() == 'sent' ? 'Envoyé' : 'Terminé';
        break;
      case 'pending':
        backgroundColor = const Color(0xFFFF9500).withOpacity(0.1);
        textColor = const Color(0xFFFF9500);
        label = 'En attente';
        break;
      case 'started':
        backgroundColor = const Color(0xFF007AFF).withOpacity(0.1);
        textColor = const Color(0xFF007AFF);
        label = 'En cours';
        break;
      case 'failed':
      case 'cancelled':
        backgroundColor = const Color(0xFFFF3B30).withOpacity(0.1);
        textColor = const Color(0xFFFF3B30);
        label = 'Échoué';
        break;
      default:
        backgroundColor = const Color(0xFF94A3B8).withOpacity(0.1);
        textColor = const Color(0xFF94A3B8);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatAmount(dynamic amount) {
    try {
      final numAmount = double.parse(amount.toString());
      return NumberFormat('#,###', 'fr_FR').format(numAmount);
    } catch (e) {
      return amount.toString();
    }
  }

  Widget _buildShimmerTransactionItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 50),
                          Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 100,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos transactions apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  WalletViewModel viewModelBuilder(BuildContext context) => WalletViewModel();
}
