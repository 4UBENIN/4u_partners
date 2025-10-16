import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:for_u_partners/models/document_model.dart';
import 'package:for_u_partners/services/document_service.dart';

class AddDocumentView extends StatefulWidget {
  static const String routeName = '/add_document';
  
  final Document? documentToUpdate;
  final String? categoryId;
  
  const AddDocumentView({
    Key? key,
    this.documentToUpdate,
    this.categoryId,
  }) : super(key: key);

  @override
  _AddDocumentViewState createState() => _AddDocumentViewState();
}

class _AddDocumentViewState extends State<AddDocumentView> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _dateExpirationController = TextEditingController();
  final DocumentService _documentService = DocumentService();
  
  XFile? _documentFile;
  bool _isLoading = false;
  
  final List<String> _documentTypes = [
    'Permis de conduire',
    'Carte d\'identité',
    'Assurance',
    'Autre document'
  ];

  @override
  void dispose() {
    _typeController.dispose();
    _dateExpirationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF184E9C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dateExpirationController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickDocument() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      
      if (file != null) {
        // Vérification de la taille du fichier (max 5 MB)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          if (mounted) {
            _showErrorSnackBar('Le fichier est trop volumineux (max 5 MB)');
          }
          return;
        }
        
        // Vérification du type de fichier
        final extension = file.name.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'pdf'].contains(extension)) {
          if (mounted) {
            _showErrorSnackBar('Format de fichier non supporté. Utilisez JPG, PNG ou PDF.');
          }
          return;
        }
        
        setState(() {
          _documentFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la sélection du fichier: ${e.toString()}');
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Veuillez corriger les erreurs dans le formulaire');
      return;
    }

    if (_documentFile == null) {
      _showErrorSnackBar('Veuillez sélectionner un document');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Télécharger le fichier
      final fileUrl = await _documentService.uploadDocument(_documentFile!);
      
      // 2. Parser la date d'expiration
      final dateFormat = DateFormat('dd/MM/yyyy');
      final expirationDate = dateFormat.parse(_dateExpirationController.text);
      
      // 3. Créer le document dans la base de données
      await _documentService.createDocument(
        type: _typeController.text,
        fileUrl: fileUrl,
        expirationDate: expirationDate,
      );
      
      // 4. Afficher un message de succès et revenir en arrière
      if (mounted) {
        _showSuccessSnackBar('Document ajouté avec succès');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de l\'enregistrement du document: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
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

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un document'),
        backgroundColor: const Color(0xFF184E9C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type de document
              const Text(
                'Type de document *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _typeController.text.isEmpty ? null : _typeController.text,
                decoration: _buildInputDecoration(
                  'Sélectionnez un type de document',
                  Icons.description,
                ),
                items: _documentTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _typeController.text = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un type de document';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Date d'expiration
              const Text(
                'Date d\'expiration *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateExpirationController,
                readOnly: true,
                decoration: _buildInputDecoration(
                  'Sélectionnez une date',
                  Icons.calendar_today,
                  onTap: () => _selectDate(context),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une date d\'expiration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Fichier du document
              const Text(
                'Document *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              _buildFileUpload(
                'Sélectionner un fichier',
                _documentFile,
                _pickDocument,
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
              const SizedBox(height: 32),

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
                    const Expanded(
                      child: Text(
                        'Tous les champs marqués d\'un * sont obligatoires',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF184E9C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Enregistrer le document',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.upload_file,
              color: file == null ? Colors.grey[500] : const Color(0xFF184E9C),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file?.name ?? label,
                    style: TextStyle(
                      color: file == null ? Colors.grey[600] : Colors.black87,
                      fontSize: 14,
                      fontWeight: file == null ? FontWeight.normal : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (file != null) ...[
                    const SizedBox(height: 4),
                    FutureBuilder<int>(
                      future: file.length(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final sizeInKb = (snapshot.data! / 1024);
                          return Text(
                            '${sizeInKb.toStringAsFixed(1)} KB',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ],
              ),
            ),
            if (file != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _documentFile = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: const Color(0xFF666666), size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
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
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      errorMaxLines: 2,
      suffixIcon: onTap != null
          ? IconButton(
              icon: const Icon(Icons.calendar_today, size: 20, color: Color(0xFF666666)),
              onPressed: onTap,
            )
          : null,
    );
  }
}