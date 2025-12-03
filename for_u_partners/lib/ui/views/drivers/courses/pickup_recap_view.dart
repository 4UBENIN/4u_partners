import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/courses_viewmodel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PickupRecapView extends StatefulWidget {
  final int courseId;
  final VoidCallback onSoumettre;
  final CoursesViewModel viewModel;

  const PickupRecapView({
    Key? key,
    required this.courseId,
    required this.onSoumettre,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<PickupRecapView> createState() => _PickupRecapViewState();
}

class _PickupRecapViewState extends State<PickupRecapView> {
  final DriverService _driverService = locator<DriverService>();
  Future<Map<String, dynamic>>? _completionFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _completionFuture = _completePickupCourse();
      });
    });
  }

  Future<Map<String, dynamic>> _completePickupCourse() async {
    try {
      debugPrint('⚡ [PICKUP RECAP] Starting pickup course completion...');

      // Complete the pickup course and get the response data
      final responseData = await _driverService.completePickupCourse(widget.courseId);

      debugPrint('⚡ [PICKUP RECAP] Course completed successfully');
      debugPrint('⚡ [PICKUP RECAP] Response: $responseData');

      // Notify viewmodel to clean up state
      await widget.viewModel.onPickupCourseCompleted(widget.courseId);

      return responseData;
    } catch (e) {
      debugPrint('❌ [PICKUP RECAP] Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            widget.onSoumettre();
          },
        ),
        title: const Text(
          'Course Pickup Terminée',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _completionFuture,
        builder: (context, snapshot) {
          if (_completionFuture == null || snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.fourRotatingDots(
                    color: kcPrimaryColor,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Finalisation de la course pickup...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Erreur de finalisation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _completionFuture = _completePickupCourse();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Aucune donnée disponible',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!;

          return Column(
            children: [
              // Success header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kcPrimaryColor.withOpacity(0.1),
                      Colors.green[50]!,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Success icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_taxi, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            data['statut']?.toString().toUpperCase() ?? 'TERMINÉ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Message
                    Text(
                      data['message'] ?? 'Course terminée avec succès',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course ID Card
                      _buildInfoCard(
                        icon: Icons.confirmation_number_outlined,
                        iconColor: kcPrimaryColor,
                        title: 'ID de la course',
                        value: '#${data['course_id']}',
                      ),

                      const SizedBox(height: 16),

                      // Amount Card (if available)
                      if (data['montant'] != null && data['montant'] > 0)
                        _buildInfoCard(
                          icon: Icons.payments_outlined,
                          iconColor: Colors.green,
                          title: 'Montant',
                          value: '${data['montant']} FCFA',
                          subtitle: 'Mode: ${_getPaymentMethodLabel(data['payment_status'])}',
                        ),

                      if (data['montant'] != null && data['montant'] > 0)
                        const SizedBox(height: 16),

                      // Payment Status Card
                      _buildInfoCard(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: Colors.orange,
                        title: 'Statut du paiement',
                        value: _getPaymentStatusLabel(data['payment_status']),
                        subtitle: data['paiement_id'] != null
                          ? 'ID Paiement: #${data['paiement_id']}'
                          : null,
                      ),

                      const SizedBox(height: 16),

                      // Commission Card (if available)
                      if (data['commission_amount'] != null)
                        _buildInfoCard(
                          icon: Icons.percent_outlined,
                          iconColor: Colors.blue,
                          title: 'Commission',
                          value: '${data['commission_amount']} FCFA',
                          subtitle: 'Taux: ${data['commission_pct']}%',
                        ),

                      if (data['commission_amount'] != null)
                        const SizedBox(height: 16),

                      // Wallet Balance Card (if available)
                      if (data['driver_wallet_balance'] != null)
                        _buildInfoCard(
                          icon: Icons.account_balance,
                          iconColor: Colors.purple,
                          title: 'Solde du portefeuille',
                          value: '${data['driver_wallet_balance']} FCFA',
                          subtitle: 'Solde actuel après cette course',
                        ),

                      const SizedBox(height: 24),

                      // Pickup Badge
                      if (data['is_pickup_client'] == true)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: kcPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kcPrimaryColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.electric_bolt, color: kcPrimaryColor, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Course Pickup',
                                  style: TextStyle(
                                    color: kcPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: widget.onSoumettre,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kcPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Terminer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentStatusLabel(String? status) {
    switch (status) {
      case 'pending_cash':
        return 'En attente (Espèces)';
      case 'completed':
        return 'Complété';
      case 'pending':
        return 'En attente';
      default:
        return status ?? 'Inconnu';
    }
  }

  String _getPaymentMethodLabel(String? status) {
    if (status?.contains('cash') == true) {
      return 'Espèces';
    }
    return 'Autre';
  }
}
