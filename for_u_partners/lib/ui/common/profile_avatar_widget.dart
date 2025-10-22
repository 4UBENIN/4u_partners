import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double size;
  final bool showEditButton;
  final bool isUploading;
  final VoidCallback? onEditPressed;

  const ProfileAvatarWidget({
    Key? key,
    this.photoUrl,
    required this.initials,
    this.size = 120,
    this.showEditButton = false,
    this.isUploading = false,
    this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Avatar principal
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
            gradient: photoUrl == null
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF184E9C), Color(0xFF2A5BB8)],
                  )
                : null,
            image: photoUrl != null
                ? DecorationImage(
                    image: NetworkImage(photoUrl!),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // En cas d'erreur de chargement, afficher les initiales
                      debugPrint('Erreur de chargement de l\'image: $exception');
                    },
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: photoUrl == null
              ? Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),

        // Badge de chargement ou bouton d'édition
        if (showEditButton)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: isUploading ? null : onEditPressed,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: kcPrimaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isUploading
                    ? Padding(
                        padding: EdgeInsets.all(size * 0.06),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: size * 0.15,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
      ],
    );
  }
}