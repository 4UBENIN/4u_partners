import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/rating_service.dart';
import 'package:for_u_partners/ui/common/toast.dart';

class RateClientViewModel extends BaseViewModel {
  final _ratingService = locator<RatingService>();
  final _navigationService = locator<NavigationService>();

  final TextEditingController commentController = TextEditingController();

  int _selectedRating = 0;
  int get selectedRating => _selectedRating;

  final int courseId;
  final int clientId;
  final String clientName;

  RateClientViewModel({
    required this.courseId,
    required this.clientId,
    required this.clientName,
  });

  void setRating(int rating) {
    _selectedRating = rating;
    notifyListeners();
  }

  bool get canSubmit => _selectedRating > 0;

  Future<void> submitRating(BuildContext context) async {
    if (!canSubmit) {
      CustomToast.showError(context, message: 'Veuillez sélectionner une note');
      return;
    }

    setBusy(true);
    String? errorMessage;
    bool success = false;

    try {
      await _ratingService.createRating(
        serviceId: 3, // 3 = Course/Ride service
        serviceObjectId: courseId,
        note: _selectedRating,
        commentaire: commentController.text.trim().isEmpty
            ? null
            : commentController.text.trim(),
      );

      debugPrint('✅ [RateClientViewModel] Rating submitted successfully');
      success = true;
    } catch (e) {
      debugPrint('❌ [RateClientViewModel] Error submitting rating: $e');
      errorMessage = 'Erreur lors de l\'envoi de l\'avis: ${e.toString()}';
    } finally {
      setBusy(false);
    }

    // Show toast and navigate after async operations
    if (!context.mounted) return;

    if (success) {
      CustomToast.showSuccess(context, message: 'Merci pour votre retour !');
      // Small delay to show the toast before navigating
      await Future.delayed(const Duration(milliseconds: 500));
      _navigationService.back();
    } else if (errorMessage != null) {
      CustomToast.showError(context, message: errorMessage);
    }
  }

  void skipRating() {
    debugPrint('⏭️ [RateClientViewModel] User skipped rating');
    // Pop this screen to go back to recap view, which will then handle navigation to home
    _navigationService.back();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}
