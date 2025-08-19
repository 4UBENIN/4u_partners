import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/course_model.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/ui/views/drivers/courses/courses_viewmodel.dart';
import 'package:intl/intl.dart';

class RecapitulatifCoursePage extends StatefulWidget {
  final int courseId;
  final VoidCallback onSoumettre;
  final CoursesViewModel viewModel;

  const RecapitulatifCoursePage({
    Key? key,
    required this.courseId,
    required this.onSoumettre,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<RecapitulatifCoursePage> createState() =>
      _RecapitulatifCoursePageState();
}

class _RecapitulatifCoursePageState extends State<RecapitulatifCoursePage> {
  final DriverService _driverService = DriverService();
  late Future<FactureCourse> _factureFuture;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _factureFuture = _initializeData();
  }

  // Méthode corrigée : on attend que completeCourseService se termine avant de fetch la facture
  Future<FactureCourse> _initializeData() async {
    try {
      // D'abord on complète le service de course
      await widget.viewModel.completeCourseService(widget.courseId, context);

      // Ensuite on récupère la facture
      return await _driverService.fetchFactureCourse(widget.courseId);
    } catch (e) {
      // Gestion d'erreur améliorée
      print('Erreur lors de l\'initialisation: $e');
      rethrow; // On relance l'erreur pour que le FutureBuilder puisse la capturer
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Récapitulatif de course',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<FactureCourse>(
        future: _factureFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Finalisation de la course...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _factureFuture = _initializeData();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Aucune donnée disponible',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final facture = snapshot.data!;
          final client = facture.client;
          final nomClient =
              '${client['prenom'] ?? ''} ${client['nom'] ?? ''}'.trim();
          final initialeClient =
              nomClient.isNotEmpty ? nomClient[0].toUpperCase() : 'C';

          return Column(
            children: [
              // En-tête avec les informations principales
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Badge de statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Course terminée',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Montant total
                    Text(
                      '${facture.montant} FCFA',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Payé par ${facture.modePaiement}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Itinéraire
                      _buildSection(
                        context,
                        title: 'Itinéraire',
                        icon: Icons.route,
                        children: [
                          _buildLocationRow(
                              Icons.location_on, facture.adresseDepart, true),
                          const SizedBox(height: 12),
                          _buildLocationRow(
                              Icons.location_on, facture.adresseArrivee, false),
                          const SizedBox(height: 8),
                          _buildDistanceInfo(facture.distanceKm),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section Client
                      _buildSection(
                        context,
                        title: 'Client',
                        icon: Icons.person_outline,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: primaryColor,
                                radius: 24,
                                child: Text(
                                  initialeClient,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                nomClient.isNotEmpty ? nomClient : 'Client',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section Détails de la facture
                      _buildSection(
                        context,
                        title: 'Détails de la facture',
                        icon: Icons.receipt_long,
                        children: [
                          _buildInvoiceRow(
                              'N° Facture', 'FAC-${facture.courseId}'),
                          _buildInvoiceRow(
                              'Date', _dateFormat.format(DateTime.now())),
                          const Divider(height: 32),
                          _buildInvoiceRow(
                            'Distance (${facture.distanceKm.toStringAsFixed(1)} km)',
                            '${facture.tarifParKm} FCFA/km',
                          ),
                          const SizedBox(height: 8),
                          _buildInvoiceRow(
                            'Temps estimé',
                            '${facture.tarifParMinute} FCFA/min',
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total à payer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                '${facture.montant} FCFA',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton de soumission
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onSoumettre,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retour à l\'accueil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text, bool isPickup) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Icon(
            icon,
            color: isPickup ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceInfo(double distance) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distance parcourue',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${distance.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
