import 'dart:async';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/countdown_toast.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';

class _AcceptedClientBottomSheetState extends State<AcceptedClientBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _clientPickedUp = false;
  late AnimationController _controller;
  
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
  
  @override
  void dispose() {
    _countUpTimer?.cancel();
    // Fermer la SnackBar si elle est affichée
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    _controller.dispose();
    super.dispose();
  }

  void _startCountUp() {
    if (mounted) {
      setState(() {
        _clientPickedUp = true;
      });
      
      // Afficher le toast de décompte
      CountdownToast.show(
        context: context,
        initialSeconds: 0, // Commence à 0
        message: 'Temps d\'attente',
      );
      
      // Démarrer le comptage
      _countUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        setState(() {
      
            _currentCount++;
         
        });
      });
    }
  }
  
  void _stopCountUp() {
    _countUpTimer?.cancel();
  }
  
  void _startRide() {
    _stopCountUp(); // Arrêter le minuteur
    // Cacher le toast
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    widget.onStartRide();
  }

  // Ancien widget de minuteur remplacé par CountdownToast
  Widget _buildTimerWidget() {
    return const SizedBox.shrink();
  }

  // Ancien widget de segment de temps non utilisé
  Widget _buildTimeSegment(String value, String label) {
    return const SizedBox.shrink();
  }

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
            child: Column(
              children: [
                // ... (le reste du contenu existant)
                
                // Bouton Confirmer mon arrivée
                if (!_clientPickedUp) ...[
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _startCountUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirmer mon arrivée',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                
                // Bouton Démarrer la course
                if (_clientPickedUp) ...[
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _startRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Démarrer la course',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
