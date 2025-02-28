import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AutoSearchScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const AutoSearchScreen({super.key, required this.onLocationSelected});

  @override
  _AutoSearchScreenState createState() => _AutoSearchScreenState();
}

class _AutoSearchScreenState extends State<AutoSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _autocompleteResults = [];

  Future<void> fetchAutocompleteResults(String query) async {
    if (query.isEmpty) return;

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _autocompleteResults = json.decode(response.body);
        });
      } else {
        print("❌ API Error: Status Code ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Unexpected Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Location")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Enter location...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => fetchAutocompleteResults(_searchController.text),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => fetchAutocompleteResults(value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _autocompleteResults.length,
              itemBuilder: (context, index) {
                final place = _autocompleteResults[index];
                return ListTile(
                  title: Text(place['display_name']),
                  onTap: () {
                    double lat = double.parse(place['lat']);
                    double lon = double.parse(place['lon']);
                    widget.onLocationSelected(LatLng(lat, lon));
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
