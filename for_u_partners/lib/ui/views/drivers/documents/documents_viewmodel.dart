import 'package:for_u_partners/models/document_model.dart';
import 'package:for_u_partners/services/document_service.dart';
import 'package:for_u_partners/ui/views/drivers/documents/add_document.dart';
import 'package:for_u_partners/ui/views/drivers/documents/view_documents.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:flutter/material.dart';

class DocumentsViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final DocumentService _documentService = DocumentService();
  final DialogService _dialogService = locator<DialogService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  
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
              .where((doc) => doc.status == 'approuve')
              .length,
    );
  }

  int get documentsExpires {
    return _categoriesDocuments.fold(
      0,
      (sum, category) =>
          sum +
          category.documents
              .where((doc) => doc.status == 'expire')
              .length,
    );
  }

  int get documentsEnAttente {
    return _categoriesDocuments.fold(
      0,
      (sum, category) =>
          sum +
          category.documents
              .where((doc) => doc.status == 'enAttente')
              .length,
    );
  }

  Future<void> initialise() async {
    setBusy(true);
    try {
      await fetchDocuments();
    } catch (e) {
      _showErrorSnackbar('Erreur lors du chargement des documents');
      print('Erreur initialisation: $e');
    } finally {
      setBusy(false);
    }
  }
  // recuperer les documents de la base de données
  Future<void> fetchDocuments() async {
    try {
      final documents = await _documentService.getDriverDocuments();
      
      
      final defaultCategory = DocumentCategory( 
        id: 'default',
        name: 'Documents',
        iconPath: 'assets/app_icon.png', 
        documents: documents,
      );
      
      _categoriesDocuments = [defaultCategory];
      notifyListeners();
    } catch (e) {
      print('Erreur fetchDocuments: $e');
      rethrow;
    }
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

  /// Voir le document téléchargé
  Future<void> viewDocument(Document doc) async {
    try {
      await _navigationService.navigateToView(
        ViewDocumentView(document: doc),
      );
    } catch (e) {
      _showErrorSnackbar('Impossible d\'ouvrir le document');
      print('Erreur viewDocument: $e');
    }
  }

  /// Modifier un document (si expiré ou invalide)
  Future<void> modifyDocument(Document doc) async {
    try {
      // Vérifier si le document peut être modifié
      if (doc.status == DocumentStatus.valide) {
        final response = await _dialogService.showConfirmationDialog(
          title: 'Document valide',
          description: 'Ce document est encore valide. Voulez-vous vraiment le remplacer ?',
          confirmationTitle: 'Remplacer',
          cancelTitle: 'Annuler',
        );
        
        if (response?.confirmed != true) return;
      }

      final result = await _navigationService.navigateToView(
        AddDocumentView(
          documentToUpdate: doc,
          categoryId: _getCategoryIdForDocument(doc),
        ),
      );
      
      if (result == true) {
        await fetchDocuments();
        _showSuccessSnackbar('Document modifié avec succès');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la modification du document');
      print('Erreur modifyDocument: $e');
    }
  }

  /// Télécharger le document sur l'appareil
  Future<void> downloadDocument(Document doc) async {
    try {
      setBusy(true);
      final success = await _documentService.downloadDocument(doc);
      
      if (success) {
        _showSuccessSnackbar('Document téléchargé avec succès');
      } else {
        _showErrorSnackbar('Échec du téléchargement');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur lors du téléchargement');
      print('Erreur downloadDocument: $e');
    } finally {
      setBusy(false);
    }
  }

  /// Supprimer un document
  Future<void> deleteDocument(Document doc) async {
    try {
      final response = await _dialogService.showConfirmationDialog(
        title: 'Supprimer le document',
        description: 'Êtes-vous sûr de vouloir supprimer "${doc.type}" ? Cette action est irréversible.',
        confirmationTitle: 'Supprimer',
        cancelTitle: 'Annuler',
        dialogPlatform: DialogPlatform.Material,
      );

      if (response?.confirmed == true) {
        setBusy(true);
        final success = await _documentService.deleteDocument(doc.id);
        
        if (success) {
          await fetchDocuments();
          _showSuccessSnackbar('Document supprimé avec succès');
        } else {
          _showErrorSnackbar('Échec de la suppression');
        }
      }
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la suppression');
      print('Erreur deleteDocument: $e');
    } finally {
      setBusy(false);
    }
  }

  /// Uploader un nouveau document
  Future<void> uploadNewDocument({String? categoryId}) async {
    try {
      final result = await _navigationService.navigateToView(
        AddDocumentView(categoryId: categoryId),
      );
      
      if (result == true) {
        await fetchDocuments();
        _showSuccessSnackbar('Document ajouté avec succès');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur lors de l\'ajout du document');
      print('Erreur uploadNewDocument: $e');
    }
  }

  /// Afficher les actions disponibles pour un document
  Future<void> showDocumentActions(Document doc, BuildContext context) async {
    final actions = _getAvailableActions(doc);
    
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              doc.type,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...actions.map((action) => _buildActionTile(
              context,
              action,
              doc,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, DocumentAction action, Document doc) {
    return ListTile(
      leading: Icon(action.icon, color: action.color),
      title: Text(action.title),
      subtitle: action.subtitle != null ? Text(action.subtitle!) : null,
      onTap: () {
        Navigator.pop(context);
        action.onTap(doc);
      },
    );
  }

  List<DocumentAction> _getAvailableActions(Document doc) {
    final actions = <DocumentAction>[];

    // Action: Voir le document
    actions.add(DocumentAction(
      title: 'Voir le document',
      icon: Icons.visibility,
      color: Colors.blue,
      onTap: viewDocument,
    ));

    // Action: Modifier (si expiré, en attente ou rejeté)
    final isExpired = doc.expirationDate.isBefore(DateTime.now());
    if (isExpired || 
        doc.status == DocumentStatus.enAttente ||
        doc.status == DocumentStatus.rejete) {
      actions.add(DocumentAction(
        title: 'Modifier le document',
        subtitle: isExpired
            ? 'Document expiré - mise à jour nécessaire'
            : 'Remplacer le document',
        icon: Icons.edit,
        color: Colors.orange,
        onTap: modifyDocument,
      ));
    }

    // Action: Télécharger
    actions.add(DocumentAction(
      title: 'Télécharger',
      icon: Icons.download,
      color: Colors.green,
      onTap: downloadDocument,
    ));

    // Action: Supprimer
    actions.add(DocumentAction(
      title: 'Supprimer',
      icon: Icons.delete,
      color: Colors.red,
      onTap: deleteDocument,
    ));

    return actions;
  }

  String _getCategoryIdForDocument(Document doc) {
    for (var category in _categoriesDocuments) {
      if (category.documents.any((d) => d.id == doc.id)) {
        return category.id;
      }
    }
    return '';
  }

  void showFilterOptions() {
    print('Afficher les options de filtre');
    // Vous pouvez implémenter un bottom sheet avec filtres ici
  }

  void _showSuccessSnackbar(String message) {
    try {
      _snackbarService.showSnackbar(
        message: message,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Snackbar error: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    try {
      _snackbarService.showSnackbar(
        message: message,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Snackbar error: $e');
    }
  }
}

/// Classe pour définir une action sur un document
class DocumentAction {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Function(Document) onTap;

  DocumentAction({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}