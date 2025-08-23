import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'activitydetails_viewmodel.dart';
import 'package:for_u_partners/ui/views/drivers/activity/models/activity_model.dart';

class ActivitydetailsView extends StackedView<ActivitydetailsViewModel> {
  final ActivityModel? activity;

  const ActivitydetailsView({
    Key? key,
    this.activity,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ActivitydetailsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      // backgroundColor: Colors.whi,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          //gradient: LinearGradient(
          //  begin: Alignment.topLeft,
          //  end: Alignment.bottomRight,
          //  colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          //),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildRideDetailsCard(),
                    const SizedBox(height: 20),
                    _buildClientInfoCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF184E9C),
        boxShadow: [
          BoxShadow(
            color: Color(0x33184E9C),
            offset: Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Retour',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Course ${activity!.type.split(' ').length > 1 ? activity!.type.split(' ')[1] : activity!.type}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activity!.route,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    activity!.earning,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(activity!.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(activity!.status),
                          color: _getStatusColor(activity!.status),
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusText(activity!.status),
                          style: TextStyle(
                            color: _getStatusColor(activity!.status),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF184E9C),
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Détails de la course',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildInfoItem(
                icon: Icons.local_offer_outlined,
                label: 'Type',
                value: activity!.type.split(' ').length > 1
                    ? activity!.type.split(' ')[1]
                    : activity!.type,
              ),
              _buildInfoItem(
                icon: Icons.route_outlined,
                label: 'Distance',
                value: activity!.distance,
              ),
              if (activity!.totalTime != null)
                _buildInfoItem(
                  icon: Icons.access_time,
                  label: 'Durée',
                  value: activity!.totalTime!,
                ),
              if (activity!.tarifkm != null)
                _buildInfoItem(
                  icon: Icons.monetization_on_outlined,
                  label: 'Tarif/km',
                  value: '${activity!.tarifkm!} CFA',
                ),
              if (activity!.modePaiement != null &&
                  activity!.modePaiement!.isNotEmpty)
                _buildInfoItem(
                  icon: _getPaymentMethodIcon(activity!.modePaiement!),
                  label: 'Paiement',
                  value: _formatPaymentMethod(activity!.modePaiement!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF184E9C),
            size: 20,
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfoCard() {
    // Récupération du nom du client depuis les données de l'activité
    final clientName = activity?.client?['nom'] != null && activity?.client?['prenom'] != null
        ? '${activity!.client!['prenom']} ${activity!.client!['nom']}'
        : 'Client inconnu';
    
    // Première lettre pour l'avatar
    final avatarLetter = clientName.isNotEmpty ? clientName[0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Color(0xFF184E9C),
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Informations client',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF184E9C),
                  child: Text(
                    avatarLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  clientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return const Color(0xFF10B981); // Green
      case ActivityStatus.cancelled:
        return const Color(0xFFEF4444); // Red
      case ActivityStatus.inprogress:
        return const Color(0xFFF59E0B); // Amber
      case ActivityStatus.pending:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  IconData _getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return Icons.check_circle;
      case ActivityStatus.cancelled:
        return Icons.cancel;
      case ActivityStatus.inprogress:
        return Icons.access_time;
      case ActivityStatus.pending:
        return Icons.pending;
    }
  }

  String _getStatusText(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return 'Terminée';
      case ActivityStatus.cancelled:
        return 'Annulée';
      case ActivityStatus.inprogress:
        return 'En cours';
      case ActivityStatus.pending:
        return 'En attente';
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'espece':
      case 'espèces':
        return Icons.money;
      case 'carte':
      case 'carte bancaire':
        return Icons.credit_card;
      case 'mobile money':
      case 'mobile':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'espece':
        return 'Espèces';
      case 'carte':
        return 'Carte bancaire';
      case 'mobile_money':
        return 'Mobile Money';
      default:
        // Mettre en majuscule la première lettre
        return method[0].toUpperCase() + method.substring(1).toLowerCase();
    }
  }

  @override
  ActivitydetailsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ActivitydetailsViewModel();
}
