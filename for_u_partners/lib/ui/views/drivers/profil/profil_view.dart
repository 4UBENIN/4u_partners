import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'profil_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';

class ProfilView extends StackedView<ProfilViewModel> {
  const ProfilView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProfilViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: viewModel.isLoading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: kcPrimaryColor,
                size: 50,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    // Avatar
                    Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF184E9C), Color(0xFF2A5BB8)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            viewModel.initials,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Stats Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              viewModel.globalStats?.totalActivities
                                      .toString() ??
                                  '0',
                              'Courses',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              viewModel.globalStats?.totalNotes.toString() ??
                                  '0',
                              'Note',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              _formatAmount(viewModel.globalStats?.totalEarnings
                                      ?.toDouble() ??
                                  0),
                              'Revenus',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: _buildUserIcon(),
                            text: 'Mon compte',
                            onTap: () {
                              viewModel.navigateToEditProfile(context);
                            },
                          ),
                          _buildMenuItem(
                            icon: _buildWalletIcon(),
                            text: 'Portefeuille',
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: _buildHistoryIcon(),
                            text: 'Historique',
                            onTap: () {
                              viewModel.navigationService
                                  .navigateToActivityView();
                            },
                          ),
                          _buildMenuItem(
                            icon: _buildLogoutIcon(),
                            text: 'Log Out',
                            isLogout: true,
                            onTap: () {
                              viewModel.logOut();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Fonction utilitaire pour formater les montants
  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M F';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1).replaceAll('.0', '')}K F';
    } else {
      return '${amount.toStringAsFixed(0)} F';
    }
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF184E9C),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: icon,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: isLogout
                        ? const Color(0xFFDC3545)
                        : const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '›',
                style: TextStyle(
                  fontSize: 18,
                  color: isLogout
                      ? const Color(0xFFDC3545)
                      : const Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom SVG Icons with stroke
  Widget _buildUserIcon() {
    return CustomPaint(
      size: const Size(24, 24),
      painter: UserIconPainter(),
    );
  }

  Widget _buildStatsIcon() {
    return CustomPaint(
      size: const Size(24, 24),
      painter: StatsIconPainter(),
    );
  }

  Widget _buildWalletIcon() {
    return CustomPaint(
      size: const Size(24, 24),
      painter: WalletIconPainter(),
    );
  }

  Widget _buildCarIcon() {
    return CustomPaint(
      size: const Size(24, 24),
      painter: CarIconPainter(),
    );
  }

  Widget _buildHistoryIcon() {
    return CustomPaint(
      size: const Size(24, 24),
      painter: HistoryIconPainter(),
    );
  }

  Widget _buildHelpIcon() {
    return CustomPaint(
      size: const Size(24, 24),
      painter: HelpIconPainter(),
    );
  }

  Widget _buildLogoutIcon() {
    return CustomPaint(
      size: const Size(24, 24),
      painter: LogoutIconPainter(),
    );
  }

  @override
  ProfilViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ProfilViewModel();
}

// Custom Painters for Icons
class UserIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF184E9C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..colorFilter =
          const ColorFilter.mode(Color(0xFF184E9C), BlendMode.srcIn);

    // Head circle
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.29),
      size.width * 0.17,
      paint,
    );

    // Body path
    final path = Path();
    path.moveTo(size.width * 0.17, size.height * 0.875);
    path.lineTo(size.width * 0.17, size.height * 0.792);
    path.cubicTo(
      size.width * 0.17,
      size.height * 0.625,
      size.width * 0.306,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.694,
      size.height * 0.5,
      size.width * 0.833,
      size.height * 0.625,
      size.width * 0.833,
      size.height * 0.792,
    );
    path.lineTo(size.width * 0.833, size.height * 0.875);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StatsIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF184E9C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..colorFilter =
          const ColorFilter.mode(Color(0xFF184E9C), BlendMode.srcIn);

    // Three vertical lines for bar chart
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.833),
      Offset(size.width * 0.25, size.height * 0.583),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.833),
      Offset(size.width * 0.5, size.height * 0.167),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.833),
      Offset(size.width * 0.75, size.height * 0.417),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WalletIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF184E9C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Wallet outline
    final path1 = Path();
    path1.moveTo(size.width * 0.875, size.height * 0.5);
    path1.lineTo(size.width * 0.875, size.height * 0.292);
    path1.lineTo(size.width * 0.208, size.height * 0.292);
    path1.cubicTo(
      size.width * 0.125,
      size.height * 0.292,
      size.width * 0.083,
      size.height * 0.25,
      size.width * 0.083,
      size.height * 0.208,
    );
    path1.cubicTo(
      size.width * 0.083,
      size.height * 0.125,
      size.width * 0.125,
      size.height * 0.083,
      size.width * 0.208,
      size.height * 0.083,
    );
    path1.lineTo(size.width * 0.792, size.height * 0.083);
    path1.lineTo(size.width * 0.792, size.height * 0.25);

    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(size.width * 0.125, size.height * 0.208);
    path2.lineTo(size.width * 0.125, size.height * 0.792);
    path2.cubicTo(
      size.width * 0.125,
      size.height * 0.875,
      size.width * 0.167,
      size.height * 0.917,
      size.width * 0.208,
      size.height * 0.917,
    );
    path2.lineTo(size.width * 0.875, size.height * 0.917);
    path2.lineTo(size.width * 0.875, size.height * 0.708);

    canvas.drawPath(path2, paint);

    final path3 = Path();
    path3.moveTo(size.width * 0.75, size.height * 0.5);
    path3.cubicTo(
      size.width * 0.694,
      size.height * 0.5,
      size.width * 0.667,
      size.height * 0.528,
      size.width * 0.667,
      size.height * 0.583,
    );
    path3.cubicTo(
      size.width * 0.667,
      size.height * 0.639,
      size.width * 0.694,
      size.height * 0.667,
      size.width * 0.75,
      size.height * 0.667,
    );
    path3.lineTo(size.width * 0.917, size.height * 0.667);
    path3.lineTo(size.width * 0.917, size.height * 0.5);
    path3.close();

    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CarIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF184E9C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Car body
    final path = Path();
    path.moveTo(size.width * 0.208, size.height * 0.25);
    path.cubicTo(
      size.width * 0.208,
      size.height * 0.167,
      size.width * 0.292,
      size.height * 0.125,
      size.width * 0.333,
      size.height * 0.125,
    );
    path.lineTo(size.width * 0.667, size.height * 0.125);
    path.cubicTo(
      size.width * 0.708,
      size.height * 0.125,
      size.width * 0.792,
      size.height * 0.167,
      size.width * 0.792,
      size.height * 0.25,
    );
    path.lineTo(size.width * 0.792, size.height * 0.333);
    path.cubicTo(
      size.width * 0.792,
      size.height * 0.375,
      size.width * 0.75,
      size.height * 0.375,
      size.width * 0.75,
      size.height * 0.375,
    );
    path.lineTo(size.width * 0.25, size.height * 0.375);
    path.cubicTo(
      size.width * 0.208,
      size.height * 0.375,
      size.width * 0.208,
      size.height * 0.375,
      size.width * 0.208,
      size.height * 0.333,
    );
    path.close();

    canvas.drawPath(path, paint);

    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.208, size.height * 0.375);
    bodyPath.lineTo(size.width * 0.208, size.height * 0.625);
    bodyPath.cubicTo(
      size.width * 0.208,
      size.height * 0.667,
      size.width * 0.25,
      size.height * 0.708,
      size.width * 0.25,
      size.height * 0.708,
    );
    path.lineTo(size.width * 0.75, size.height * 0.708);
    path.cubicTo(
      size.width * 0.792,
      size.height * 0.708,
      size.width * 0.792,
      size.height * 0.667,
      size.width * 0.792,
      size.height * 0.625,
    );
    bodyPath.lineTo(size.width * 0.792, size.height * 0.375);

    canvas.drawPath(bodyPath, paint);

    // Wheels
    canvas.drawCircle(
      Offset(size.width * 0.333, size.height * 0.792),
      size.width * 0.083,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.667, size.height * 0.792),
      size.width * 0.083,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HistoryIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF184E9C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Clock circle
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.417,
      paint,
    );

    // Clock hands
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.25),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.667, size.height * 0.583),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HelpIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF184E9C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Circle
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.417,
      paint,
    );

    // Question mark path
    final path = Path();
    path.moveTo(size.width * 0.375, size.height * 0.375);
    path.cubicTo(
      size.width * 0.375,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.25,
      size.width * 0.625,
      size.height * 0.375,
    );
    path.cubicTo(
      size.width * 0.625,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.625,
    );

    canvas.drawPath(path, paint);

    // Dot
    final dotPaint = Paint()
      ..color = const Color(0xFF184E9C)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.708),
      size.width * 0.021,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LogoutIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDC3545)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Door frame
    final path = Path();
    path.moveTo(size.width * 0.375, size.height * 0.875);
    path.lineTo(size.width * 0.208, size.height * 0.875);
    path.cubicTo(
      size.width * 0.125,
      size.height * 0.875,
      size.width * 0.083,
      size.height * 0.833,
      size.width * 0.083,
      size.height * 0.792,
    );
    path.lineTo(size.width * 0.083, size.height * 0.208);
    path.cubicTo(
      size.width * 0.083,
      size.height * 0.125,
      size.width * 0.125,
      size.height * 0.083,
      size.width * 0.208,
      size.height * 0.083,
    );
    path.lineTo(size.width * 0.375, size.height * 0.083);

    canvas.drawPath(path, paint);

    // Arrow
    canvas.drawLine(
      Offset(size.width * 0.667, size.height * 0.708),
      Offset(size.width * 0.875, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.875, size.height * 0.5),
      Offset(size.width * 0.667, size.height * 0.292),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.875, size.height * 0.5),
      Offset(size.width * 0.375, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
