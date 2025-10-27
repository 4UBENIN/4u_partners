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
  String? dateError;
  bool _showSuccessMessage = false;

  bool get showSuccessMessage => _showSuccessMessage;

  void resetSuccessMessage() {
    _showSuccessMessage = false;
    notifyListeners();
  }

  void _setSuccessMessage() {
    _showSuccessMessage = true;
    notifyListeners();
  }

  void updateSelectedType(DocumentType? type) {
    selectedType = type;
    notifyListeners();
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: true,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        final fileSize = await file.length() / 1024 / 1024;
        if (fileSize > 5) {
          _snackbarService.showSnackbar(
            message: 'Le fichier est trop volumineux (max 5MB). Taille: ${fileSize.toStringAsFixed(2)}MB',
            duration: const Duration(seconds: 3),
          );
          return;
        }
        
        selectedFile = file;
        notifyListeners();
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Erreur lors de la sélection du fichier: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
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

    if (expirationDate!.isBefore(DateTime.now())) {
      _snackbarService.showSnackbar(
        message: 'La date d\'expiration doit être dans le futur',
        duration: const Duration(seconds: 3),
      );
      dateError = 'La date ne peut pas être dans le passé';
      notifyListeners();
      return;
    }

    try {
      isUploading = true;
      notifyListeners();

      final userId = await _sharedPreferencesService.getUserId();
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final success = await _documentService.addDocument(
        userId: userId,
        type: selectedType.toString().split('.').last,
        category: _getCategoryForType(selectedType!),
        file: selectedFile!,
        expirationDate: expirationDate,
      );

      if (success) {
        _setSuccessMessage();
        _resetForm();
      } else {
        _snackbarService.showSnackbar(
          message: 'Échec de l\'enregistrement du document',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
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
    dateError = null;
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
    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: today.add(const Duration(days: 1)),
        firstDate: today,
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

      if (picked != null) {
        if (picked.isBefore(today)) {
          dateError = 'Vous ne pouvez pas choisir une date passée.';
          _snackbarService.showSnackbar(
            message: dateError!,
            duration: const Duration(seconds: 3),
          );
          notifyListeners();
          return;
        }

        expirationDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        dateError = null; // On enlève le message d’erreur si tout va bien
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de la sélection de la date: $e');
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }
}
