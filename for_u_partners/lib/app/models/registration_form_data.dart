class RegistrationFormData {
  // Étape 1: Informations de base
  String? phoneNumber;
  String? email;
  String? password;
  
  // Étape 2: Informations du profil
  String? profileType;
  Map<String, dynamic> profileData = {};
  
  // Méthodes utilitaires
  bool validateStep1() {
    return phoneNumber?.isNotEmpty == true && 
           email?.isNotEmpty == true && 
           password?.isNotEmpty == true &&
           password!.length >= 6;
  }
  
  bool validateProfileStep() {
    // Validation spécifique au type de profil
    switch (profileType?.toLowerCase()) {
      case 'pressing':
        return profileData['name']?.isNotEmpty == true &&
               profileData['location']?.isNotEmpty == true;
      // Ajoutez d'autres cas pour les autres types de profils
      default:
        return false;
    }
  }
}
