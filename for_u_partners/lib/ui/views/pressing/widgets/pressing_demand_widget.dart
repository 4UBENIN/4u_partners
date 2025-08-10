import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/ramassage_model.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/home_pressing_viewmodel.dart';
import 'package:stacked/stacked.dart';

class PressingDemandWidget extends ViewModelWidget<HomePressingViewModel> {
  final Ramassage ramassage;
  final VoidCallback? onTap;

  const PressingDemandWidget({
    super.key,
    required this.ramassage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, HomePressingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                              color: const Color(0xFF10b981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_shipping_outlined,
                              color: Color(0xFF10b981),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${ramassage.client?.prenom ?? ''} ${ramassage.client?.nom ?? ''}'
                                    .trim(),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1a1a1a),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                viewModel
                                    .changeFormatDate(ramassage.dateRamassage!),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8e8e93),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Services basés sur les données réelles
                  // if (ramassage.servicesComplementaires != null)
                  //   Wrap(
                  //     spacing: 8,
                  //     children: ramassage.servicesComplementaires!
                  //         .take(2)
                  //         .map((service) {
                  //       return Container(
                  //         padding: const EdgeInsets.symmetric(
                  //             horizontal: 8, vertical: 4),
                  //         decoration: BoxDecoration(
                  //           color: const Color(0xFFf1f3f4),
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //         child: Text(
                  //           service.libelle,
                  //           style: const TextStyle(
                  //             fontSize: 12,
                  //             color: Color(0xFF6b7280),
                  //           ),
                  //         ),
                  //       );
                  //     }).toList(),
                  //   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case "À facturer":
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      case "Terminé":
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        break;
      case "À finaliser":
        backgroundColor = const Color(0xFFDDD6FE);
        textColor = const Color(0xFF7C3AED);
        break;
      default: // "En attente"
        backgroundColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
