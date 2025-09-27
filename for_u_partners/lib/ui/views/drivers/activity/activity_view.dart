import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'activity_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/views/drivers/activity/models/activity_model.dart';
import 'package:for_u_partners/ui/views/drivers/activitydetails/activitydetails_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ActivityView extends StackedView<ActivityViewModel> {
  const ActivityView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ActivityViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
        child: _buildBody(viewModel),
      ),
    );
  }

  Widget _buildBody(ActivityViewModel viewModel) {
    if (viewModel.isLoading && viewModel.activities.isEmpty) {
      return Center(
          child: LoadingAnimationWidget.fourRotatingDots(
              color: kcPrimaryColor, size: 50));
    }
    if (viewModel.errorMessage != null) {
      return Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône avec animation subtile
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF184E9C).withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF184E9C).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF184E9C),
                    size: 56,
                  ),
                ),

                const SizedBox(height: 32),

                // Titre principal
                const Text(
                  'Compte en cours de validation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF184E9C),
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                // Message descriptif
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Votre demande d\'inscription a été reçue avec succès !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Notre équipe examine actuellement votre dossier. Vous recevrez une notification par email dès que votre compte sera activé.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Indicateur de progression
                Column(
                  children: [
                    Text(
                      'Temps de traitement habituel',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF184E9C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '24-48 heures',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF184E9C),
                          fontWeight: FontWeight.w600,
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

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: const WaterDropHeader(
        waterDropColor: Color(0xFF184E9C),
        complete: Text('Rafraîchissement terminé'),
      ),
      onRefresh: viewModel.refreshActivities,
      controller: RefreshController(),
      child: _buildActivitiesList(viewModel.activities),
    );
  }

  Widget _buildActivitiesList(List<ActivityModel> activities) {
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
            Duration(milliseconds: (index + 1) * 100),
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(ActivityModel activity, Duration animationDelay) {
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
        onTap: () => _onActivityTap(activity),
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
            border: Border(
              left: BorderSide(
                color: _getStatusColor(activity.status),
                width: 3,
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Course #${activity.numero}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      _buildStatusBadge(activity.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF184E9C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.adresseDepart,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(left: 2, right: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE11D48),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 0),
                      Expanded(
                        child: Text(
                          activity.adresseArrivee,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activity.timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          activity.distance,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      Text(
                        activity.earning,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF184E9C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return const Color(0xFF059669);
      case ActivityStatus.cancelled:
        return const Color(0xFFDC2626);
      case ActivityStatus.inprogress:
        return Colors.orange;
      case ActivityStatus.pending:
        return Colors.blue;
    }
  }

  Widget _buildStatusBadge(ActivityStatus status) {
    Color color = _getStatusColor(status);
    String text;

    switch (status) {
      case ActivityStatus.completed:
        text = 'Terminée';
        break;
      case ActivityStatus.cancelled:
        text = 'Annulée';
        break;
      case ActivityStatus.inprogress:
        text = 'En cours';
        break;
      case ActivityStatus.pending:
        text = 'En attente';
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
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aucune activité',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Vos courses apparaîtront ici',
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

  void _onActivityTap(ActivityModel activity) {
    final navigationService = locator<NavigationService>();
    navigationService.navigateToView(ActivitydetailsView(activity: activity));
  }

  @override
  ActivityViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ActivityViewModel();
}
