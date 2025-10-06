import 'package:for_u_partners/ui/views/drivers/documents/documents_view.dart';
import 'package:stacked/stacked.dart';

// documents_viewmodel.dart
class DocumentsViewModel extends BaseViewModel {
  List<DocumentCategory> _categoriesDocuments = [];
  
  List<DocumentCategory> get categoriesDocuments => _categoriesDocuments;

  int get totalDocuments {
    return _categoriesDocuments.fold(
      0,
      (sum, category) => sum + category.documents.length,
    );
  }

  int get documentsValides {
    return _categoriesDocuments.fold(
      0,
      (sum, category) =>
          sum +
          category.documents
              .where((doc) => doc.status == DocumentStatus.valide)
              .length,
    );
  }

  int get documentsExpires {
    return _categoriesDocuments.fold(
      0,
      (sum, category) =>
          sum +
          category.documents
              .where((doc) => doc.status == DocumentStatus.expire)
              .length,
    );
  }

  Future<void> initialise() async {
    setBusy(true);
    // Ici vous appellerez votre API pour récupérer les documents
    // Exemple:
    // _categoriesDocuments = await _apiService.getDocuments();
    
    // Données de test (à remplacer par votre API)
    _categoriesDocuments = [];
    
    setBusy(false);
  }

  Future<void> refreshDocuments() async {
    await initialise();
  }

  void toggleCategory(String categoryId) {
    final index =
        _categoriesDocuments.indexWhere((cat) => cat.id == categoryId);
    if (index != -1) {
      _categoriesDocuments[index].isExpanded =
          !_categoriesDocuments[index].isExpanded;
      notifyListeners();
    }
  }

  void viewDocument(Document doc) {
    print('Voir le document: ${doc.name}');
    // Navigation vers une page de visualisation ou ouverture du document
  }

  void downloadDocument(Document doc) {
    print('Télécharger le document: ${doc.name}');
    // Logique de téléchargement du document
  }

  void deleteDocument(Document doc) {
    print('Supprimer le document: ${doc.name}');
    // Afficher une confirmation puis supprimer via API
  }

  void uploadNewDocument() {
    print('Ajouter un nouveau document');
    // Navigation vers la page d'upload de document
  }

  void showFilterOptions() {
    print('Afficher les options de filtre');
    // Afficher un bottom sheet avec les options de filtre
  }
}