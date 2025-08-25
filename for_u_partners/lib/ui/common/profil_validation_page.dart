import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfileValidationPage extends StatefulWidget {
  const ProfileValidationPage({Key? key}) : super(key: key);

  @override
  State<ProfileValidationPage> createState() => _ProfileValidationPageState();
}

class _ProfileValidationPageState extends State<ProfileValidationPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  late AnimationController _slideController;
  late AnimationController _shineController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation pour l'icône pulsante
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Animation pour les points de chargement
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
    
    // Animation d'entrée
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Animation de brillance
    _shineController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    
    _shineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );
    
    // Démarrer l'animation d'entrée
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    _slideController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _slideAnimation.value)),
                  child: Opacity(
                    opacity: _slideAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          //mainAxisSize: MainAxisSize.min,
                          children: [
                            // Barre de progression animée
                           
                            
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
                              child: Column(
                                children: [
                                  // Icône animée
                                  _buildAnimatedIcon(),
                                  
                                  const SizedBox(height: 30),
                                  
                                  // Titre
                                  const Text(
                                    'Profil Créé avec Succès !',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Sous-titre avec points animés
                                  _buildSubtitleWithDots(),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Message principal
                                  const Text(
                                    'Félicitations ! Votre profil a été créé avec succès. Pour finaliser l\'activation de votre compte, une validation en agence est requise.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Étapes
                                  _buildStepsSection(),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Boîte d'information
                                  _buildInfoBox(),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Message final
                                  _buildFinalMessage(),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Boutons en ligne
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Bouton Se connecter
                                   
                                      
                                      // Bouton J'ai compris
                                      ElevatedButton(
                                        onPressed: () {
                                        NavigationService().navigateToLoginView();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF184E9C),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: const Text(
                                          'Se connecter',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF184E9C), Color(0xFF2563EB)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF184E9C).withOpacity(0.4),
                  blurRadius: 20 * _pulseAnimation.value,
                  spreadRadius: (20 * _pulseAnimation.value) - 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.access_time,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitleWithDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'En attente de validation',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF184E9C),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        _buildLoadingDots(),
      ],
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final animationValue = (_dotsController.value - (index * 0.16)) % 1.0;
            final opacity = animationValue < 0.4 ? (animationValue / 0.4) : 
                           animationValue > 0.8 ? (1.0 - (animationValue - 0.8) / 0.2) : 1.0;
            final scale = animationValue < 0.4 ? 0.8 + (0.2 * (animationValue / 0.4)) : 
                         animationValue > 0.8 ? 1.0 - (0.2 * (animationValue - 0.8) / 0.2) : 1.0;
            
            return Container(
              margin: const EdgeInsets.only(right: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF184E9C).withOpacity(opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStepsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Prochaines étapes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF184E9C),
            ),
          ),
          const SizedBox(height: 16),
          _buildStep(1, 'Rendez-vous dans l\'une de nos agences avec une pièce d\'identité valide'),
          const SizedBox(height: 12),
          _buildStep(2, 'Présentez-vous au guichet et mentionnez votre demande de validation de compte'),
          const SizedBox(height: 12),
          _buildStep(3, 'Votre compte sera activé immédiatement après vérification'),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2, right: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF184E9C),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF184E9C).withOpacity(0.1),
            const Color(0xFF2563EB).withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF184E9C).withOpacity(0.2),
        ),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF184E9C),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Important',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF184E9C),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Vous recevrez une notification par email dès que votre compte sera validé et activé.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalMessage() {
    return AnimatedBuilder(
      animation: _shineAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF184E9C).withOpacity(0.05),
                const Color(0xFF2563EB).withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF184E9C).withOpacity(0.15),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Effet de brillance
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Transform.translate(
                    offset: Offset(MediaQuery.of(context).size.width * _shineAnimation.value, 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF184E9C).withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF184E9C), Color(0xFF2563EB)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF184E9C).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phone_android,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Une fois votre profil validé',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF184E9C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Revenez sur l\'application pour profiter de tous nos services. Vous pourrez alors accéder à votre compte complet et utiliser toutes les fonctionnalités.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4B5563),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}