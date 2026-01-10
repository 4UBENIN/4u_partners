import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'rate_client_viewmodel.dart';

class RateClientView extends StackedView<RateClientViewModel> {
  final int courseId;
  final int clientId;
  final String clientName;

  const RateClientView({
    Key? key,
    required this.courseId,
    required this.clientId,
    required this.clientName,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RateClientViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        title: const Text(
          'Noter le client',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: viewModel.skipRating,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Client avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: kcPrimaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          clientName.isNotEmpty
                              ? clientName[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: kcPrimaryColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Client name
                    Text(
                      clientName.isNotEmpty ? clientName : 'Client',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Instruction text
                    Text(
                      'Comment s\'est passée cette course ?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Star rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return GestureDetector(
                          onTap: () => viewModel.setRating(starValue),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              viewModel.selectedRating >= starValue
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 48,
                              color: viewModel.selectedRating >= starValue
                                  ? Colors.amber
                                  : Colors.grey[400],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Rating description
                    if (viewModel.selectedRating > 0)
                      Text(
                        _getRatingDescription(viewModel.selectedRating),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _getRatingColor(viewModel.selectedRating),
                        ),
                      ),

                    const SizedBox(height: 40),

                    // Comment section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Commentaire (optionnel)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: viewModel.commentController,
                            maxLines: 4,
                            maxLength: 500,
                            decoration: InputDecoration(
                              hintText: 'Partagez votre expérience...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.isBusy || !viewModel.canSubmit
                          ? null
                          : () => viewModel.submitRating(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: viewModel.isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Soumettre',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Skip button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: viewModel.isBusy ? null : viewModel.skipRating,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Retour à l\'accueil',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  RateClientViewModel viewModelBuilder(BuildContext context) {
    return RateClientViewModel(
      courseId: courseId,
      clientId: clientId,
      clientName: clientName,
    );
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Très mauvais';
      case 2:
        return 'Mauvais';
      case 3:
        return 'Moyen';
      case 4:
        return 'Bien';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  Color _getRatingColor(int rating) {
    if (rating <= 2) {
      return Colors.red;
    } else if (rating == 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
