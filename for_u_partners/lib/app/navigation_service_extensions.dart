import 'package:for_u_partners/models/user_model.dart';
import 'package:for_u_partners/ui/views/drivers/profil/edit_profile_view.dart';
import 'package:for_u_partners/ui/views/drivers/profil/profil_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

/// Extensions for NavigationService to add custom navigation methods
extension NavigationServiceExtensions on NavigationService {
  /// Navigates to the edit profile view
  void navigateToEditProfileView(UserModel user, ProfilViewModel viewModel) {
    navigateToView(EditProfileView(user: user, viewModel: viewModel));
  }
}
