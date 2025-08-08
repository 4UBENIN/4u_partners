import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:stacked/stacked.dart';

import 'profil_pressing_viewmodel.dart';

class ProfilPressingView extends StackedView<ProfilPressingViewModel> {
  const ProfilPressingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProfilPressingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Profil"),
        centerTitle: true,
        backgroundColor: backgroundColor,
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, ProfilPressingViewModel viewModel) {
    // État de chargement
    if (viewModel.isBusy) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: primaryColor,
            ),
            SizedBox(height: 16),
            Text("Chargement du profil..."),
          ],
        ),
      );
    }

    // Gestion des erreurs
    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                "Erreur",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(height: 8),
              // Text(
              //   viewModel.errorMessage!,
              //   textAlign: TextAlign.center,
              //   style: const TextStyle(color: Colors.grey),
              // ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                  onPressed: viewModel.retry,
                  icon: const Icon(
                    Icons.refresh,
                    color: primaryColor,
                  ),
                  label: const Text(
                    "Réessayer",
                    style: TextStyle(color: primaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
            ],
          ),
        ),
      );
    }

    // Cas où aucune donnée n'est trouvée
    final pressing = viewModel.pressing;
    if (pressing == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Aucune information trouvée"),
          ],
        ),
      );
    }

    // Affichage des données
    return RefreshIndicator(
      onRefresh: viewModel.fetchPressingInfo,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte principale avec les informations
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec icône
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: primaryColor,
                        child: Text(
                          pressing.nom.isNotEmpty
                              ? pressing.nom[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextComponent(
                              pressing.nom,
                              fontsize: 20,
                              fontweight: FontWeight.bold,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              pressing.statutValidation.toUpperCase(),
                              style: TextStyle(
                                color:
                                    _getStatusColor(pressing.statutValidation),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Informations détaillées
                  _buildInfoRow(Icons.email, "Email", pressing.email),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.phone, "Téléphone", pressing.telephone),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on, "Adresse", pressing.adresse),
                  const SizedBox(height: 12),
                  // _buildInfoRow(Icons.calendar_today, "Inscrit le",
                  // _formatDate(pressing.createdAt)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    // Vérifier si c'est un champ téléphone
    final isPhone = label.toLowerCase().contains('téléphone') ||
        label.toLowerCase().contains('phone');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isPhone)
          _buildPhoneNumber(value)
        else
          TextComponent(
            value,
            fontsize: 17,
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPhoneNumber(String phoneNumber) {
    // Vérifier si le numéro commence par +229
    if (phoneNumber.startsWith('+229')) {
      return Row(
        children: [
          const Text(
            '+229 ',
            style: TextStyle(
              fontSize: 17,
            ),
          ),
          Text(
            phoneNumber.substring(4).trim(), // Tout après le +229
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
        ],
      );
    }

    // Pour les numéros qui ne commencent pas par +229
    return TextComponent(
      phoneNumber,
      fontsize: 17,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'validé':
      case 'approved':
        return Colors.green;
      case 'en_attente':
      case 'pending':
        return Colors.orange;
      case 'refusé':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  ProfilPressingViewModel viewModelBuilder(BuildContext context) =>
      ProfilPressingViewModel();
}
