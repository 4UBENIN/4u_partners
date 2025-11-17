import 'dart:async';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/arrival_state_service.dart';
import 'package:for_u_partners/services/pause_state_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';
import 'package:for_u_partners/ui/views/drivers/courses/widget/dialog_widget.dart';
import 'package:slide_to_act/slide_to_act.dart';

class ClientsBottomSheet extends StatelessWidget {
  final List<ClientData> getClientsList;
  final Function() onAccept;
  final Function() onDecline;
  const ClientsBottomSheet(
      {Key? key,
        required this.getClientsList,
        required this.onAccept,
        required this.onDecline})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
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
          child: Column(
            children: [
              // Poignée de glissement
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Liste des clients
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: getClientsList.length,
                  itemBuilder: (context, index) {
                    final client = getClientsList[index];
                    return ClientCard(
                        client: client,
                        onAccept: () {
                          print("ff");
                          showClientPickupDialog(
                            context: context,
                            clientName: client.name,
                            onAccept: onAccept,
                            onDecline: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                        onDecline: onDecline);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
  int _remainingSeconds = 15;
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

class AcceptedClientBottomSheet extends StatefulWidget {
  final ClientData client;
  final String? clientId;
  final int courseId;
  final Function() onCancelRide;
  final Function() onStartRide;
  final Function() onCallClients;
  final Function() onChatClients;
  final String? vehicleType;

  const AcceptedClientBottomSheet({
    Key? key,
    required this.client,
    required this.onCancelRide,
    required this.onStartRide,
    required this.onCallClients,
    required this.onChatClients,
    this.clientId,
    required this.courseId,
    this.vehicleType,
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
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.6,
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
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),

                  // Titre
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
                                onPressed: widget.onCallClients,
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

                  // Bouton Annuler
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 50,
                  //   child: _buildCancelButton(),
                  // ),
                ],
              ),
            ),
          ),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFree
            ? [Colors.green[50]!, Colors.green[100]!]
            : [Colors.orange[50]!, Colors.orange[100]!],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFree ? Colors.green[300]! : Colors.orange[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFree ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFree ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isFree ? Icons.timer_outlined : Icons.schedule_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Temps d\'attente',
                style: TextStyle(
                  fontSize: 18,
                  color: isFree ? Colors.green[900] : Colors.orange[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeSegment(hours, 'H'),
                _buildTimeSeparator(),
                _buildTimeSegment(minutes, 'MIN'),
                _buildTimeSeparator(),
                _buildTimeSegment(seconds, 'SEC'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isFree ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isFree ? Icons.check_circle : Icons.payments_rounded,
                    color: isFree ? Colors.green[700] : Colors.orange[700],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isFree ? 'Attente gratuite' : 'Frais d\'attente',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFree
                      ? '5 min gratuites'
                      : '+${waitingPrice.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isFree ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSegment(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kcPrimaryColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: kcPrimaryColor.withOpacity(0.6),
        ),
      ),
    );
  }
}

class InProgressRideBottomSheet extends StatefulWidget {
  final ClientData client;
  final Function() onCancelRide;
  final Function() onAddPenalty;
  final Function() onCallClients;
  final double price;
  final String? vehicleType;

  const InProgressRideBottomSheet({
    Key? key,
    required this.client,
    required this.onCancelRide,
    required this.onAddPenalty,
    required this.onCallClients,
    required this.price,
    this.vehicleType,
  }) : super(key: key);

  @override
  State<InProgressRideBottomSheet> createState() =>
      _InProgressRideBottomSheetState();
}

class _InProgressRideBottomSheetState extends State<InProgressRideBottomSheet>
    with TickerProviderStateMixin {
  final _pauseStateService = locator<PauseStateService>();
  final _driverService = locator<DriverService>();

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  Timer? _pauseTimer;
  bool _isPaused = false;
  int _pauseTime = 0;
  int? _pauseStartTimestamp;

  int _countdown = 300; // 5 minutes en secondes
  int? _waitingTime; // Track waiting time in seconds

  @override
  void initState() {
    super.initState();
    _loadPauseState();

    // Animation pour le pouls du prix
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animation pour la barre de progression
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Démarrer les animations en boucle
    _pulseController.repeat(reverse: true);
    _progressController.repeat();
  }

  Future<void> _loadPauseState() async {
    if (widget.client.courseId == null) return;

    final courseId = int.tryParse(widget.client.courseId!);
    if (courseId == null) return;

    _isPaused = await _pauseStateService.isPaused(courseId);
    _pauseStartTimestamp = await _pauseStateService.getPauseStartTimestamp(courseId);

    if (mounted) {
      setState(() {});
      if (_isPaused && _pauseStartTimestamp != null) {
        _startPauseTimer();
      }
    }
  }

  void _startPauseTimer() {
    _pauseTimer?.cancel();

    _pauseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (widget.client.courseId != null) {
          final courseId = int.tryParse(widget.client.courseId!);
          if (courseId != null) {
            _pauseTime = _pauseStateService.getPauseElapsedTime(courseId);
          }
        }
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _togglePause() async {
    if (widget.client.courseId == null) return;

    final courseId = int.tryParse(widget.client.courseId!);
    if (courseId == null) return;

    try {
      if (_isPaused) {
        // Reprendre la course
        final pauseData = await _driverService.stopPause(courseId);
        _pauseTimer?.cancel();
        _isPaused = false;
        await _pauseStateService.setPaused(courseId, false);
        await _pauseStateService.clearPauseState(courseId);
        _pauseStartTimestamp = null;
        _pauseTime = 0;

        if (mounted) {
          setState(() {});

          // Show pause summary
          final pauseSeconds = pauseData['pause_seconds'] as int;
          final montantPause = pauseData['montant_pause'] as int;

          final minutes = (pauseSeconds / 60).floor();
          final seconds = pauseSeconds % 60;

          _showPauseSummaryDialog(
            duration: '$minutes min ${seconds}s',
            amount: montantPause,
          );
        }
      } else {
        // Mettre en pause
        final response = await _driverService.startPause(courseId);
        final timestamp = response['timestamp'] as int;

        _pauseStartTimestamp = timestamp;
        _isPaused = true;
        _pauseTime = 0;
        await _pauseStateService.setPaused(courseId, true);
        await _pauseStateService.setPauseStartTimestamp(courseId, timestamp);
        _startPauseTimer();

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  void _showPauseSummaryDialog({
    required String duration,
    required int amount,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Course reprise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé de la pause',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Durée de la pause',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        duration,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payments, size: 20, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Frais de pause',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        '$amount FCFA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: amount > 0 ? Colors.orange[700] : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (amount == 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Pause gratuite (moins de 5 minutes)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                          fontStyle: FontStyle.italic,
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
              backgroundColor: kcPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  double _calculatePausePrice() {
    // First 5 minutes are free
    if (_pauseTime <= 300) return 0.0;

    // Calculate billable minutes (after first 5 minutes)
    final int totalMinutes = (_pauseTime / 60).ceil();
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

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
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
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),

                  // Titre avec indicateur en cours
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Text(
                          _isPaused ? 'Course en pause' : 'Course en cours',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isPaused ? Colors.orange : Colors.black87,
                          ),
                        ),
                      ],
                    ),
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
                        // Bouton pause/reprendre
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _isPaused ? Colors.green : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _togglePause,
                            icon: Icon(
                              _isPaused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
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

                  const SizedBox(height: 20),

                  // Pause Timer Widget
                  if (_isPaused)
                    _buildPauseTimer(),

                  if (_isPaused)
                    const SizedBox(height: 20),

                  // OPTION 1: Container avec bordure animée et prix qui pulse
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 60,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: _pulseAnimation.value * 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Course en cours',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${widget.price.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // OPTION 2: Barre de progression animée
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  kcPrimaryColor,
                                  Colors.green,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Warning message when paused
                  if (_isPaused)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange[200]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange[700],
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Reprenez la course avant de la terminer',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Bouton Terminer avec effet de chargement
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isPaused ? null : widget.onCancelRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPaused ? Colors.grey[400] : kcPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: _isPaused ? 0 : 2,
                        disabledBackgroundColor: Colors.grey[400],
                        disabledForegroundColor: Colors.grey[600],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isPaused) ...[
                            Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                          ] else
                            AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _progressController.value * 2 * 3.14159,
                                  child: const Icon(
                                    Icons.check_circle_outline,
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                          if (!_isPaused)
                            const SizedBox(width: 8),
                          Text(
                            _isPaused
                                ? 'Course en pause'
                                : 'Terminer la course',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isPaused ? Colors.grey[600] : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Bouton pénalité
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPauseTimer() {
    final pauseTime = _pauseTime;
    final hours = (pauseTime ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((pauseTime % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (pauseTime % 60).toString().padLeft(2, '0');
    final pausePrice = _calculatePausePrice();
    final isFree = pauseTime <= 300;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFree
            ? [Colors.green[50]!, Colors.green[100]!]
            : [Colors.orange[50]!, Colors.orange[100]!],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFree ? Colors.green[300]! : Colors.orange[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFree ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFree ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isFree ? Icons.timer_outlined : Icons.pause_circle_filled,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Temps de pause',
                style: TextStyle(
                  fontSize: 18,
                  color: isFree ? Colors.green[900] : Colors.orange[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeSegment(hours, 'H'),
                _buildTimeSeparator(),
                _buildTimeSegment(minutes, 'MIN'),
                _buildTimeSeparator(),
                _buildTimeSegment(seconds, 'SEC'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isFree ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isFree ? Icons.check_circle : Icons.payments_rounded,
                    color: isFree ? Colors.green[700] : Colors.orange[700],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isFree ? 'Pause gratuite' : 'Frais de pause',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFree
                      ? '5 min gratuites'
                      : '+${pausePrice.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isFree ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerWidget() {
    // Utiliser 0 comme valeur par défaut si _waitingTime est null
    final waitingTime = _waitingTime ?? 0;
    final hours = (waitingTime ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((waitingTime % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (waitingTime % 60).toString().padLeft(2, '0');

    // Calcul du prix d'attente (exemple: 50 FCFA par minute après les 2 premières minutes gratuites)
    final double waitingPrice = _calculateWaitingPrice();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header avec icône et titre
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kcPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: kcPrimaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Temps d\'attente',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Timer principal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: kcPrimaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kcPrimaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeSegment(hours, 'H'),
                _buildTimeSeparator(),
                _buildTimeSegment(minutes, 'MIN'),
                _buildTimeSeparator(),
                _buildTimeSegment(seconds, 'SEC'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section prix d'attente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: waitingPrice > 0
                    ? [Colors.orange[100]!, Colors.orange[50]!]
                    : [Colors.green[100]!, Colors.green[50]!],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                waitingPrice > 0 ? Colors.orange[200]! : Colors.green[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: waitingPrice > 0 ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    waitingPrice > 0
                        ? Icons.payments_rounded
                        : Icons.timer_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        waitingPrice > 0
                            ? 'Frais d\'attente'
                            : 'Attente gratuite',
                        style: TextStyle(
                          fontSize: 14,
                          color: waitingPrice > 0
                              ? Colors.orange[700]
                              : Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        waitingPrice > 0
                            ? 'Facturation après 2 min'
                            : '2 minutes gratuites',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: waitingPrice > 0 ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    waitingPrice > 0
                        ? '+${waitingPrice.toStringAsFixed(0)} FCFA'
                        : '0 FCFA',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: (_waitingTime ?? 0) > 120
                      ? Colors.orange
                      : kcPrimaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ((_waitingTime ?? 0) > 120
                          ? Colors.orange
                          : kcPrimaryColor)
                          .withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                (_waitingTime ?? 0) <= 120
                    ? 'En attente du client...'
                    : 'Facturation en cours',
                style: TextStyle(
                  color: (_waitingTime ?? 0) > 120
                      ? Colors.orange[700]
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSegment(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kcPrimaryColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kcPrimaryColor,
              fontFeatures: [FontFeature.tabularFigures()],
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: kcPrimaryColor.withOpacity(0.6),
          height: 1.0,
        ),
      ),
    );
  }

// Méthode pour calculer le prix d'attente
  double _calculateWaitingPrice() {
    // Return 0 if waiting time is not set
    if (_waitingTime == null) return 0.0;

    // Facturation dès la première minute à 50 FCFA par minute
    final int billableMinutes = (_waitingTime! / 60).ceil();
    return billableMinutes * 50.0;
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () => _showCancelDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[50],
        foregroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
      ),
      child: const Text(
        'Annuler la course',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Annuler la course'),
          content:
          const Text('Êtes-vous sûr de vouloir annuler cette course ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCancelRide();
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );
  }
}