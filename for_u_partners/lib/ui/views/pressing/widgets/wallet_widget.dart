import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';

class WalletPressingWidget extends StatelessWidget {
  final String balance;
  final VoidCallback? onAdd;
  final VoidCallback? onTransfer;

  const WalletPressingWidget(
      {required this.balance, this.onAdd, this.onTransfer, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: kcPrimaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Section informations (gauche)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Portefeuille',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kcWhiteColors,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    balance,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: kcWhiteColors,
                    ),
                  ),
                ],
              ),

              // Section actions (droite)
              Row(
                children: [
                  _actionButton(
                    icon: Icons.add,
                    onTap: onAdd,
                  ),
                  const SizedBox(width: 12),
                  _actionButton(
                    icon: Icons.north,
                    onTap: onTransfer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF333333),
          size: 18,
        ),
      ),
    );
  }
}
