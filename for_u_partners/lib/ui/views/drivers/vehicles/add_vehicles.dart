import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:for_u_partners/models/vehicle_model.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:image_picker/image_picker.dart';

class AddVehiclesView extends StatefulWidget {
  const AddVehiclesView({Key? key}) : super(key: key);

  @override
  _AddVehiclesViewState createState() => _AddVehiclesViewState();
}

class _AddVehiclesViewState extends State<AddVehiclesView> {
  final AddVehiclesViewModel viewModel = AddVehiclesViewModel();
  
  final _formKey = GlobalKey<FormState>();
  final _marqueController = TextEditingController();
  final _modeleController = TextEditingController();
  final _immatriculationController = TextEditingController();
  final _couleurController = TextEditingController();
  final _anneeController = TextEditingController();
  
  @override
  void dispose() {
    _marqueController.dispose();
    _modeleController.dispose();
    _immatriculationController.dispose();
    _couleurController.dispose();
    _anneeController.dispose();
    super.dispose();
  }
  
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Veuillez corriger les erreurs dans le formulaire');
      return;
    }
    
    // Validation des fichiers requis
    String missingFiles = '';
    if (viewModel.selectedVehicleType == 'voiture') {
      if (viewModel.carteGrise == null) missingFiles += 'Carte grise, ';
      if (viewModel.assurance == null) missingFiles += 'Assurance, ';
      if (viewModel.permis == null) missingFiles += 'Permis de conduire, ';
    } else {
      if (viewModel.carteGrise == null) missingFiles += 'Carte grise, ';
      if (viewModel.assurance == null) missingFiles += 'Assurance, ';
    }
    
    if (missingFiles.isNotEmpty) {
      missingFiles = missingFiles.replaceAll(RegExp(r', $'), '');
      _showErrorSnackBar('Fichiers manquants: $missingFiles');
      return;
    }
    
    final vehicle = Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      marque: _marqueController.text.trim(),
      model: _modeleController.text.trim(),
      immatriculation: _immatriculationController.text.trim().toUpperCase(),
      couleur: _couleurController.text.isNotEmpty ? _couleurController.text.trim() : 'Non spécifiée',
      statut: 'en_attente',
      categorie: viewModel.selectedCategory,
    );
    
    viewModel.addVehicle(
      vehicle,
      context,
      carteGrise: viewModel.carteGrise,
      assurance: viewModel.assurance,
      permis: viewModel.permis,
      vehicleType: viewModel.selectedVehicleType,
      annee: _anneeController.text.trim(),
    );
  }
  
  InputDecoration _buildInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF184E9C)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF184E9C), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      labelStyle: const TextStyle(color: Color(0xFF666666), fontSize: 14),
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      errorMaxLines: 2,
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un véhicule',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      backgroundColor: const Color(0xFFFFFBFF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Informations du véhicule',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complétez les informations de votre véhicule',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type de véhicule
                    Text(
                      'Type de véhicule *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => viewModel.selectedVehicleType = 'moto');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: viewModel.selectedVehicleType == 'moto'
                                    ? const Color(0xFF184E9C)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: viewModel.selectedVehicleType == 'moto'
                                      ? const Color(0xFF184E9C)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                'Moto',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: viewModel.selectedVehicleType == 'moto'
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => viewModel.selectedVehicleType = 'tricycle');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: viewModel.selectedVehicleType == 'tricycle'
                                    ? const Color(0xFF184E9C)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: viewModel.selectedVehicleType == 'tricycle'
                                      ? const Color(0xFF184E9C)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                'Tricycle',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: viewModel.selectedVehicleType == 'tricycle'
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => viewModel.selectedVehicleType = 'voiture');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: viewModel.selectedVehicleType == 'voiture'
                                    ? const Color(0xFF184E9C)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: viewModel.selectedVehicleType == 'voiture'
                                      ? const Color(0xFF184E9C)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                'Voiture',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: viewModel.selectedVehicleType == 'voiture'
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Marque
                    TextFormField(
                      controller: _marqueController,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s-]')),
                        LengthLimitingTextInputFormatter(50),
                      ],
                      decoration: _buildInputDecoration(
                        'Marque *',
                        'Ex: Toyota, Peugeot, Honda',
                        Icons.directions_car,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La marque est requise';
                        }
                        if (value.trim().length < 2) {
                          return 'La marque doit contenir au moins 2 caractères';
                        }
                        if (value.trim().length > 50) {
                          return 'La marque est trop longue (max 50 caractères)';
                        }
                        if (!RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$').hasMatch(value.trim())) {
                          return 'La marque ne peut contenir que des lettres';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Auto-validation en temps réel
                        _formKey.currentState?.validate();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Modèle
                    TextFormField(
                      controller: _modeleController,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      decoration: _buildInputDecoration(
                        'Modèle *',
                        'Ex: Yaris, 208, CBR 500',
                        Icons.model_training,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le modèle est requis';
                        }
                        if (value.trim().length < 2) {
                          return 'Le modèle doit contenir au moins 2 caractères';
                        }
                        if (value.trim().length > 50) {
                          return 'Le modèle est trop long (max 50 caractères)';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _formKey.currentState?.validate();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Couleur
                    TextFormField(
                      controller: _couleurController,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s-]')),
                        LengthLimitingTextInputFormatter(30),
                      ],
                      decoration: _buildInputDecoration(
                        'Couleur *',
                        'Ex: Rouge, Noir, Blanc, Bleu',
                        Icons.palette,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La couleur est requise';
                        }
                        if (value.trim().length < 3) {
                          return 'La couleur doit contenir au moins 3 caractères';
                        }
                        if (value.trim().length > 30) {
                          return 'La couleur est trop longue (max 30 caractères)';
                        }
                        if (!RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$').hasMatch(value.trim())) {
                          return 'La couleur ne peut contenir que des lettres';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _formKey.currentState?.validate();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Immatriculation
                    TextFormField(
                      controller: _immatriculationController,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s-]')),
                        LengthLimitingTextInputFormatter(15),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          return TextEditingValue(
                            text: newValue.text.toUpperCase(),
                            selection: newValue.selection,
                          );
                        }),
                      ],
                      decoration: _buildInputDecoration(
                        'Immatriculation *',
                        'Ex: AB-123-CD ou 1234AB56',
                        Icons.confirmation_number,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L\'immatriculation est requise';
                        }
                        final cleanValue = value.trim().toUpperCase();
                        if (cleanValue.length < 4) {
                          return 'L\'immatriculation est trop courte (min 4 caractères)';
                        }
                        if (cleanValue.length > 15) {
                          return 'L\'immatriculation est trop longue (max 15 caractères)';
                        }
                        // Accepte les formats: AA-123-BB, AA123BB, 1234AB56, etc.
                        if (!RegExp(r'^[A-Z0-9\s-]+$').hasMatch(cleanValue)) {
                          return 'Format invalide (lettres, chiffres, tirets uniquement)';
                        }
                        // Vérifie qu'il y a au moins une lettre ET un chiffre
                        if (!RegExp(r'[A-Z]').hasMatch(cleanValue) || !RegExp(r'[0-9]').hasMatch(cleanValue)) {
                          return 'L\'immatriculation doit contenir des lettres et des chiffres';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _formKey.currentState?.validate();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Année
                    TextFormField(
                      controller: _anneeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: _buildInputDecoration(
                        'Année *',
                        'Ex: 2020',
                        Icons.calendar_month,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L\'année est requise';
                        }
                        if (value.trim().length != 4) {
                          return 'L\'année doit contenir 4 chiffres';
                        }
                        final year = int.tryParse(value.trim());
                        if (year == null) {
                          return 'L\'année doit être un nombre valide';
                        }
                        final currentYear = DateTime.now().year;
                        if (year < 1990) {
                          return 'L\'année doit être supérieure ou égale à 1990';
                        }
                        if (year > currentYear + 1) {
                          return 'L\'année ne peut pas dépasser ${currentYear + 1}';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _formKey.currentState?.validate();
                      },
                    ),
                    const SizedBox(height: 28),

                    // Documents
                    const Text(
                      'Documents requis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Formats acceptés: JPG, PNG, PDF (max 5 MB)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Permis (pour voiture uniquement)
                    if (viewModel.selectedVehicleType == 'voiture') ...[
                      _buildFileUpload(
                        'Permis de conduire *',
                        viewModel.permis,
                        () => viewModel.pickFile((file) {
                          setState(() => viewModel.permis = file);
                        }),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Carte grise
                    _buildFileUpload(
                      'Carte grise *',
                      viewModel.carteGrise,
                      () => viewModel.pickFile((file) {
                        setState(() => viewModel.carteGrise = file);
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Assurance
                    _buildFileUpload(
                      'Assurance *',
                      viewModel.assurance,
                      () => viewModel.pickFile((file) {
                        setState(() => viewModel.assurance = file);
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Note informative
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tous les champs marqués d\'un * sont obligatoires',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bouton soumettre
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF184E9C),
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Ajouter le véhicule',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUpload(
    String label,
    XFile? file,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: file != null ? 150 : 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: file != null
                    ? const Color(0xFF184E9C)
                    : Colors.grey[300]!,
                width: 2,
              ),
              color: file != null ? const Color(0xFF184E9C).withOpacity(0.05) : Colors.grey[50],
            ),
            child: file != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(file.path),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF184E9C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choisir une image',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class AddVehiclesViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String selectedVehicleType = 'voiture';
  String selectedCategory = 'standard';
  final List<String> categories = ['standard', 'premium', 'vip'];
  
  XFile? carteGrise;
  XFile? assurance;
  XFile? permis;
  
  final _sharedPreferencesService = locator<SharedpreferencesService>();
  final Dio _dio = Dio();
  final String _baseUrl = 'https://foryou.cilassocies.com/api';
  final ImagePicker _picker = ImagePicker();
  
  Future<void> pickFile(Function(XFile) onFilePicked) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file != null) {
        // Vérification de la taille du fichier (max 5 MB)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Le fichier est trop volumineux (max 5 MB)');
        }
        onFilePicked(file);
      }
    } catch (e) {
      print('Erreur lors de la sélection du fichier: $e');
      rethrow;
    }
  }
  
  Future<void> addVehicle(
    Vehicle vehicle,
    BuildContext context, {
    required XFile? carteGrise,
    required XFile? assurance,
    required XFile? permis,
    required String vehicleType,
    required String annee,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await _sharedPreferencesService.getToken();
      final userId = await _sharedPreferencesService.getUserId();
      
      if (token == null || token.isEmpty) {
        _showErrorSnackBar(context, 'Authentification requise');
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final cleanToken = token.replaceAll('"', '').trim();
      
      // Créer FormData pour upload avec fichiers
      final formData = FormData();
      
      formData.fields.addAll([
        MapEntry('marque', vehicle.marque),
        MapEntry('modele', vehicle.model),
        MapEntry('immatriculation', vehicle.immatriculation),
        MapEntry('couleur', vehicle.couleur ?? 'Noire'),
        MapEntry('statut', 'en_attente'),
        MapEntry('annee', annee),
      ]);
      
      if (carteGrise != null) {
        formData.files.add(
          MapEntry(
            'carte_grise',
            await MultipartFile.fromFile(carteGrise.path),
          ),
        );
      }
      
      if (assurance != null) {
        formData.files.add(
          MapEntry(
            'assurance',
            await MultipartFile.fromFile(assurance.path),
          ),
        );
      }
      
      if (permis != null) {
        formData.files.add(
          MapEntry(
            'permis_conduire',
            await MultipartFile.fromFile(permis.path),
          ),
        );
      }
      
      final response = await _dio.post(
        '$_baseUrl/vehicules',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $cleanToken',
            'Accept': 'application/json',
          },
        ),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar(context, 'Véhicule ajouté avec succès');
        if (context.mounted) {
          Navigator.pop(context, vehicle);
        }
      } else {
        _showErrorSnackBar(context, 'Erreur lors de l\'ajout du véhicule');
      }
      
    } on DioException catch (e) {
      String errorMessage = _formatDioError(e);
      _showErrorSnackBar(context, errorMessage);
    } catch (e) {
      _showErrorSnackBar(context, 'Erreur: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  String _formatDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai d\'expiration. Vérifiez votre connexion.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Authentification échouée. Reconnectez-vous.';
        }
        if (e.response?.statusCode == 422) {
          return 'Données invalides. Vérifiez les informations saisies.';
        }
        if (e.response?.statusCode == 413) {
          return 'Les fichiers sont trop volumineux.';
        }
        return 'Erreur serveur: ${e.response?.statusCode}';
      case DioExceptionType.connectionError:
        return 'Erreur de connexion internet.';
      case DioExceptionType.badCertificate:
        return 'Erreur de certificat de sécurité.';
      default:
        return 'Une erreur est survenue.';
    }
  }
  
  void _showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// Extension pour FileSystemException
class FileSystemException implements Exception {
  final String message;
  FileSystemException(this.message);
  
  @override
  String toString() => message;
}