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

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text(
                    'Photo de profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Divider(),
                if (widget.viewModel.user?.photoUrl == null)
                  ListTile(
                    leading: const Icon(Icons.add_a_photo, color: kcPrimaryColor),
                    title: const Text('Ajouter une photo'),
                    onTap: () {
                      Navigator.pop(context);
                      widget.viewModel.pickAndUploadPhoto(context);
                    },
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.remove_red_eye, color: kcPrimaryColor),
                    title: const Text('Voir la photo'),
                    onTap: () {
                      Navigator.pop(context);
                      _showFullScreenImage();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit, color: kcPrimaryColor),
                    title: const Text('Modifier la photo'),
                    onTap: () {
                      Navigator.pop(context);
                      widget.viewModel.pickAndUploadPhoto(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      widget.viewModel.deleteProfilePhoto(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage() {
    if (widget.viewModel.user?.photoUrl == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  widget.viewModel.user!.photoUrl!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
                  // Avatar avec photo
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: widget.viewModel.user?.photoUrl == null
                                ? kcPrimaryColor.withValues(alpha: 0.4)
                                : null,
                            shape: BoxShape.circle,
                            image: widget.viewModel.user?.photoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(widget.viewModel.user!.photoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: widget.viewModel.user?.photoUrl == null
                              ? const Icon(Icons.person, size: 50, color: kcPrimaryColor)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: kcPrimaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: widget.viewModel.isUploadingPhoto
                                ? const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
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
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _showPhotoOptions,
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(
                      widget.viewModel.user?.photoUrl == null
                          ? 'Ajouter une photo'
                          : 'Modifier la photo',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: kcPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Informations personnelles'),
            const SizedBox(height: 16),

            _buildTextField(controller: _nomController, label: 'Nom'),
            const SizedBox(height: 16),

            _buildTextField(controller: _prenomController, label: 'Prénom'),
            const SizedBox(height: 16),

            _buildTextField(controller: _emailController, label: 'Email'),
            const SizedBox(height: 16),

            _buildTextField(controller: _telephoneController, label: 'Téléphone'),
            const SizedBox(height: 24),

            _buildSectionTitle('Informations supplémentaires'),
            const SizedBox(height: 16),

            _buildTextField(controller: _adresseController, label: 'Adresse'),
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
                DropdownMenuItem(value: 'masculin', child: Text('Masculin')),
                DropdownMenuItem(value: 'feminin', child: Text('Féminin')),
              ],
              label: 'Genre',
            ),
            const SizedBox(height: 32),
          ],
        ),
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

  Widget _buildTextField({
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
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
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
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<DropdownMenuItem<String>> items,
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
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            items: items,
            onChanged: null,
            isExpanded: true,
          ),
        ),
      ),
    );
  }
}