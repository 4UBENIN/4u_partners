import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/views/drivers/documents/documents_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked_annotations.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: DocumentsView, initial: true),
  ],
)
class DocumentsView extends StackedView<DocumentsViewModel> {
  const DocumentsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DocumentsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes documents'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text('Gestion des documents'),
      ),
    );
  }

  @override
  DocumentsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DocumentsViewModel();
}
