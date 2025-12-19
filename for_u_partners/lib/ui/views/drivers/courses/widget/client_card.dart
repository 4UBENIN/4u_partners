import 'dart:async';

import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientCard extends StatefulWidget {
  final ClientData client;
  final Function() onAccept;
  final Function() onDecline;

  const ClientCard(
      {Key? key,
        required this.client,
        required this.onAccept,
        required this.onDecline})
      : super(key: key);

  @override
  State<ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<ClientCard> {
  Timer? _countdownTimer;
  int _remainingSeconds = 20;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        setState(() {
          _remainingSeconds = 0;
          _isExpired = true;
        });
        timer.cancel();

        // Auto-decline when timer expires after a short delay to show expired state
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.onDecline();
          }
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _remainingSeconds <= 5 && !_isExpired;

    String getSimplifiedLocation(String? address) {
      if (address == null || address.isEmpty) return 'Non spécifié';
      // Split by comma and take first 2 parts (usually area/neighborhood)
      final parts = address.split(',');
      return parts.take(2).join(',').trim();
    }

    return Opacity(
      opacity: _isExpired ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isExpired
              ? Colors.grey[300]
              : (isUrgent ? Colors.red[50] : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: _isExpired
              ? Border.all(color: Colors.grey[400]!, width: 2)
              : (isUrgent
                  ? Border.all(color: Colors.red[300]!, width: 2)
                  : Border.all(color: Colors.grey[200]!, width: 1)),
          boxShadow: _isExpired
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Category badge and action buttons
            Row(
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.client.timeInfo.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                // Bouton X (refuser)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isExpired ? Colors.grey[300] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isExpired ? null : widget.onDecline,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: _isExpired ? Colors.grey[500] : Colors.grey[700],
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton Check (accepter)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isExpired ? Colors.grey[400] : kcPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isExpired ? null : widget.onAccept,
                    icon: Icon(
                      _isExpired ? Icons.block : Icons.check_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price - Big, bold, black
            Center(
              child: Text(
                widget.client.formattedPrice,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Simplified pickup and dropoff locations
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 50,
                      color: Colors.grey[300],
                    ),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getSimplifiedLocation(widget.client.adresseDepart),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        getSimplifiedLocation(widget.client.destination),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Timer display
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isExpired
                    ? Colors.grey[400]
                    : (isUrgent ? Colors.red[100] : Colors.orange[100]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isExpired ? Icons.timer_off : Icons.timer,
                    size: 18,
                    color: _isExpired
                        ? Colors.grey[700]
                        : (isUrgent ? Colors.red[700] : Colors.orange[700]),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isExpired
                        ? 'Offre expirée'
                        : 'Accepter dans $_remainingSeconds secondes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isExpired
                          ? Colors.grey[800]
                          : (isUrgent ? Colors.red[900] : Colors.orange[900]),
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
}
