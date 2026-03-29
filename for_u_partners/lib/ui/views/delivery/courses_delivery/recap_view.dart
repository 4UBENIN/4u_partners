import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';

class DeliveryRecapitulatifCoursePage extends StatelessWidget {
  final String demandType;
  final String pointDepart;
  final String destination;
  final String nomClient;
  final String type;
  final String initialeClient;
  final List<String> vetements;
  final VoidCallback onSoumettre;

  const DeliveryRecapitulatifCoursePage({
    Key? key,
    required this.demandType,
    required this.pointDepart,
    required this.destination,
    required this.nomClient,
    required this.initialeClient,
    required this.onSoumettre,
    required this.vetements,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Récapitulatif',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail de la demande :  $demandType',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Section trajet
                  Column(
                    children: [
                      const Text(
                        'Point de départ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        pointDepart,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Destination',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Section client
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            initialeClient,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        nomClient,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 30),

                  // // Section distance et prix
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Column(
                  //         children: [
                  //           Row(
                  //             children: [
                  //               Icon(
                  //                 Icons.map_outlined,
                  //                 color: Colors.grey[600],
                  //                 size: 20,
                  //               ),
                  //               const SizedBox(width: 8),
                  //               const Text(
                  //                 'Distance',
                  //                 style: TextStyle(
                  //                   color: Colors.grey,
                  //                   fontSize: 14,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //           const SizedBox(height: 5),
                  //           Text(
                  //             '${distance.toStringAsFixed(0)} Km',
                  //             style: const TextStyle(
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.bold,
                  //               color: Colors.black,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Column(
                  //         children: [
                  //           Row(
                  //             children: [
                  //               Icon(
                  //                 Icons.local_offer_outlined,
                  //                 color: Colors.grey[600],
                  //                 size: 20,
                  //               ),
                  //               const SizedBox(width: 8),
                  //               const Text(
                  //                 'Prix',
                  //                 style: TextStyle(
                  //                   color: Colors.grey,
                  //                   fontSize: 14,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //           const SizedBox(height: 5),
                  //           Text(
                  //             '$prix fcfa',
                  //             style: const TextStyle(
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.bold,
                  //               color: Colors.black,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 30),

                  // Section moyen de paiement
                  // const Text(
                  //   'Moyen de paiement',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w500,
                  //     color: Colors.black,
                  //   ),
                  // ),
                  // const SizedBox(height: 15),
                  // Row(
                  //   children: [
                  //     Radio<String>(
                  //       value: 'Portefeuille',
                  //       groupValue: moyenPaiement,
                  //       onChanged: null,
                  //       activeColor: Colors.grey,
                  //     ),
                  //     const Text(
                  //       'Portefeuille',
                  //       style: TextStyle(
                  //         color: Colors.grey,
                  //         fontSize: 14,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Row(
                  //   children: [
                  //     Radio<String>(
                  //       value: 'Espèces',
                  //       groupValue: moyenPaiement,
                  //       onChanged: null,
                  //       activeColor: Colors.grey[800],
                  //     ),
                  //     const Text(
                  //       'Espèces',
                  //       style: TextStyle(
                  //         color: Colors.black,
                  //         fontSize: 14,
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // const SizedBox(height: 30),

                  // Section détail du récapitulatif
                  if (type == "Ramassage") ...{
                    const Text(
                      'Détails du récapitulatif',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    //Vetements
                    const Text(
                      'Vetements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < vetements.length; i++) ...{
                            Text(
                              vetements[i],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                          }
                        ],
                      ),
                    ),
                    // ignore: equal_elements_in_set
                    const SizedBox(height: 20),

                    // Poids
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Poids',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '1kg',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  } else
                    ...{}
                  // const SizedBox(height: 15),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text(
                  //       'Coût de la distance',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         color: Colors.black,
                  //       ),
                  //     ),
                  //     Text(
                  //       '${coutDistance.toStringAsFixed(0)} Fcfa',
                  //       style: const TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w500,
                  //         color: Colors.black,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),

          // Bouton Soumettre
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            child: ElevatedButton(
              onPressed: onSoumettre,
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Soumettre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
