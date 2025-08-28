import 'package:for_u_partners/app/models/ramasseur_models/ramasseur_demand_model.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'activities_delivery_viewmodel.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/views/delivery/activities_delivery/delivery_activity_details.dart';
import 'package:for_u_partners/ui/views/delivery/activities_delivery/models/delivery_activity_model.dart';

class ActivitiesDeliveryView extends StackedView<ActivitiesDeliveryViewModel> {
  const ActivitiesDeliveryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ActivitiesDeliveryViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text(
          'Activités',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF184E9C),
          ),
        ),
        centerTitle: false,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: Column(
          children: [
            Expanded(
              child: _buildActivitiesList(viewModel.activities, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesList(
      List<Demandes> activities, ActivitiesDeliveryViewModel viewModel) {
    if (activities.isEmpty) {
      return _buildNoActivities();
    }

    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildActivityItem(
            activities[index],
            Duration(
              milliseconds: (index + 1) * 100,
            ),
            context,
            viewModel,
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(
    Demandes activity,
    Duration animationDelay,
    BuildContext context,
    ActivitiesDeliveryViewModel viewModel,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 10),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
          onTap: () {},
          // => _onActivityTap(activity),
          child: _buildModernDemandeCard(activity, viewModel, context)),
    );
  }

  Widget _buildModernDemandeCard(Demandes demande,
      ActivitiesDeliveryViewModel viewModel, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec numéro et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              viewModel.getDemandeStatusColor(demande.statut),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Demande N° ${demande.numero ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1D29),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: viewModel
                        .getDemandeStatusColor(demande.statut)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: viewModel
                          .getDemandeStatusColor(demande.statut)
                          .withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    viewModel.getDemandeStatusText(demande.statut),
                    style: TextStyle(
                      color: viewModel.getDemandeStatusColor(demande.statut),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Adresses avec design amélioré
            _buildModernAddressRow(
              icon: Icons.my_location,
              label: 'Point de ramassage',
              address: demande.adresseRamassage ?? 'Adresse non spécifiée',
              color: const Color(0xFF059669),
            ),

            const SizedBox(height: 12),

            _buildModernAddressRow(
              icon: Icons.location_on,
              label: 'Destination',
              address: demande.adresseLivraison ?? 'Adresse non spécifiée',
              color: primaryColor,
            ),

            const SizedBox(height: 16),

            // Date avec icône
            if (demande.dateDemande != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Demandé le ${viewModel.formatDateTime(demande.dateDemande!)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAddressRow({
    required IconData icon,
    required String label,
    required String address,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1D29),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ActivityStatus status) {
    Color color;
    String text;

    switch (status) {
      case ActivityStatus.completed:
        color = const Color(0xFF059669);
        text = 'Terminée';
        break;
      case ActivityStatus.cancelled:
        color = const Color(0xFFDC2626);
        text = 'Annulée';
        break;
      case ActivityStatus.inprogress:
        color = Colors.orange;
        text = 'En cours';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNoActivities() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune activité',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D29),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Vos activités apparaîtront ici',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onActivityTap(DeliveryActivityModel activity) {
    final navigationService = locator<NavigationService>();
    print('Clic sur: ${activity.type} - ${activity.route}');
    navigationService
        .navigateToView(DeliveryActivityDetails(activity: activity));
  }

  @override
  ActivitiesDeliveryViewModel viewModelBuilder(BuildContext context) =>
      ActivitiesDeliveryViewModel();
}
