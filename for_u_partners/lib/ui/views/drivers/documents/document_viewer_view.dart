import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/models/document_model.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DocumentViewerView extends StatefulWidget {
  final Document document;
  
  const DocumentViewerView({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  State<DocumentViewerView> createState() => _DocumentViewerViewState();
}

class _DocumentViewerViewState extends State<DocumentViewerView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      );

    // Vérifier si l'URL est une URL valide
    final url = widget.document.fileUrl;
    if (url != null && url.isNotEmpty) {
      if (url.endsWith('.pdf')) {
        // Utiliser Google Docs Viewer pour les PDF
        _controller.loadRequest(
          Uri.parse('https://docs.google.com/gview?embedded=true&url=$url'),
        );
      } else if (url.toLowerCase().endsWith('.jpg') || 
                url.toLowerCase().endsWith('.jpeg') || 
                url.toLowerCase().endsWith('.png')) {
        // Afficher directement les images
        _controller.loadRequest(Uri.parse(url));
      } else {
        // Pour les autres types de fichiers, essayer de les ouvrir dans le navigateur
        _controller.loadRequest(Uri.parse(url));
      }
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _openInBrowser() async {
    final url = widget.document.fileUrl;
    if (url != null && url.isNotEmpty) {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir le document dans le navigateur'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _downloadDocument() async {
    // Implémentez ici la logique de téléchargement si nécessaire
    // Par exemple, vous pouvez utiliser le plugin flutter_downloader
    // ou ouvrir le lien de téléchargement dans le navigateur
    await _openInBrowser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.document.type ?? 'Document',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
            tooltip: 'Ouvrir dans le navigateur',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadDocument,
            tooltip: 'Télécharger',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger le document',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'URL: ${widget.document.fileUrl ?? 'Non disponible'}' ?? 'Non disponible',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeWebView,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kcPrimaryColor),
            ),
          ),
      ],
    );
  }
}

// Classe du ViewModel (peut être utilisée pour une logique plus avancée)
class DocumentViewerViewModel extends BaseViewModel {
  // Vous pouvez ajouter ici la logique métier si nécessaire
}
