import 'package:flutter/material.dart';
import 'package:for_u_partners/models/user_model.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/profil/profil_viewmodel.dart';
import 'package:intl/intl.dart';

class EditProfileView extends StatefulWidget {
  final UserModel user;
  final ProfilViewModel viewModel;

  const EditProfileView({
    Key? key,
    required this.user,
    required this.viewModel,
  }) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _emailController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _adresseController;
  late final TextEditingController _dateNaissanceController;
  late String? _selectedGenre;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadUserProfile();
    });
  }

  void _initializeControllers() {
    _nomController = TextEditingController(text: widget.user.nom);
    _prenomController = TextEditingController(text: widget.user.prenom);
    _emailController = TextEditingController(text: widget.user.email);
    _telephoneController = TextEditingController(text: widget.user.telephone);
    _adresseController = TextEditingController(text: widget.user.adresse ?? '');
    _dateNaissanceController = TextEditingController(
        text: widget.user.dateNaissance != null
            ? DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(widget.user.dateNaissance!))
            : '');
    _selectedGenre = widget.user.genre;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (widget.viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // En-tête avec avatar
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: kcPrimaryColor.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person,
                                size: 40, color: kcPrimaryColor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.user.prenom} ${widget.user.nom}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Informations personnelles
                    _buildSectionTitle('Informations personnelles'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _nomController,
                      label: 'Nom',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Le nom est requis' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _prenomController,
                      label: 'Prénom',
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Le prénom est requis'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'L\'email est requis';
                        }
                        if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+$')
                            .hasMatch(value!)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _telephoneController,
                      label: 'Téléphone',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Le téléphone est requis'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Section Informations supplémentaires
                    _buildSectionTitle('Informations supplémentaires'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _adresseController,
                      label: 'Adresse',
                    ),
                    const SizedBox(height: 16),

                    _buildDateField(
                      context: context,
                      controller: _dateNaissanceController,
                      label: 'Date de naissance',
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      value: _selectedGenre,
                      items: const [
                        DropdownMenuItem(
                            value: 'masculin', child: Text('Masculin')),
                        DropdownMenuItem(
                            value: 'feminin', child: Text('Féminin')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGenre = value;
                        });
                      },
                      label: 'Genre',
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Bouton de validation fixe en bas
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.viewModel.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: widget.viewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      await widget.viewModel.updateUserProfile(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        adresse: _adresseController.text.trim(),
        dateNaissance: _dateNaissanceController.text.trim(),
        genre: _selectedGenre,
      );

      if (mounted && widget.viewModel.errorMessage == null) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profil mis à jour avec succès'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: controller.text.isNotEmpty
                ? DateTime.parse(controller.text)
                : DateTime.now().subtract(const Duration(days: 365 * 18)),
            firstDate: DateTime(1900),
            lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
          );

          if (date != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(date);
          }
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            items: items,
            onChanged: onChanged,
            hint: const Text('Sélectionnez un genre'),
            isExpanded: true,
          ),
        ),
      ),
    );
  }
}
