import 'dart:async';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/driver_service.dart';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
  final Function() onChatClients;

  const AcceptedClientBottomSheet({
    Key? key,
    required this.client,
    required this.onCancelRide,
    required this.onStartRide,
    required this.onCallClients,
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
  final bool _isLoading = false; // État du toggle switch
  bool _showTimer = false;
  bool _arrivalConfirmed =
      false; // Pour suivre si la confirmation d'arrivée a été faite
  late AnimationController _controller;
  int _countdown = 300; // 5 minutes en secondes
  Timer? _countdownTimer;
  Timer? _waitingTimer;
  int _waitingTime = 0; // Track waiting time in seconds

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _countdownTimer?.cancel();
    _waitingTimer?.cancel();
    super.dispose();
  }

  void _startWaitingTimer() {
    // Annuler le timer existant s'il y en a un
    _waitingTimer?.cancel();

    // Réinitialiser le temps d'attente
    setState(() {
      _waitingTime = 0;
    });

    // Démarrer un nouveau timer qui s'incrémente chaque seconde
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _waitingTime++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startCountdown() {
    setState(() {
      _showTimer = true;
      _controller.forward();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  Widget _buildTimerWidget() {
    // SUPPRIMER CES LIGNES - elles écrasent les variables de classe !
    // int _waitingTime = 0;
    // Timer? _waitingTimer;

    // Use 0 as default if _waitingTime is null
    final waitingTime = _waitingTime ?? 0;
    final hours = (waitingTime ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((waitingTime % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (waitingTime % 60).toString().padLeft(2, '0');

    // Calcul du prix d'attente
    final double waitingPrice = _calculateWaitingPrice();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding:
          const EdgeInsets.all(20), // Réduire le padding pour éviter l'overflow
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
              Flexible(
                // Utiliser Flexible pour éviter l'overflow
                child: Text(
                  'Temps d\'attente',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16), // Réduire l'espace

          // Timer principal
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12), // Réduire le padding
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
              mainAxisSize: MainAxisSize.min, // Ajouter pour éviter l'overflow
              children: [
                _buildTimeSegment(hours, 'H'),
                _buildTimeSeparator(),
                _buildTimeSegment(minutes, 'MIN'),
                _buildTimeSeparator(),
                _buildTimeSegment(seconds, 'SEC'),
              ],
            ),
          ),

          const SizedBox(height: 16), // Réduire l'espace

          // Section prix d'attente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14), // Réduire le padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange[100]!, Colors.orange[50]!],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.orange[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(8), // Réduire le padding de l'icône
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Colors.white,
                    size: 18, // Réduire la taille de l'icône
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frais d\'attente',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Facturation dès la première minute',
                        style: TextStyle(
                          fontSize:
                              11, // Réduire la taille pour éviter l'overflow
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6), // Réduire le padding
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${waitingPrice.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontSize: 14, // Réduire la taille de police
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12), // Réduire l'espace

          // Status indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6, // Réduire la taille
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                // Utiliser Flexible pour éviter l'overflow
                child: Text(
                  'Facturation en cours',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 13, // Réduire la taille de police
                  ),
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
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 6), // Réduire le padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
              fontSize: 24, // Réduire la taille de police
              fontWeight: FontWeight.bold,
              color: kcPrimaryColor,
              fontFeatures: [FontFeature.tabularFigures()],
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10, // Réduire la taille
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 6), // Réduire l'espacement
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 24, // Réduire la taille
          fontWeight: FontWeight.bold,
          color: kcPrimaryColor.withOpacity(0.6),
          height: 1.0,
        ),
      ),
    );
  }

// Méthode pour calculer le prix d'attente
  double _calculateWaitingPrice() {
    // Utiliser directement _waitingTime qui est déjà en secondes
    // Convertir en minutes (arrondi au supérieur)
    final int minutes = (_waitingTime / 60).ceil();

    // Calculer le prix (50 FCFA par minute)
    return minutes * 50.0;
  }

  // Widget _buildCancelButton() {
  //   return ElevatedButton(
  //     onPressed: () => _showCancelDialog(context),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.red[50],
  //       foregroundColor: Colors.red,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       padding: const EdgeInsets.symmetric(vertical: 16),
  //       elevation: 0,
  //     ),
  //     child: const Text(
  //       'Annuler la course',
  //       style: TextStyle(
  //         fontSize: 16,
  //         fontWeight: FontWeight.w600,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final driverservice = locator<DriverService>();

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

                  // Question avec Slider Button
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
                        child: _showTimer
                            ? _buildTimerWidget()
                            : SlideAction(
                                height: 60,
                                sliderButtonIcon: const Icon(
                                  Icons.double_arrow_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                sliderButtonYOffset: -1,
                                borderRadius: 30,
                                elevation: 0,
                                outerColor: Colors.grey[200]!,
                                innerColor: kcPrimaryColor,
                                text: 'Glissez pour confirmer votre arrivée',
                                textStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                                onSubmit: () async {
                                  // Éviter les déclenchements multiples
                                  if (_arrivalConfirmed) return;

                                  // Démarrer le minuteur d'attente
                                  _startWaitingTimer();

                                  // Démarrer le compte à rebours
                                  _startCountdown();

                                  // Ensuite gérer la notification
                                  try {
                                    await driverservice
                                        .notifyClient(widget.courseId);

                                    if (mounted) {
                                      setState(() {
                                        _clientPickedUp = true;
                                        _arrivalConfirmed = true; // Marquer comme confirmé
                                      });
                                    }
                                  } catch (e) {
                                    // En cas d'erreur, annuler les timers
                                    if (mounted) {
                                      setState(() {
                                        _showTimer = false;
                                      });
                                      _countdownTimer?.cancel();
                                      _waitingTimer?.cancel();
                                    }
                                    // Relancer le slider en cas d'erreur
                                    if (mounted) {
                                      setState(() {
                                        _arrivalConfirmed = false;
                                      });
                                    }
                                    rethrow;
                                  }
                                },
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bouton Démarrer la course (conditionnel)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _clientPickedUp ? widget.onStartRide : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _clientPickedUp ? kcPrimaryColor : Colors.grey[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: _clientPickedUp ? 2 : 0,
                        disabledBackgroundColor: Colors.grey[400],
                        disabledForegroundColor: Colors.grey[600],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_clientPickedUp) ...[
                            Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _clientPickedUp
                                ? 'Démarrer la course'
                                : 'Récupérez d\'abord le client',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _clientPickedUp
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
}

class InProgressRideBottomSheet extends StatefulWidget {
  final ClientData client;
  final Function() onCancelRide;
  final Function() onAddPenalty;
  final Function() onCallClients;
  final double price;

  const InProgressRideBottomSheet({
    Key? key,
    required this.client,
    required this.onCancelRide,
    required this.onAddPenalty,
    required this.onCallClients,
    required this.price,
  }) : super(key: key);

  @override
  State<InProgressRideBottomSheet> createState() =>
      _InProgressRideBottomSheetState();
}

class _InProgressRideBottomSheetState extends State<InProgressRideBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  int _countdown = 300; // 5 minutes en secondes
  int? _waitingTime; // Track waiting time in seconds

  @override
  void initState() {
    super.initState();

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

  @override
  void dispose() {
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
                        const Text(
                          'Course en cours',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                        // Bouton téléphone
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: kcPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: widget.onCallClients,
                            icon: const Icon(
                              Icons.pause,
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

                  // Bouton Terminer avec effet de chargement
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.onCancelRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          const SizedBox(width: 8),
                          const Text(
                            'Terminer la course',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
