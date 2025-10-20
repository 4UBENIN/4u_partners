// documents_viewmodel.dart
import 'package:for_u_partners/ui/views/drivers/documents/add_document.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/models/document_model.dart';
import 'package:for_u_partners/services/document_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';

class DocumentsViewModel extends BaseViewModel {
  final _documentService = DocumentService();
  final _navigationService = NavigationService();
  final _dialogService = DialogService();
  final _snackbarService = SnackbarService();
  final _sharedPreferencesService = locator<SharedpreferencesService>();

  List<DocumentCategory> _documentCategories = [];
  List<DocumentCategory> get documentCategories => _documentCategories;

  int get pendingCount => _getAllDocuments()
      .where((doc) => doc.status == DocumentStatus.enAttente)
      .length;

  int get approvedCount => _getAllDocuments()
      .where((doc) => doc.status == DocumentStatus.approuve)
      .length;

  int get rejectedCount => _getAllDocuments()
      .where((doc) => doc.status == DocumentStatus.rejete)
      .length;

  List<Document> _getAllDocuments() {
    return _documentCategories
        .expand((category) => category.documents)
        .toList();
  }

  // Initialisation et récupération des documents
  Future<void> initialise() async {
    await fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      setBusy(true);
      
      // Récupérer l'ID de l'utilisateur connecté
      final userId = await _sharedPreferencesService.getUserId();
      
      if (userId == null || userId.isEmpty) {
        _snackbarService.showSnackbar(
          message: 'Utilisateur non connecté',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Récupérer les documents de l'utilisateur depuis la base de données
      final documents = await _documentService.getUserDocuments(userId);
      
      // Organiser les documents par catégorie
      _documentCategories = _organizeDocumentsByCategory(documents);
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la récupération des documents: $e');
      _snackbarService.showSnackbar(
        message: 'Erreur lors du chargement des documents',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  // Organiser les documents par catégorie
  List<DocumentCategory> _organizeDocumentsByCategory(List<Document> documents) {
    final Map<String, List<Document>> categorizedDocs = {};

    // Grouper les documents par catégorie
    for (var doc in documents) {
      final categoryName = doc.category ?? 'Autres';
      if (!categorizedDocs.containsKey(categoryName)) {
        categorizedDocs[categoryName] = [];
      }
      categorizedDocs[categoryName]!.add(doc);
    }

    // Convertir en liste de DocumentCategory
    return categorizedDocs.entries.map((entry) {
      return DocumentCategory(
        name: entry.key,
        documents: entry.value,
        iconPath: _getCategoryIconPath(entry.key),
      );
    }).toList();
  }

  String _getCategoryIconPath(String categoryName) {
    // Retourner le chemin de l'icône selon la catégorie
    switch (categoryName.toLowerCase()) {
      case 'permis':
        return 'assets/icons/license.png';
      case 'assurance':
        return 'assets/icons/insurance.png';
      case 'carte grise':
        return 'assets/icons/registration.png';
      case 'identité':
        return 'assets/icons/identity.png';
      default:
        return 'assets/icons/document.png';
    }
  }

  // Rafraîchir les documents
  Future<void> refreshDocuments() async {
    await fetchDocuments();
  }

  // Voir un document
  Future<void> viewDocument(Document doc) async {
    try {
      if (doc.fileUrl == null || doc.fileUrl!.isEmpty) {
        _snackbarService.showSnackbar(
          message: 'Aucun fichier disponible',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Naviguer vers la page de visualisation du document
      await _navigationService.navigateTo(
        '/document-viewer',
        arguments: doc,
      );
    } catch (e) {
      print('Erreur lors de la visualisation: $e');
      _snackbarService.showSnackbar(
        message: 'Impossible d\'ouvrir le document',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Modifier un document
  Future<void> modifyDocument(Document doc) async {
    await _navigationService.navigateTo(
      '/document-update',
      arguments: doc,
    );
  }

  // Télécharger un document
  Future<void> downloadDocument(Document doc) async {
    try {
      setBusy(true);
      
      final success = await _documentService.downloadDocument(doc);
      
      if (success) {
        _snackbarService.showSnackbar(
          message: 'Document téléchargé avec succès',
          duration: const Duration(seconds: 2),
        );
      } else {
        _snackbarService.showSnackbar(
          message: 'Échec du téléchargement',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Erreur lors du téléchargement: $e');
      _snackbarService.showSnackbar(
        message: 'Erreur lors du téléchargement',
        duration: const Duration(seconds: 2),
      );
    } finally {
    }
  }

  // Supprimer un document
  Future<void> deleteDocument(Document doc) async {
    // Afficher une boîte de dialogue de confirmation
    final response = await _dialogService.showConfirmationDialog(
      title: 'Supprimer le document',
      description: 'Êtes-vous sûr de vouloir supprimer ce document ?',
      confirmationTitle: 'Supprimer',
      cancelTitle: 'Annuler',
    );

    if (response?.confirmed == true) {
      try {
        if (doc.id == null) {
          _snackbarService.showSnackbar(
            message: 'Erreur: ID du document manquant',
            duration: const Duration(seconds: 2),
          );
          return;
        }

        setBusy(true);
        
        final success = await _documentService.deleteDocument(doc.id!);
        
        if (success) {
          _snackbarService.showSnackbar(
            message: 'Document supprimé avec succès',
            duration: const Duration(seconds: 2),
          );
          
          // Rafraîchir la liste
          await fetchDocuments();
        } else {
          _snackbarService.showSnackbar(
            message: 'Échec de la suppression',
            duration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        print('Erreur lors de la suppression: $e');
        _snackbarService.showSnackbar(
          message: 'Erreur lors de la suppression',
          duration: const Duration(seconds: 2),
        );
      } finally {
        setBusy(false);
      }
    }
  }

  // Ajouter un nouveau document
  Future<void> uploadNewDocument() async {
    await _navigationService.navigateToView(const AddDocumentView());
    
    // Rafraîchir après l'ajout
    await fetchDocuments();
  }

  // Afficher les options de filtrage
  Future<void> showFilterOptions() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.filterDocuments,
      title: 'Filtrer les documents',
    );

    if (response?.confirmed == true) {
      // Appliquer les filtres
      await fetchDocuments();
    }
  }
}

// Enum pour les types de dialogue
enum DialogType {
  filterDocuments,
}