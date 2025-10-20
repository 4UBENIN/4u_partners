// add_document.dart
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/enums/document_type.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

import 'add_document_viewmodel.dart';

class AddDocumentView extends StatelessWidget {
  const AddDocumentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddDocumentViewModel>.reactive(
      viewModelBuilder: () => AddDocumentViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Ajouter un document'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => model.navigateBack(),
          ),
        ),
        body: model.isBusy
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: model.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<DocumentType>(
                        value: model.selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type de document',
                          border: OutlineInputBorder(),
                        ),
                        items: DocumentType.values.map((type) {
                          return DropdownMenuItem<DocumentType>(
                            value: type,
                            child: Text(_getDocumentTypeName(type)),
                          );
                        }).toList(),
                        onChanged: model.updateSelectedType,
                        validator: (value) =>
                            value == null ? 'Veuillez sélectionner un type' : null,
                      ),
                      verticalSpaceMedium,
                      
                      // Afficher la date d'expiration UNIQUEMENT si le type le nécessite
                      if (model.needsExpirationDate()) ...[
                        TextFormField(
                          controller: model.dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Date d\'expiration *',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today, color: kcPrimaryColor),
                              onPressed: () => model.selectExpirationDate(context),
                            ),
                          ),
                          validator: (value) {
                            if (model.needsExpirationDate() && (value == null || value.isEmpty)) {
                              return 'Veuillez sélectionner une date d\'expiration';
                            }
                            return null;
                          },
                        ),
                        verticalSpaceMedium,
                      ],
                      
                      verticalSpaceLarge,
                      _buildFilePicker(model),
                      verticalSpaceLarge,
                      verticalSpaceLarge,
                      ElevatedButton(
                        onPressed: (model.isUploading || model.selectedFile == null) 
                            ? null 
                            : model.uploadDocument,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kcPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: model.isUploading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  horizontalSpaceSmall,
                                  Text('Téléversement en cours...'),
                                ],
                              )
                            : const Text(
                                'Enregistrer le document',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFilePicker(AddDocumentViewModel model) {
    final List<Widget> children = [
      const Text(
        'Document *',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      verticalSpaceSmall,
      InkWell(
        onTap: model.pickFile,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: model.selectedFile == null ? Colors.grey : Colors.green,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              Icon(
                model.selectedFile == null 
                    ? Icons.cloud_upload 
                    : Icons.check_circle,
                size: 40,
                color: model.selectedFile == null ? kcPrimaryColor : Colors.green,
              ),
              verticalSpaceSmall,
              Text(
                model.selectedFile == null
                    ? 'Glissez-déposez votre fichier ici ou cliquez pour sélectionner'
                    : 'Fichier sélectionné',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (model.selectedFile == null) ...[
                verticalSpaceTiny,
                const Text(
                  'Formats acceptés: PDF, JPG, PNG (max 5MB)',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ] else ...[
                verticalSpaceTiny,
                Text(
                  model.selectedFile!.path.split('/').last,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    ];

    if (model.selectedFile == null) {
      children.addAll([
        verticalSpaceTiny,
        const Text(
          'Veuillez sélectionner un fichier',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  String _getDocumentTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.permisDeConduire:
        return 'Permis de conduire';
      case DocumentType.carteIdentite:
        return 'Carte d\'identité';
      case DocumentType.assurance:
        return 'Attestation d\'assurance';
      case DocumentType.carteGrise:
        return 'Carte grise';
      default:
        return type.toString().split('.').last;
    }
  }
}