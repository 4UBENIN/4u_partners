// add_document_viewmodel.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/enums/document_type.dart';
import 'package:for_u_partners/services/document_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddDocumentViewModel extends BaseViewModel {
  final _documentService = DocumentService();
  final _navigationService = NavigationService();
  final _snackbarService = locator<SnackbarService>();
  final _sharedPreferencesService = locator<SharedpreferencesService>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  
  DocumentType? selectedType;
  File? selectedFile;
  bool isUploading = false;
  DateTime? expirationDate;

  void updateSelectedType(DocumentType? type) {
    selectedType = type;
    notifyListeners();
  }

  Future<void> pickFile() async {
    try {
      // Utiliser FilePicker au lieu de ImagePicker pour tous types de fichiers
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: true,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Vérifier la taille du fichier (max 5MB)
        final fileSize = await file.length() / 1024 / 1024;
        if (fileSize > 5) {
          _snackbarService.showSnackbar(
            message: 'Le fichier est trop volumineux (max 5MB). Taille: ${fileSize.toStringAsFixed(2)}MB',
            duration: const Duration(seconds: 3),
          );
          return;
        }
        
        print('Fichier sélectionné: ${file.path}');
        print('Taille du fichier: ${fileSize.toStringAsFixed(2)}MB');
        
        selectedFile = file;
        notifyListeners();
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Erreur lors de la sélection du fichier: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
      print('Erreur pickFile: $e');
    }
  }

  Future<void> uploadDocument() async {
    if (!formKey.currentState!.validate()) {
      print('Formulaire invalide');
      return;
    }
    
    if (selectedFile == null) {
      _snackbarService.showSnackbar(
        message: 'Veuillez sélectionner un fichier',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (selectedType == null) {
      _snackbarService.showSnackbar(
        message: 'Veuillez sélectionner un type de document',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (expirationDate == null) {
      _snackbarService.showSnackbar(
        message: 'Veuillez sélectionner une date d\'expiration',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Vérifier si la date d'expiration est dans le futur
    if (expirationDate!.isBefore(DateTime.now())) {
      _snackbarService.showSnackbar(
        message: 'La date d\'expiration doit être dans le futur',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isUploading = true;
      notifyListeners();

      final userId = await _sharedPreferencesService.getUserId();
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      print('=== Paramètres d\'upload ===');
      print('UserId: $userId');
      print('Type: ${selectedType.toString().split('.').last}');
      print('Catégorie: ${_getCategoryForType(selectedType!)}');
      print('Fichier: ${selectedFile!.path}');
      print('Date expiration: ${expirationDate!.toIso8601String()}');

      final success = await _documentService.addDocument(
        userId: userId,
        type: selectedType.toString().split('.').last,
        category: _getCategoryForType(selectedType!),
        file: selectedFile!,
        expirationDate: expirationDate,
      );

      if (success) {
        _snackbarService.showSnackbar(
          message: 'Document enregistré avec succès',
          duration: const Duration(seconds: 3),
        );
        // Réinitialiser les champs
        _resetForm();
        _navigationService.back();
      } else {
        _snackbarService.showSnackbar(
          message: 'Échec de l\'enregistrement du document',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Erreur uploadDocument: $e');
      _snackbarService.showSnackbar(
        message: 'Erreur lors de l\'enregistrement: ${e.toString()}',
        duration: const Duration(seconds: 5),
      );
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  void _resetForm() {
    selectedType = null;
    selectedFile = null;
    descriptionController.clear();
    dateController.clear();
    expirationDate = null;
    notifyListeners();
  }

  String _getCategoryForType(DocumentType type) {
    switch (type) {
      case DocumentType.permisDeConduire:
      case DocumentType.carteIdentite:
        return 'identite';
      case DocumentType.assurance:
      case DocumentType.carteGrise:
        return 'vehicule';
      default:
        return 'autre';
    }
  }

  // Vérifier si le type de document nécessite une date d'expiration
  bool needsExpirationDate() {
    if (selectedType == null) return false;
    
    return selectedType == DocumentType.carteIdentite ||
           selectedType == DocumentType.assurance ||
           selectedType == DocumentType.permisDeConduire ||
           selectedType == DocumentType.carteGrise;
  }

  void navigateBack() {
    _navigationService.back();
  }

  Future<void> selectExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kcPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: kcPrimaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != expirationDate) {
      expirationDate = picked;
      dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }
}