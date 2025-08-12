import 'package:for_u_partners/ui/views/pressing/activites_pressing/activity_detail_view.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'activites_pressing_viewmodel.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildStatsSection(viewModel),
            const SizedBox(height: 24),
            _buildFilterTabs(viewModel),
            const SizedBox(height: 16),
            Expanded(
              child: _buildActivitiesArea(context, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onViewModelReady(ActivitesPressingViewModel viewModel) {
    // Chargement initial
    viewModel.loadFinishedActivities();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Activités',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
      ),
      centerTitle: false,
    );
  }

  Widget _buildStatsSection(ActivitesPressingViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF184E9C), Color(0xFF2563eb)],
        ),
        borderRadius: BorderRadius.circular(16),
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
                  '${viewModel.todayCount ?? 0} demandes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          const SizedBox(width: 16),
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
                  '${viewModel.weekCount ?? 0} demandes',
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

  Widget _buildActivitiesArea(
      BuildContext context, ActivitesPressingViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(
          child: CircularProgressIndicator(
        color: primaryColor,
      ));
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text('Erreur : ${viewModel.errorMessage}'));
    }

    // Filtre "Ramassage"
    if (viewModel.selectedFilter == 'pickup') {
      if (viewModel.ramassages.isEmpty) return _buildEmptyState();
      return ListView(
        children: viewModel.ramassages.map((r) {
          final name =
              '${r.client?.prenom ?? ''} ${r.client?.nom ?? ''}'.trim();
          final date = r.dateRamassage ?? '-';
          return _DepotDemandWidget(
            name: name.isEmpty ? (r.numero ?? 'Ramassage') : name,
            date: date,
            status: r.statut,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ActivityDetailView(type: 'ramassages', id: r.id!)),
              );
            },
          );
        }).toList(),
      );
    }

    // Filtre "Dépot"
    if (viewModel.selectedFilter == 'deposit') {
      if (viewModel.depot.isEmpty) return _buildEmptyState();
      return ListView(
        children: viewModel.depot.map((d) {
          final name =
              '${d.client?.prenom ?? ''} ${d.client?.nom ?? ''}'.trim();
          final date = d.dateRdv ?? '-';
          return _DepotDemandWidget(
            name: name.isEmpty ? (d.numero ?? 'Dépôt') : name,
            date: date,
            status: d.statut,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ActivityDetailView(type: 'rendezvous', id: d.id!)),
              );
            },
          );
        }).toList(),
      );
    }

    // Filtre "Toutes" -> afficher les deux sections
    final List<Widget> children = [];

    if (viewModel.ramassages.isNotEmpty) {
      children.add(const SizedBox(height: 8));
      children.add(_sectionHeader('Ramassages'));
      children.addAll(viewModel.ramassages.map((r) {
        final name = '${r.client?.prenom ?? ''} ${r.client?.nom ?? ''}'.trim();
        final date = r.dateRamassage ?? '-';
        return _DepotDemandWidget(
          name: name.isEmpty ? (r.numero ?? 'Ramassage') : name,
          date: date,
          status: r.statut,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ActivityDetailView(type: 'ramassages', id: r.id!)),
            );
          },
        );
      }));
    }

    if (viewModel.depot.isNotEmpty) {
      children.add(const SizedBox(height: 12));
      children.add(_sectionHeader('Dépôts'));
      children.addAll(viewModel.depot.map((d) {
        final name = '${d.client?.prenom ?? ''} ${d.client?.nom ?? ''}'.trim();
        final date = d.dateRdv ?? '-';
        return _DepotDemandWidget(
          name: name.isEmpty ? (d.numero ?? 'Dépôt') : name,
          date: date,
          status: d.statut,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ActivityDetailView(type: 'rendezvous', id: d.id!)),
            );
          },
        );
      }));
    }

    if (children.isEmpty) return _buildEmptyState();

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: children,
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          )),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            'Les demandes terminées apparaîtront ici',
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

class _DepotDemandWidget extends StatelessWidget {
  final String name;
  final String date;
  final VoidCallback onTap;
  final String? status;

  const _DepotDemandWidget({
    Key? key,
    required this.name,
    required this.date,
    required this.onTap,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
              Row(
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
                  _buildStatusChip(status ?? ''),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "Facturé le ",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6b7280),
                        ),
                        children: [
                          TextSpan(
                            text: changeFormatDate(date),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          )
                        ],
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

  String changeFormatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      String formatted =
          DateFormat("EEEE d MMMM 'à' HH'h'mm", 'fr_FR').format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      print("Erreur format date: $e");
      return dateString;
    }
  }

  Widget _buildStatusChip(String status) {
    final st = status.toLowerCase();
    Color backgroundColor = Colors.grey.withOpacity(0.1);
    Color textColor = Colors.grey[600]!;
    String displayText = status.isNotEmpty ? status : 'En attente';

    if (st.contains('term') || st.contains('terminé')) {
      backgroundColor = Colors.green.withOpacity(0.12);
      textColor = Colors.green[700]!;
      displayText = 'Terminé';
    } else if (st.contains('annulé')) {
      backgroundColor = Colors.red.withOpacity(0.12);
      textColor = Colors.red[700]!;
      displayText = 'Annulé';
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
