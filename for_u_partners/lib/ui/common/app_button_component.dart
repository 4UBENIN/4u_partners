import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';

//* PRIMARY BUTTON

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isActive;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: const Duration(milliseconds: 150),
      onTap: isActive ? onPressed : null,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? primaryColor : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFB3B3B3),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

//* CANCEL BUTTON

class CancelButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;

  const CancelButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(
                color: primaryColor,
              )),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: primaryColor),
        ),
      ),
    );
  }
}

//* AUTH BUTTON

class AuthProviderButton extends StatelessWidget {
  final String text;
  final String assetPath;
  final VoidCallback onPressed;

  const AuthProviderButton({
    super.key,
    required this.text,
    required this.assetPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(assetPath, height: 24, width: 24),
        label: TextComponent(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: greybutton,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

//* SIMPLE BUTTON

class SimpleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const SimpleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = greybutton,
    this.textColor = const Color(0xFF1E1E1E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: TextComponent(text),
      ),
    );
  }
}

class BackCircularButton extends StatelessWidget {
  final Function()? onTap;
  const BackCircularButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: backButton),
          color: textinsidebutton,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.arrow_back, color: insideBackButton, size: 24),
        ),
      ),
    );
  }
}

class ContinueButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;

  const ContinueButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward,
            color: textinsidebutton,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class ContinueButton2 extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  const ContinueButton2({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward,
            color: textinsidebutton,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class ContinueButtonSimple extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const ContinueButtonSimple(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class SocialButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String icon;
  final String label;
  final Color textColor;

  const SocialButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.textColor,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: widget.onPressed,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(widget.icon),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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
}
