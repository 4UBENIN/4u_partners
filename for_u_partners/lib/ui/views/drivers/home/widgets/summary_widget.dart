import 'package:flutter/material.dart';

class SummaryWidget extends StatefulWidget {
  final int todayCourses;
  final String todayEarnings;

  const SummaryWidget(
      {required this.todayCourses, required this.todayEarnings, super.key});

  @override
  State<SummaryWidget> createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends State<SummaryWidget>
    with TickerProviderStateMixin {
  late AnimationController _coursesController;
  late AnimationController _earningsController;
  late Animation<int> _coursesAnimation;
  late Animation<double> _earningsAnimation;

  @override
  void initState() {
    super.initState();

    // Animation pour les courses
    _coursesController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _coursesAnimation = IntTween(
      begin: 0,
      end: widget.todayCourses,
    ).animate(CurvedAnimation(
      parent: _coursesController,
      curve: Curves.easeOut,
    ));

    // Animation pour les gains (extraire le montant numérique)
    final earningsValue = double.tryParse(widget.todayEarnings
            .replaceAll(RegExp(r'[^\d,.]'), '')
            .replaceAll(',', '')) ??
        0.0;

    _earningsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _earningsAnimation = Tween<double>(
      begin: 0.0,
      end: earningsValue,
    ).animate(CurvedAnimation(
      parent: _earningsController,
      curve: Curves.easeOut,
    ));

    // Démarrer les animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _coursesController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _earningsController.forward();
    });
  }

  @override
  void dispose() {
    _coursesController.dispose();
    _earningsController.dispose();
    super.dispose();
  }

  String _formatEarnings(double value) {
    return '${value.round().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} CFA';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.08),
        //     blurRadius: 20,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
        border: Border.all(color: const Color(0xFFe5e7eb)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Indicateur décoratif
                    Container(
                      width: 20,
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF184E9C).withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _coursesAnimation,
                      builder: (context, child) {
                        return Text(
                          '${_coursesAnimation.value}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF184E9C),
                            height: 1.2,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Courses aujourd\'hui',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748b),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Séparateur vertical
            Container(
              width: 1,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xFFe0e6ed),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            Expanded(
              child: _StatItem(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Indicateur décoratif
                    Container(
                      width: 20,
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF184E9C).withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _earningsAnimation,
                      builder: (context, child) {
                        return Text(
                          _formatEarnings(_earningsAnimation.value),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF184E9C),
                            height: 1.2,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gains aujourd\'hui',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748b),
                        fontWeight: FontWeight.w500,
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
    );
  }
}

class _StatItem extends StatefulWidget {
  final Widget child;

  const _StatItem({required this.child});

  @override
  State<_StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<_StatItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Action au tap si nécessaire
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(minHeight: 80),
          child: widget.child,
        ),
      ),
    );
  }
}
