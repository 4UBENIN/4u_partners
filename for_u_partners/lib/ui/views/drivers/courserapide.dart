import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CourseRapidePage extends StatefulWidget {
  const CourseRapidePage({super.key});

  @override
  State<CourseRapidePage> createState() => _CourseRapidePageState();
}

class _CourseRapidePageState extends State<CourseRapidePage> {
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final String mapboxToken =
      "pk.eyJ1IjoiZGVvNTUiLCJhIjoiY21iZmE2cWVzMmM0cDJscDlrZ2R2ZnR4dSJ9.Gy24yXxgHhTlcpLV242RIg";

  List<Map<String, dynamic>> _departSuggestions = [];
  List<Map<String, dynamic>> _destinationSuggestions = [];

  LatLng? _departPosition;
  LatLng? _destinationPosition;

  Future<void> _getSuggestions(String query, bool isDepart) async {
    if (query.isEmpty) {
      setState(() {
        if (isDepart) {
          _departSuggestions = [];
        } else {
          _destinationSuggestions = [];
        }
      });
      return;
    }

    final url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=$mapboxToken&autocomplete=true&limit=5";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data["features"] as List;

      setState(() {
        final suggestions = features
            .map((f) => {
                  "name": f["place_name"],
                  "lat": f["geometry"]["coordinates"][1],
                  "lng": f["geometry"]["coordinates"][0],
                })
            .toList();

        if (isDepart) {
          _departSuggestions = suggestions;
        } else {
          _destinationSuggestions = suggestions;
        }
      });
    }
  }

  void _selectPlace(Map<String, dynamic> place, bool isDepart) {
    setState(() {
      if (isDepart) {
        _departController.text = place["name"];
        _departPosition = LatLng(place["lat"], place["lng"]);
        _departSuggestions = [];
      } else {
        _destinationController.text = place["name"];
        _destinationPosition = LatLng(place["lat"], place["lng"]);
        _destinationSuggestions = [];
      }
    });
  }

  void _demarrerCourse() {
    if (_departPosition == null || _destinationPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir départ et destination")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Course démarrée 🚖\nDe: ${_departController.text}\nVers: ${_destinationController.text}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Rapide"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Champs de recherche
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _departController,
                  decoration: const InputDecoration(
                    labelText: "Lieu de départ",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  onChanged: (value) => _getSuggestions(value, true),
                ),
                if (_departSuggestions.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: _departSuggestions.map((place) {
                        return ListTile(
                          title: Text(place["name"]),
                          onTap: () => _selectPlace(place, true),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: "Destination",
                    prefixIcon: Icon(Icons.flag),
                  ),
                  onChanged: (value) => _getSuggestions(value, false),
                ),
                if (_destinationSuggestions.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: _destinationSuggestions.map((place) {
                        return ListTile(
                          title: Text(place["name"]),
                          onTap: () => _selectPlace(place, false),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // Carte Mapbox
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                center: LatLng(6.3703, 2.3912), // Cotonou par défaut
                zoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken",
                  additionalOptions: {
                    'accessToken': mapboxToken,
                    'id': 'mapbox.streets',
                  },
                ),
                if (_departPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _departPosition!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 40,
                        ),
                      )
                    ],
                  ),
                if (_destinationPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _destinationPosition!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.flag,
                          color: Colors.red,
                          size: 40,
                        ),
                      )
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _demarrerCourse,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text("Démarrer la course"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
