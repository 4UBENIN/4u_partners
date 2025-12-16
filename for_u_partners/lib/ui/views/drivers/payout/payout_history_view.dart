import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'payout_history_viewmodel.dart';
import 'package:for_u_partners/app/models/payout_model.dart';

class PayoutHistoryView extends StackedView<PayoutHistoryViewModel> {
  const PayoutHistoryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PayoutHistoryViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        title: const Text(
          'Historique des retraits',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: viewModel.isBusy && viewModel.payouts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: Column(
                children: [
                  _buildFilterChips(viewModel),
                  const SizedBox(height: 8),
                  Expanded(
                    child: viewModel.payouts.isEmpty
                        ? _buildEmptyState(viewModel)
                        : _buildPayoutList(viewModel),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.navigateToCreatePayout,
        backgroundColor: const Color(0xFF007AFF),
        icon: const Icon(Icons.add),
        label: const Text(
          'Nouveau retrait',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildFilterChips(PayoutHistoryViewModel viewModel) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: viewModel.statusFilters.length,
        itemBuilder: (context, index) {
          final filter = viewModel.statusFilters[index];
          final isSelected = viewModel.selectedStatusFilter == filter['value'] ||
              (viewModel.selectedStatusFilter == null && filter['value'] == '');

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  viewModel.setStatusFilter(
                      filter['value']!.isEmpty ? null : filter['value']);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF007AFF),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF007AFF)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPayoutList(PayoutHistoryViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: viewModel.payouts.length + (viewModel.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.payouts.length) {
          // Load more indicator
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ElevatedButton(
                onPressed: viewModel.loadMore,
                child: const Text('Charger plus'),
              ),
            ),
          );
        }

        final payout = viewModel.payouts[index];
        return _buildPayoutItem(payout, viewModel);
      },
    );
  }

  Widget _buildPayoutItem(PayoutModel payout, PayoutHistoryViewModel viewModel) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'fr_FR');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () => viewModel.navigateToPayoutDetails(payout),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: viewModel.getStatusColor(payout).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      viewModel.getStatusIcon(payout),
                      color: viewModel.getStatusColor(payout),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payout.displayStatus,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: viewModel.getStatusColor(payout),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ref: ${payout.reference}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${payout.amount.toStringAsFixed(0)} ${payout.currency}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.black.withOpacity(0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(payout.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
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

  Widget _buildEmptyState(PayoutHistoryViewModel viewModel) {
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
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun retrait',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos demandes de retrait apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: viewModel.navigateToCreatePayout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Nouveau retrait',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  PayoutHistoryViewModel viewModelBuilder(BuildContext context) =>
      PayoutHistoryViewModel();

  @override
  void onViewModelReady(PayoutHistoryViewModel viewModel) {
    viewModel.initialize();
  }
}
