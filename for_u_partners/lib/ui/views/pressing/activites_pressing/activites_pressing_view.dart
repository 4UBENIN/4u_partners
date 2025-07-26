import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'activites_pressing_viewmodel.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/pressing/activites_pressing/widgets/activity_detail_view.dart';
import 'package:for_u_partners/ui/views/pressing/activites_pressing/models/pressing_activities_models.dart';

class ActivitesPressingView extends StackedView<ActivitesPressingViewModel> {
  const ActivitesPressingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ActivitesPressingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            _buildStatsSection(viewModel),
            const SizedBox(height: 30),
            _buildFilterTabs(viewModel),
            const SizedBox(height: 20),
            _buildActivitiesList(context, viewModel),
            const SizedBox(height: 100), // Espace pour la bottom nav
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Activités',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildStatsSection(ActivitesPressingViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF184E9C), Color(0xFF2563eb)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aujourd\'hui',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${viewModel.todayCount} demandes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white30,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cette semaine',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${viewModel.weekCount} demandes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(ActivitesPressingViewModel viewModel) {
    return Row(
      children: [
        _buildFilterChip(
          'Toutes',
          viewModel.selectedFilter == 'all',
          () => viewModel.setFilter('all'),
        ),
        const SizedBox(width: 12),
        _buildFilterChip(
          'Ramassage',
          viewModel.selectedFilter == 'pickup',
          () => viewModel.setFilter('pickup'),
        ),
        const SizedBox(width: 12),
        _buildFilterChip(
          'Dépôt',
          viewModel.selectedFilter == 'deposit',
          () => viewModel.setFilter('deposit'),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF184E9C) : const Color(0xFFf1f3f4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6b7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context, ActivitesPressingViewModel viewModel) {
    final filteredActivities = viewModel.getFilteredActivities();
    
    if (filteredActivities.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: filteredActivities.map((activity) {
        return _ActivityCard(
          activity: activity,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ActivityDetailView(activity: activity),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFf1f3f4),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 40,
              color: Color(0xFF8e8e93),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune activité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les demandes acceptées apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8e8e93),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ActivitesPressingViewModel viewModelBuilder(BuildContext context) =>
      ActivitesPressingViewModel();
}

class _ActivityCard extends StatelessWidget {
  final PressingActivityModel activity;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.04),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFf1f3f4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: activity.type == 'pickup' 
                                ? const Color(0xFF10b981).withOpacity(0.1)
                                : const Color(0xFF184E9C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            activity.type == 'pickup' 
                                ? Icons.local_shipping_outlined
                                : Icons.local_laundry_service_outlined,
                            color: activity.type == 'pickup' 
                                ? const Color(0xFF10b981)
                                : const Color(0xFF184E9C),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.clientName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1a1a1a),
                              ),
                            ),
                            Text(
                              activity.type == 'pickup' ? 'Ramassage' : 'Dépôt',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8e8e93),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          activity.amount,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF184E9C),
                          ),
                        ),
                        Text(
                          activity.getFormattedDate(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8e8e93),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: const Color(0xFF8e8e93),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8e8e93),
                        ),
                      ),
                    ),
                  ],
                ),
                if (activity.services.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: activity.services.take(2).map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf1f3f4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}