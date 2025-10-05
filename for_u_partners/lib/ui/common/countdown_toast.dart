import 'dart:async';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';

class CountdownToast extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback? onCountdownFinished;
  final String message;
  final bool countUp; // Nouveau paramètre pour compter vers le haut
  final int? maxSeconds; // Limite maximale pour le comptage ascendant

  const CountdownToast({
    Key? key,
    required this.initialSeconds,
    this.onCountdownFinished,
    this.message = 'Temps d\'attente',
    this.countUp = false,
    this.maxSeconds,
  }) : super(key: key);

  @override
  _CountdownToastState createState() => _CountdownToastState();

  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    required int initialSeconds,
    VoidCallback? onCountdownFinished,
    String message = 'Temps d\'attente',
    bool countUp = false,
    int? maxSeconds,
  }) {
    // Supprimer l'overlay existant s'il y en a un
    _currentOverlay?.remove();
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    void removeOverlay() {
      overlayEntry.remove();
      _currentOverlay = null;
      onCountdownFinished?.call();
    }
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: CountdownToast(
            initialSeconds: initialSeconds,
            onCountdownFinished: removeOverlay,
            message: message,
            countUp: countUp,
            maxSeconds: maxSeconds,
          ),
        ),
      ),
    );

    // Ajouter l'overlay à l'écran
    overlay.insert(overlayEntry);
    _currentOverlay = overlayEntry;
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _CountdownToastState extends State<CountdownToast> {
  late int _countdown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _countdown = widget.initialSeconds;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (widget.countUp) {
          // Mode comptage ascendant
          if (widget.maxSeconds == null || _countdown < widget.maxSeconds!) {
            _countdown++;
          } else {
            timer.cancel();
            widget.onCountdownFinished?.call();
          }
        } else {
          // Mode décompte descendant
          if (_countdown > 0) {
            _countdown--;
          } else {
            timer.cancel();
            widget.onCountdownFinished?.call();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (_countdown % 60).toString().padLeft(2, '0');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: kcPrimaryColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              '${widget.message}: $minutes:${seconds}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
