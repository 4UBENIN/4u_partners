import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';

class DotsLoader extends StatefulWidget {
  const DotsLoader({super.key});

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();

    _animation1 = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)),
    );

    _animation2 = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5)),
    );

    _animation3 = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(_animation1.value),
            const SizedBox(width: 8),
            _buildDot(_animation2.value),
            const SizedBox(width: 8),
            _buildDot(_animation3.value),
          ],
        );
      },
    );
  }

  Widget _buildDot(double offset) {
    return Transform.translate(
      offset: Offset(0, -offset),
      child: const CircleAvatar(radius: 3, backgroundColor: primaryColor),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
