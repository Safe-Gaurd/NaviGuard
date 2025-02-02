import 'dart:async';
import 'dart:convert'; // For JSON parsing
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:navigaurd/screens/maps/accident_report.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late CameraPosition initial;
  late List<Marker> markerlist = []; // Initialize as an empty list
  Completer<GoogleMapController> mapController = Completer();
  bool isMapLoading = true;
  bool isFocusOnUser = true;
  LatLng? userLocation = const LatLng(16.566222371638474, 81.5225554105058); // Default location

  // Default coordinates for From and To locations
  final TextEditingController fromLocationController = TextEditingController(); // Default "From" location
  final TextEditingController toLocationController = TextEditingController();   // Default "To" location

  String distance = "";
  String duration = "";

  @override
  void initState() {
    super.initState();
    // Set initial camera position to default location until user location is fetched
    initial = CameraPosition(
      target: userLocation!,
      zoom: 10.0,
    );
    getUserLocation();
  }

  // Function to get user location
  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Get the user's current location
    updateMapData();
  }

  void updateMapData() async {
    setState(() {
      isMapLoading = true;
    });

    // Update initial camera position to the user location
    initial = CameraPosition(
      target: userLocation!,
      zoom: 10.0,
    );

    markerlist = [
      if (userLocation != null)
        Marker(
          markerId: const MarkerId("From"),
          position: LatLng(16.566222371638474, 81.5225554105058),
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      Marker(
        markerId: const MarkerId("Destination"),
        position: LatLng(16.54407246750926, 81.52518519509799),
        infoWindow: const InfoWindow(title: "Your Destination"),
      ),
    ];

    await getDirections();

    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(initial));

    setState(() {
      isMapLoading = false;
    });
  }

  Future<void> getDirections() async {
    // Get the source and destination coordinates
    final fromCoords = fromLocationController.text.split(',');
    final toCoords = toLocationController.text.split(',');

    if (fromCoords.length != 2 || toCoords.length != 2) {
      return; // Invalid input format, skip
    }

    double fromLat = double.parse(fromCoords[0]);
    double fromLng = double.parse(fromCoords[1]);
    double toLat = double.parse(toCoords[0]);
    double toLng = double.parse(toCoords[1]);

    final String apiKey = "YOUR_GOOGLE_MAPS_API_KEY"; // Replace with your Google Maps API Key

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$fromLat,$fromLng&destination=$toLat,$toLng&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0];
      final legs = route['legs'][0];

      // Extract the distance and duration
      setState(() {
        distance = legs['distance']['text'];
        duration = legs['duration']['text'];
      });
    } else {
      throw Exception('Failed to load directions');
    }
  }

  void toggleFocus() async {
    final controller = await mapController.future;
    CameraPosition targetPosition = isFocusOnUser
        ? CameraPosition(target: userLocation!, zoom: 10.0)
        : CameraPosition(target: userLocation!, zoom: 10.0);

    controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));

    setState(() {
      isFocusOnUser = !isFocusOnUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: initial,
              markers: Set<Marker>.of(markerlist),
              onMapCreated: (controller) {
                mapController.complete(controller);
              },
              zoomControlsEnabled: false, // Disable default zoom controls
            ),
            if (isMapLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            Positioned(
              bottom: 65.0,
              right: 10.0,
              child: FloatingActionButton(
                onPressed: toggleFocus,
                tooltip: 'Toggle Focus',
                child: Icon(isFocusOnUser ? Icons.location_on : Icons.map),
              ),
            ),
            Positioned(
              bottom: 10.0,
              left: 10.0,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      final controller = await mapController.future;
                      controller.animateCamera(CameraUpdate.zoomIn());
                    },
                    child: const Icon(Icons.zoom_in),
                    tooltip: "Zoom In",
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: () async {
                      final controller = await mapController.future;
                      controller.animateCamera(CameraUpdate.zoomOut());
                    },
                    child: const Icon(Icons.zoom_out),
                    tooltip: "Zoom Out",
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20.0,
              left: 20.0,
              right: 20.0,
              child: Column(
                children: [
                  TextField(
                    controller: fromLocationController,
                    decoration: InputDecoration(
                      labelText: 'From Location',
                      hintText: 'Enter From Latitude, Longitude',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      updateMapData();
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: toLocationController,
                    decoration: InputDecoration(
                      labelText: 'To Location',
                      hintText: 'Enter To Latitude, Longitude',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      updateMapData();
                    },
                  ),
                  SizedBox(height: 10),
                  if (distance.isNotEmpty && duration.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          "Distance: $distance",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Duration: $duration",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: updateMapData,
                    child: const Text('Update Map'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomElevatedButton(
        text: "Report An Accident",
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AccidentReportScreen(coordinates: LatLng(16.566222371638474, 81.5225554105058)))); 
        },
      ),
    );
  }
}
