import 'package:flutter/material.dart';
import 'package:for_u_partners/models/document_model.dart';

class ViewDocumentView extends StatelessWidget {
  final Document document;

  const ViewDocumentView({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.type!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 100, color: Colors.blueGrey),
            const SizedBox(height: 20),
            Text(
              document.type!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('Statut : ${document.status}'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ouvrir le document'),
              onPressed: () {
                // Ici tu peux ouvrir un PDF, une image ou autre
              },
            ),
          ],
        ),
      ),
    );
  }
}
