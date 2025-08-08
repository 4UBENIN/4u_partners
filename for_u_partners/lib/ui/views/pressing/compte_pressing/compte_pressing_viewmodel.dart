import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/pressing_model.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/services/pressing_service.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class ComptePressingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();
  final _pressingService = locator<PressingService>();

  Pressing? _pressing;
  Pressing? get pressing => _pressing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  ComptePressingViewModel() {
    fetchPressingInfo();
  }

  //* METHODS
  void viewProfile() {
    _navigationService.navigateToProfilPressingView();
  }

  Future<void> fetchPressingInfo() async {
    setBusy(true);
    _errorMessage = null; // Reset l'erreur
    notifyListeners();

    try {
      final response = await _pressingService.getPressingInfo();
      // ignore: unnecessary_null_comparison
      if (response != null && response.pressing != null) {
        _pressing = response.pressing;
        _errorMessage = null;
      } else {
        _errorMessage = "Aucune information de pressing trouvée";
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("Erreur dans ViewModel: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Méthode pour retry en cas d'erreur
  Future<void> retry() async {
    await fetchPressingInfo();
  }

  void logOutAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Se déconnecter'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _authService.logOut();
                _navigationService.navigateToLoginView();
              },
              child: const Text(
                'Oui, bye',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
