import 'dart:async';

import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/pause_state_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';

class InProgressRideBottomSheet extends StatefulWidget {
  final ClientData client;
  final Function() onCancelRide;
  final Function() onAddPenalty;
  final Function() onCallClients;
  final double price;
  final String? vehicleType;
  final double? currentLatitude;
  final double? currentLongitude;

  const InProgressRideBottomSheet({
    Key? key,
    required this.client,
    required this.onCancelRide,
    required this.onAddPenalty,
    required this.onCallClients,
    required this.price,
    this.vehicleType,
    this.currentLatitude,
    this.currentLongitude,
  }) : super(key: key);

  // Helper to check if this is a pickup course
  bool get isPickupCourse => client.isPickupCourse;

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
  bool _pauseRequested = false; // Track if pause request is pending customer approval
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

  void _showPauseDevelopmentMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('En cours de développement'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _togglePause() async {
    if (widget.client.courseId == null) return;

    final courseId = int.tryParse(widget.client.courseId!);
    if (courseId == null) return;

    // ⚡ Check if this is a pickup course
    final isPickup = widget.isPickupCourse;

    debugPrint('🔍🔍🔍 [PAUSE DEBUG] ========== PAUSE TOGGLE DEBUG ==========');
    debugPrint('🔍 [PAUSE DEBUG] Course ID: $courseId');
    debugPrint('🔍 [PAUSE DEBUG] widget.client.serviceId: ${widget.client.serviceId}');
    debugPrint('🔍 [PAUSE DEBUG] widget.client.isPickupCourse: ${widget.client.isPickupCourse}');
    debugPrint('🔍 [PAUSE DEBUG] widget.isPickupCourse: ${widget.isPickupCourse}');
    debugPrint('🔍 [PAUSE DEBUG] isPickup (local variable): $isPickup');
    debugPrint('🔍 [PAUSE DEBUG] Current pause state: ${_isPaused ? "PAUSED" : "NOT PAUSED"}');
    debugPrint('🔍🔍🔍 [PAUSE DEBUG] ================================================');

    try {
      if (_isPaused) {
        // Reprendre la course
        debugPrint('🟢 [PAUSE DEBUG] About to STOP pause');
        debugPrint('🟢 [PAUSE DEBUG] Will call: ${isPickup ? "stopPickupPause" : "stopPause"}');
        debugPrint('🟢 [PAUSE DEBUG] Expected endpoint: ${isPickup ? "/api/conducteur/course_pickup/$courseId/stop_pause" : "/api/conducteur/courses/$courseId/stop_pause"}');

        final pauseData = isPickup
            ? await _driverService.stopPickupPause(courseId)
            : await _driverService.stopPause(courseId);

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
        debugPrint('🔴 [PAUSE DEBUG] About to START pause');
        debugPrint('🔴 [PAUSE DEBUG] Will call: ${isPickup ? "startPickupPause" : "requestPause"}');
        debugPrint('🔴 [PAUSE DEBUG] Expected endpoint: ${isPickup ? "/api/conducteur/course_pickup/$courseId/start_pause" : "/api/conducteur/courses/$courseId/demande_pause"}');

        if (isPickup) {
          // For pickup courses, directly start the pause
          final response = await _driverService.startPickupPause(courseId);
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
        } else {
          // For standard courses, request pause from customer
          final response = await _driverService.requestPause(courseId);

          // Set pause requested flag (pause is not active yet, waiting for customer approval)
          _pauseRequested = true;

          if (mounted) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response['message'] ?? 'Demande de pause envoyée au client',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } on PauseAlreadyActiveException catch (e) {
      // Pause is already active on backend, sync local state
      debugPrint('⚠️ [PAUSE SYNC] Pause already active on backend, syncing local state...');
      debugPrint('⚠️ [PAUSE SYNC] Backend timestamp: ${e.timestamp}');
      debugPrint('⚠️ [PAUSE SYNC] Backend pause_start: ${e.pauseStart}');

      _pauseStartTimestamp = e.timestamp;
      _isPaused = true;
      _pauseTime = 0;
      await _pauseStateService.setPaused(courseId, true);
      await _pauseStateService.setPauseStartTimestamp(courseId, e.timestamp);
      _startPauseTimer();

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La pause était déjà active. État synchronisé.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [PAUSE ERROR] ${e.toString()}');
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: Text(
                  'Course reprise',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Subtitle
              if (amount == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Pause gratuite',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 16),

              // Content - Simple rows
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Duration row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Durée',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          duration,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        height: 0.5,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),

                    // Amount row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Montant',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          '$amount FCFA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: amount > 0 ? Colors.orange[700] : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Divider before button
              Container(
                height: 0.5,
                color: Colors.black.withOpacity(0.1),
              ),

              // Action button - iOS style
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Continuer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: kcPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
                          _isPaused
                            ? (widget.isPickupCourse ? 'Pickup en pause' : 'Course en pause')
                            : (widget.isPickupCourse ? 'Pickup en cours' : 'Course en cours'),
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

                  // Informations client (skip for pickup courses)
                  if (!widget.isPickupCourse)
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
                          // Bouton pause/reprendre (désactivé - en développement)
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _showPauseDevelopmentMessage,
                              icon: Icon(
                                Icons.pause,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Pause button for pickup courses
                  if (widget.isPickupCourse)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_taxi,
                            size: 36,
                            color: kcPrimaryColor,
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Text(
                              'Course Pickup',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Bouton pause/reprendre (désactivé - en développement)
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _showPauseDevelopmentMessage,
                              icon: Icon(
                                Icons.pause,
                                color: Colors.grey[600],
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
                'Course en pause',
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
                  isFree ? 'Gratuit' : '+${pausePrice.toStringAsFixed(0)} FCFA',
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
