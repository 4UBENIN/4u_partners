import 'package:flutter/material.dart';

/// Simplified waiting/pause timer widget
/// Shows elapsed time with billing information
class TimerBannerWidget extends StatelessWidget {
  final int elapsedSeconds;
  final bool isPause;
  final double Function(int) calculateBillingAmount;
  final String? title;

  const TimerBannerWidget({
    Key? key,
    required this.elapsedSeconds,
    required this.isPause,
    required this.calculateBillingAmount,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hours = (elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    final billingAmount = calculateBillingAmount(elapsedSeconds);
    final isFree = elapsedSeconds <= 300; // First 5 minutes are free
    final accentColor = isFree ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(
                isFree ? Icons.timer_outlined : Icons.pause_circle_filled,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title ?? (isPause ? 'Course en pause' : 'Temps d\'attente'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isFree ? 'Gratuit' : '+${billingAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Time Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$hours:$minutes:$seconds',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Info Text
          Text(
            isFree ? '5 minutes gratuites incluses' : 'Facturation après 5 min',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
