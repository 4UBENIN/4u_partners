import 'dart:async';

import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/arrival_state_service.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:url_launcher/url_launcher.dart';

class AcceptedClientBottomSheet extends StatefulWidget {
  final ClientData client;
  final String? clientId;
  final int courseId;
  final Function() onCancelRide;
  final Function() onStartRide;
  final Function() onCallClients;
  final Function() onChatClients;
  final Function()? onDenyRide;
  final String? vehicleType;
  final double? currentLatitude;
  final double? currentLongitude;

  const AcceptedClientBottomSheet({
    Key? key,
    required this.client,
    required this.onCancelRide,
    required this.onStartRide,
    required this.onCallClients,
    required this.onChatClients,
    this.onDenyRide,
    this.clientId,
    required this.courseId,
    this.vehicleType,
    this.currentLatitude,
    this.currentLongitude,
  }) : super(key: key);

  @override
  State<AcceptedClientBottomSheet> createState() =>
      _AcceptedClientBottomSheetState();
}

class _AcceptedClientBottomSheetState extends State<AcceptedClientBottomSheet> {
  final _arrivalStateService = locator<ArrivalStateService>();
  final GlobalKey<SlideActionState> _slideKey = GlobalKey();
  Timer? _waitingTimer;
  bool _arrivalConfirmed = false;
  int _waitingTime = 0;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    _arrivalConfirmed = await _arrivalStateService.isArrivalConfirmed(widget.courseId);
    _waitingTime = await _arrivalStateService.getWaitingTime(widget.courseId);

    if (mounted) {
      setState(() {});
      if (_arrivalConfirmed) {
        _startWaitingTimer();
      }
    }
  }

  @override
  void dispose() {
    _waitingTimer?.cancel();
    super.dispose();
  }

  void _startWaitingTimer() {
    _waitingTimer?.cancel();

    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _waitingTime++;
        _arrivalStateService.setWaitingTime(widget.courseId, _waitingTime);
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  double _calculateWaitingPrice() {
    // First 5 minutes are free
    if (_waitingTime <= 300) return 0.0;

    // Calculate billable minutes (after first 5 minutes)
    final int totalMinutes = (_waitingTime / 60).ceil();
    final int billableMinutes = totalMinutes - 5;

    // Get rate based on vehicle type
    final int ratePerMinute = _getRatePerMinute(widget.vehicleType);

    return billableMinutes * ratePerMinute.toDouble();
  }

  int _getRatePerMinute(String? vehicleType) {
    if (vehicleType == null) return 25; // Default to Voiture Std

    switch (vehicleType.toLowerCase()) {
      case 'moto':
        return 10;
      case 'tricycle':
        return 20;
      case 'voiture std':
      case 'voiture standard':
        return 25;
      case 'voiture premium':
        return 50;
      case 'voiture vip':
        return 80;
      default:
        return 25; // Default to Voiture Std
    }
  }

  Future<void> _confirmArrival() async {
    if (_arrivalConfirmed) return;

    final driverservice = locator<DriverService>();
    try {
      // Set state immediately to remove SlideAction before async completes
      if (mounted) {
        setState(() {
          _arrivalConfirmed = true;
          _waitingTime = 0;
        });
      }

      // Notify client of arrival (updates status to "chauffeur_arrive")
      await driverservice.notifyClient(widget.courseId);

      if (mounted) {
        await _arrivalStateService.setArrivalConfirmed(widget.courseId, true);
        await _arrivalStateService.setWaitingTime(widget.courseId, 0);
        _startWaitingTimer();
      }
    } catch (e) {
      // Revert state on error
      if (mounted) {
        setState(() {
          _arrivalConfirmed = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ [AcceptedClientBottomSheet] build() called for course ${widget.courseId}');
    print('🏗️ [AcceptedClientBottomSheet] client: ${widget.client.name}');
    print('🏗️ [AcceptedClientBottomSheet] _arrivalConfirmed: $_arrivalConfirmed');
    return GestureDetector(
      onTap: () {}, // Prevents taps on the sheet from closing it
      child: DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.25,
        maxChildSize: 0.6,
        snap: true,
        snapSizes: const [0.25, 0.45, 0.6],
        builder: (context, scrollController) {
        print('🏗️ [AcceptedClientBottomSheet] DraggableScrollableSheet builder called');
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poignée
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),

                  // Titre avec bouton de fermeture
                  Stack(
                    children: [
                      const Center(
                        child: Text(
                          'Course acceptée',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: -8,
                        child: IconButton(
                          onPressed: () {
                            // Minimize the sheet to its minimum size
                            // Note: This doesn't cancel the ride, just minimizes the UI
                          },
                          icon: const Icon(Icons.keyboard_arrow_down),
                          iconSize: 28,
                          color: Colors.grey[600],
                          tooltip: 'Réduire',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Informations client
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              widget.client.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.client.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.client.timeInfo,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bouton téléphone et chat
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: kcPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: widget.onChatClients,
                                icon: const Icon(
                                  Icons.message_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: kcPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  // Try to get phone number from client data
                                  final rawPhoneNumber = widget.client.phoneNumber;
                                  final phoneNumber = rawPhoneNumber?.trim();
                                  debugPrint('call_client: rawPhoneNumber=$rawPhoneNumber');
                                  if (phoneNumber != null && phoneNumber.isNotEmpty) {
                                    try {
                                      final Uri phoneUri = Uri.parse('tel:$phoneNumber');
                                      final canLaunch = await canLaunchUrl(phoneUri);
                                      debugPrint('call_client: canLaunchUrl=$canLaunch, uri=$phoneUri');
                                      if (canLaunch) {
                                        await launchUrl(phoneUri);
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Impossible d\'ouvrir l\'application téléphone'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      debugPrint('call_client: launch error: $e');
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Erreur: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    debugPrint('call_client: missing phone number');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Numéro de téléphone non disponible'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Destination
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.client.destination,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Arrival Confirmation Slider
                  if (!_arrivalConfirmed)
                    SlideAction(
                      key: _slideKey,
                      onSubmit: _confirmArrival,
                      height: 60,
                      borderRadius: 30,
                      elevation: 0,
                      innerColor: kcPrimaryColor,
                      outerColor: Colors.grey[200]!,
                      sliderButtonIcon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      text: 'Glisser pour confirmer mon arrivée',
                      textStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                  // Waiting Timer Widget
                  if (_arrivalConfirmed)
                    _buildWaitingTimer(),

                  const SizedBox(height: 20),

                  // Bouton Démarrer la course (conditionnel)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _arrivalConfirmed ? widget.onStartRide : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _arrivalConfirmed ? kcPrimaryColor : Colors.grey[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: _arrivalConfirmed ? 2 : 0,
                        disabledBackgroundColor: Colors.grey[400],
                        disabledForegroundColor: Colors.grey[600],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_arrivalConfirmed) ...[
                            Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _arrivalConfirmed
                                ? 'Démarrer la course'
                                : 'Récupérez d\'abord le client',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _arrivalConfirmed
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Bouton Refuser la course (seulement si pas encore arrivé)
                  if (widget.onDenyRide != null && !_arrivalConfirmed)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _showDenyDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 20),
                        label: const Text(
                          'Refuser la course',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      ),
    );
  }

  void _showDenyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Refuser la course',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Êtes-vous sûr de vouloir refuser la course avec ${widget.client.name} ?',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cette action est irréversible',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onDenyRide != null) {
                  widget.onDenyRide!();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Oui, refuser'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Annuler la course'),
          content: Text(
              'Êtes-vous sûr de vouloir annuler la course avec ${widget.client.name} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Non', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: widget.onCancelRide,
              child: const Text(
                'Oui, annuler',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWaitingTimer() {
    final waitingTime = _waitingTime;
    final hours = (waitingTime ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((waitingTime % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (waitingTime % 60).toString().padLeft(2, '0');
    final waitingPrice = _calculateWaitingPrice();
    final isFree = waitingTime <= 300;
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
                'Temps d\'attente',
                style: TextStyle(
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
                  isFree ? 'Gratuit' : '+${waitingPrice.toStringAsFixed(0)} FCFA',
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
