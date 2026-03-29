

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/driver_service.dart';

import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/countdown_toast.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';
import 'package:for_u_partners/ui/views/drivers/courses/widget/dialog_widget.dart';

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
              // Titre
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Clients disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
                      onDecline: onDecline,
                    );
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


class ClientCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar avec initiales
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                client.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Informations client
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.timeInfo,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    client.destination,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Boutons d'action
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouton X (refuser)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: IconButton(
                  onPressed: onDecline,
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 8),
              // Bouton Check (accepter)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: kcPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onAccept,
                  icon: const Icon(
                    Icons.check,
                    size: 18,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
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
  final Function() onWhatsAppClients;
  final Function() onChatClients;

  const AcceptedClientBottomSheet({
    Key? key,
    required this.client,
    required this.onCancelRide,
    required this.onStartRide,
    required this.onCallClients,
    required this.onWhatsAppClients,
    required this.onChatClients,
    this.clientId,
    required this.courseId,
  }) : super(key: key);

  @override
  State<AcceptedClientBottomSheet> createState() =>
      _AcceptedClientBottomSheetState();
}

class _AcceptedClientBottomSheetState extends State<AcceptedClientBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _clientPickedUp = false;
  late AnimationController _controller;
  final DriverService _driverService = locator<DriverService>();

  // Timer pour le comptage du temps d'attente
  Timer? _countUpTimer;
  int _currentCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _startCountUp() {
    if (mounted) {
      setState(() {
        _clientPickedUp = true;
      });

      // Afficher le toast de comptage ascendant
      CountdownToast.show(
        context: context,
        initialSeconds: 0, // Commence à 0
        message: 'Temps d\'attente',
        countUp: true, // Mode comptage ascendant
        //maxSeconds: 300, // 5 minutes maximum
      );

      // Démarrer le comptage
      _countUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (mounted) {
          setState(() {
            if (_currentCount < 300) {
              // 5 minutes = 300 secondes
              _currentCount++;
            } else {
              _stopCountUp();
            }
          });
        }
      });
    }
  }

  void _stopCountUp() {
    _countUpTimer?.cancel();
  }

  void _startRide() {
    _stopCountUp(); // Arrêter le minuteur
    // Cacher le toast
    CountdownToast.hide();
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    widget.onStartRide();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.44,  // Augmenté pour afficher plus de contenu
      minChildSize: 0.25,
      //expand: false,
      maxChildSize: 0.8,  // Augmenté pour permettre un meilleur défilement
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
                        // Boutons d'action: Chat, WhatsApp, Téléphone
                        Row(
                          children: [
                            // Bouton Chat
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
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Bouton WhatsApp
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color:
                                    Color(0xFF25D366), // Couleur WhatsApp
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: widget.onWhatsAppClients,
                                icon: const Icon(
                                  FontAwesomeIcons.whatsapp,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Bouton Téléphone
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
                                  Icons.call,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
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

                  // Bouton de confirmation (visible seulement si le client n'est pas encore récupéré)
                  if (!_clientPickedUp)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!mounted) return;

                                try {
                                  await _driverService
                                      .notifyClient(widget.courseId);

                                  if (mounted) {
                                    // Afficher la confirmation
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Vous avez confirmé votre arrivée au client.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    // Démarrer le minuteur de comptage
                                    _startCountUp();
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Erreur de réseau. Veuillez réessayer."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kcPrimaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Confirmer mon arrivée',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Bouton Démarrer la course (visible seulement après confirmation)
                  if (_clientPickedUp)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _startRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kcPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Démarrer la course',
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
    );
  }

  @override
  void dispose() {
    print(
        '🛑 _AcceptedClientBottomSheetState dispose() appelé - nettoyage en cours');
    _countUpTimer?.cancel();
    // Fermer le toast et la SnackBar si affichés
    CountdownToast.hide();
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    _controller.dispose();
    super.dispose();
    print('✅ _AcceptedClientBottomSheetState dispose() terminé');
  }
}


class InProgressRideBottomSheet extends StatefulWidget {
  final ClientData client;
  final Function() onAddPenalty;
  final double price;
  final Function()? onFinishRide;

  const InProgressRideBottomSheet({
    Key? key,
    required this.client,
    required this.onAddPenalty,
    required this.price,
    this.onFinishRide,
  }) : super(key: key);

  @override
  State<InProgressRideBottomSheet> createState() =>
      _InProgressRideBottomSheetState();
}

class _InProgressRideBottomSheetState extends State<InProgressRideBottomSheet>
    with SingleTickerProviderStateMixin {
  final DriverService _driverService = locator<DriverService>();
  bool _isRequestingPause = false;
  bool _isPaused = false; // État pour savoir si la pause est active
  Timer? _pauseTimer; // Minuteur pour la pause
  int _pauseSeconds = 0; // Compteur de secondes de pause
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Widget _buildPauseTimer() {
    if (!_isPaused) return const SizedBox.shrink();

    final minutes = (_pauseSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_pauseSeconds % 60).toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: Colors.orange[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Pause en cours : $minutes:$seconds',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Poignée de glissement
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Indicateur de statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isPaused ? Colors.orange : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isPaused ? 'Pause en cours' : 'Course en cours',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  
                  // Affichage du minuteur de pause
                  _buildPauseTimer(),
                  
                  const SizedBox(height: 24),
                  
                  // Barre de progression animée
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _animationController.value,
                          backgroundColor: Colors.grey[100],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            kcPrimaryColor,
                          ),
                          minHeight: 8,
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Carte client
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kcPrimaryColor,
                                kcPrimaryColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: kcPrimaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.client.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Détails du client
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
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.place_rounded,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.client.destination,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bouton Demander une pause
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isPaused ? _endPause : _requestPause,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kcPrimaryColor,
                        side: const BorderSide(color: kcPrimaryColor, width: 1.5),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isPaused ? Icons.play_circle_outline : Icons.pause_circle_outline,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isPaused ? 'Terminer la pause' : 'Demander une pause',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bouton Terminer la course
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: widget.onFinishRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Terminer la course',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _requestPause() async {
    if (_isRequestingPause) return;

    setState(() {
      _isRequestingPause = true;
    });

    try {
      final result = await _driverService.requestPause(int.parse(widget.client.courseId.toString()));
      //await _driverService.answerPause(int.parse(widget.client.courseId.toString()));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.green,
          ),
        );

        // Démarrer la pause et le minuteur
        _startPause();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la demande de pause: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPause = false;
        });
      }
    }
  }

  void _startPause() {
    setState(() {
      _isPaused = true;
      _pauseSeconds = 0; // Réinitialiser le compteur
    });

    // Le minuteur va tourner indéfiniment jusqu'à ce qu'on termine la pause
    _pauseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _pauseSeconds++;
        });
      }
    });
  }

  void _endPause() {
    _pauseTimer?.cancel();
    _pauseTimer = null;

    setState(() {
      _isPaused = false;
      _pauseSeconds = 0; // Réinitialiser le compteur
    });

    // Appeler le service pour terminer la pause
    _driverService.stopPause(int.parse(widget.client.courseId.toString()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pause terminée'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}