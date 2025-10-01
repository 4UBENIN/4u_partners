import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:for_u_partners/app/core/constants.dart';

class PickUpPage extends StatefulWidget {
  const PickUpPage({super.key});

  @override
  State<PickUpPage> createState() => _PickUpPageState();
}

class _PickUpPageState extends State<PickUpPage> {
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _departFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();
  
  String? _departurePlaceId;
  String? _destinationPlaceId;
  double? _departureLat;
  double? _departureLng;
  double? _destinationLat;
  double? _destinationLng;

  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;
  bool _isDepartureField = true;

  bool get _canContinue =>
      _departController.text.isNotEmpty &&
      _destinationController.text.isNotEmpty &&
      _departureLat != null &&
      _destinationLat != null;

  @override
  void initState() {
    super.initState();
    _departController.addListener(_onDepartureChanged);
    _destinationController.addListener(_onDestinationChanged);
    _departFocus.addListener(() {
      if (_departFocus.hasFocus) {
        setState(() => _isDepartureField = true);
      }
    });
    _destinationFocus.addListener(() {
      if (_destinationFocus.hasFocus) {
        setState(() => _isDepartureField = false);
      }
    });
  }

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    _departFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  void _onDepartureChanged() {
    if (_departController.text.isNotEmpty && _departController.text != "Position actuelle") {
      _searchPlaces(_departController.text);
    } else {
      setState(() => _suggestions.clear());
    }
  }

  void _onDestinationChanged() {
    if (_destinationController.text.isNotEmpty) {
      _searchPlaces(_destinationController.text);
    } else {
      setState(() => _suggestions.clear());
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=${AppConstants.mapboxPublicToken}&country=BJ&language=fr&limit=5',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        setState(() {
          _suggestions = features.map((feature) {
            return {
              'place_name': feature['place_name'],
              'coordinates': feature['geometry']['coordinates'],
              'id': feature['id'],
            };
          }).toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectPlace(Map<String, dynamic> place) {
    final coordinates = place['coordinates'] as List;
    final lng = coordinates[0] as double;
    final lat = coordinates[1] as double;
    final placeName = place['place_name'] as String;

    setState(() {
      if (_isDepartureField) {
        _departController.text = placeName;
        _departureLat = lat;
        _departureLng = lng;
        _departurePlaceId = place['id'];
        _departFocus.unfocus();
      } else {
        _destinationController.text = placeName;
        _destinationLat = lat;
        _destinationLng = lng;
        _destinationPlaceId = place['id'];
        _destinationFocus.unfocus();
      }
      _suggestions.clear();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission de localisation refusée'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocoding avec Mapbox
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude},${position.latitude}.json?access_token=${AppConstants.mapboxPublicToken}&language=fr',
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        if (features.isNotEmpty) {
          final placeName = features[0]['place_name'] as String;
          
          setState(() {
            _departController.text = placeName;
            _departureLat = position.latitude;
            _departureLng = position.longitude;
            _departurePlaceId = 'current_location';
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Position actuelle récupérée'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Réserver une course',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      
                      // Formulaire
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            // Champ départ
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _departController,
                                    focusNode: _departFocus,
                                    decoration: InputDecoration(
                                      hintText: 'Votre point de départ',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Champ destination
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextField(
                                    controller: _destinationController,
                                    focusNode: _destinationFocus,
                                    decoration: InputDecoration(
                                      hintText: 'Votre destination',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Position actuelle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: _getCurrentLocation,
                          child: Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Position actuelle',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton continuer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _canContinue
                          ? () {
                              print('Départ: ${_departController.text}');
                              print('Lat: $_departureLat, Lng: $_departureLng');
                              print('Destination: ${_destinationController.text}');
                              print('Lat: $_destinationLat, Lng: $_destinationLng');
                              // Navigation vers la page suivante
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canContinue ? Colors.grey[800] : Colors.grey[300],
                        disabledBackgroundColor: Colors.grey[300],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continuer',
                            style: TextStyle(
                              color: _canContinue ? Colors.white : Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: _canContinue ? Colors.white : Colors.grey[500],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Suggestions
          if (_suggestions.isNotEmpty)
            Positioned(
              top: 160,
              left: 20,
              right: 20,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      leading: Icon(Icons.location_on, color: Colors.blue[700]),
                      title: Text(
                        suggestion['place_name'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: () => _selectPlace(suggestion),
                    );
                  },
                ),
              ),
            ),

          if (_isSearching)
            const Positioned(
              top: 160,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}