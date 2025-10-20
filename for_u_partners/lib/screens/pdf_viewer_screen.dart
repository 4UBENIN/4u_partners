import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    Key? key,
    required this.pdfUrl,
    required this.title,
  }) : super(key: key);

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
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
      )
      ..loadRequest(
        Uri.parse(
          widget.pdfUrl.startsWith('http')
              ? widget.pdfUrl
              : 'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.pdfUrl)}',
        ),
      );
  }

  Future<void> _openInBrowser() async {
    final url = Uri.parse(widget.pdfUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le PDF dans le navigateur'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
            tooltip: 'Ouvrir dans le navigateur',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_hasError)
            Center(
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
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeWebView,
                    child: const Text('Réessayer'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _openInBrowser,
                    child: const Text('Ouvrir dans le navigateur'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Fonction utilitaire pour ouvrir un PDF
Future<void> showPdfViewer({
  required BuildContext context,
  required String pdfUrl,
  required String title,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PdfViewerScreen(
        pdfUrl: pdfUrl,
        title: title,
      ),
    ),
  );
}
