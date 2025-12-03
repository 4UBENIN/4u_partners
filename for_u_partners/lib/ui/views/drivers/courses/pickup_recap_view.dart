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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: widget.onSoumettre,
        ),
        title: const Text(
          'Course Terminée',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
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
                    size: 50,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Finalisation en cours...',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Erreur',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _completionFuture = _completePickupCourse();
                        });
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Aucune donnée',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // Success icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: kcPrimaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 48,
                          color: kcPrimaryColor,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Course terminée',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Message
                      Text(
                        data['message'] ?? 'Paiement géré avec succès',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Details Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Course ID
                            _buildDetailRow(
                              'N° de course',
                              '#${data['course_id']}',
                              isFirst: true,
                            ),

                            // Amount
                            if (data['montant'] != null && data['montant'] > 0)
                              _buildDetailRow(
                                'Montant',
                                '${data['montant']} FCFA',
                              ),

                            // Payment Status
                            _buildDetailRow(
                              'Paiement',
                              _getPaymentStatusLabel(data['payment_status']),
                            ),

                            // Commission
                            if (data['commission_amount'] != null)
                              _buildDetailRow(
                                'Commission (${data['commission_pct']}%)',
                                '${data['commission_amount']} FCFA',
                              ),

                            // Wallet Balance
                            if (data['driver_wallet_balance'] != null)
                              _buildDetailRow(
                                'Solde portefeuille',
                                '${data['driver_wallet_balance']} FCFA',
                                isLast: true,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Pickup Badge
                      if (data['is_pickup_client'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kcPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.electric_bolt,
                                size: 16,
                                color: kcPrimaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Course Pickup',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: kcPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.onSoumettre,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Terminer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentStatusLabel(String? status) {
    switch (status) {
      case 'pending_cash':
        return 'Espèces';
      case 'completed':
        return 'Complété';
      case 'pending':
        return 'En attente';
      default:
        return status ?? 'Inconnu';
    }
  }
}
