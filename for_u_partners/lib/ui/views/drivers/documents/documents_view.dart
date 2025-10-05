// documents_view.dart
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/documents/documents_viewmodel.dart';
import 'package:stacked/stacked.dart';

class DocumentsView extends StackedView<DocumentsViewModel> {
  const DocumentsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DocumentsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mes Documents',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: viewModel.showFilterOptions,
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(
              child: CircularProgressIndicator(color: kcPrimaryColor))
          : RefreshIndicator(
              color: kcPrimaryColor,
              onRefresh: viewModel.refreshDocuments,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header avec image
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kcPrimaryColor, Color(0xFF0D47A1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -10,
                            child: Icon(
                              Icons.description_rounded,
                              size: 140,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Mes Documents',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Gérez vos documents administratifs et justificatifs.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Statistiques des documents
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total',
                              '${viewModel.totalDocuments}',
                              Icons.description,
                              const Color(0xFF00A651),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Validés',
                              '${viewModel.documentsValides}',
                              Icons.check_circle,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Expirés',
                              '${viewModel.documentsExpires}',
                              Icons.warning,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Liste des catégories de documents
                    ...viewModel.categoriesDocuments.map((category) {
                      return _buildCategorySection(
                        context,
                        viewModel,
                        category,
                      );
                    }).toList(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          onPressed: viewModel.uploadNewDocument,
          icon: const Icon(Icons.upload_file),
          label: const Text(
            'Ajouter un document',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kcPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    DocumentsViewModel viewModel,
    DocumentCategory category,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kcPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category.icon,
                      color: kcPrimaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${category.documents.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  category.isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () => viewModel.toggleCategory(category.id),
              ),
            ],
          ),
          if (category.isExpanded) ...[
            const SizedBox(height: 12),
            if (category.documents.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.folder_open,
                          size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text(
                        'Aucun document dans cette catégorie',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...category.documents.map((doc) {
                return _buildDocumentCard(context, viewModel, doc);
              }).toList(),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    DocumentsViewModel viewModel,
    Document doc,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (doc.status) {
      case DocumentStatus.valide:
        statusColor = kcPrimaryColor;
        statusIcon = Icons.check_circle;
        statusText = 'Validé';
        break;
      case DocumentStatus.enAttente:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'En attente';
        break;
      case DocumentStatus.rejete:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rejeté';
        break;
      case DocumentStatus.expire:
        statusColor = Colors.red[700]!;
        statusIcon = Icons.warning;
        statusText = 'Expiré';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => viewModel.viewDocument(doc),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getFileIcon(doc.fileType),
                            color: kcPrimaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doc.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Ajouté le ${doc.dateAjout}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (doc.dateExpiration != null)
                      Row(
                        children: [
                          Icon(Icons.event_busy,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Expire le ${doc.dateExpiration}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (doc.status == DocumentStatus.rejete &&
                    doc.motifRejet != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            doc.motifRejet!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => viewModel.downloadDocument(doc),
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Télécharger'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00A651),
                          side: const BorderSide(color: Color(0xFF00A651)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => viewModel.deleteDocument(doc),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Supprimer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  DocumentsViewModel viewModelBuilder(BuildContext context) =>
      DocumentsViewModel();

  @override
  void onViewModelReady(DocumentsViewModel viewModel) {
    viewModel.initialise();
  }
}


// document_category_model.dart
class DocumentCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<Document> documents;
  bool isExpanded;

  DocumentCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.documents,
    this.isExpanded = true,
  });
}

// document_model.dart
enum DocumentStatus {
  valide,
  enAttente,
  rejete,
  expire,
}

class Document {
  final String id;
  final String name;
  final String description;
  final String fileType;
  final String fileUrl;
  final DocumentStatus status;
  final String dateAjout;
  final String? dateExpiration;
  final String? motifRejet;

  Document({
    required this.id,
    required this.name,
    required this.description,
    required this.fileType,
    required this.fileUrl,
    required this.status,
    required this.dateAjout,
    this.dateExpiration,
    this.motifRejet,
  });
}