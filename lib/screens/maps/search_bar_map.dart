import 'dart:async';
import 'dart:convert'; // For JSON parsing
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


class AutoMapScreen extends StatefulWidget {
  const AutoMapScreen({super.key});

  @override
  State<AutoMapScreen> createState() => _AutoMapScreenState();
}

class _AutoMapScreenState extends State<AutoMapScreen> {
  late CameraPosition initial;
  late List<Marker> markerlist = [];
  late Set<Polyline> _polylines = {}; // Added Polyline set
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
      zoom: 15.0,
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

    // Update the initial camera position to user location if available
    initial = CameraPosition(
      target: userLocation!,
      zoom: 15.0,
    );

    // Update markers dynamically with the coordinates from the input fields
    final fromCoords = fromLocationController.text.split(',');
    final toCoords = toLocationController.text.split(',');

    if (fromCoords.length == 2 && toCoords.length == 2) {
      double fromLat = double.parse(fromCoords[0]);
      double fromLng = double.parse(fromCoords[1]);
      double toLat = double.parse(toCoords[0]);
      double toLng = double.parse(toCoords[1]);

      markerlist = [
        Marker(
          markerId: const MarkerId("From"),
          position: LatLng(fromLat, fromLng),
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
        Marker(
          markerId: const MarkerId("Destination"),
          position: LatLng(toLat, toLng),
          infoWindow: const InfoWindow(title: "Your Destination"),
        ),
      ];
    }

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
      print('Invalid coordinates format');
      return; // Invalid input format, skip
    }

    double fromLat = double.parse(fromCoords[0]);
    double fromLng = double.parse(fromCoords[1]);
    double toLat = double.parse(toCoords[0]);
    double toLng = double.parse(toCoords[1]);

    // OSRM API URL for routing (No API key required)
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$fromLng,$fromLat;$toLng,$toLat?overview=full&geometries=polyline');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'];

        if (routes.isNotEmpty) {
          final route = routes[0];
          final legs = route['legs'][0];

          // Extract the distance and duration from the route data
          setState(() {
            distance = legs['distance'] > 1000
                ? "${(legs['distance'] / 1000).toStringAsFixed(2)} km"
                : "${legs['distance']} m";
            duration = legs['duration'] > 3600
                ? "${(legs['duration'] / 3600).toStringAsFixed(1)} hr"
                : "${(legs['duration'] / 60).toStringAsFixed(1)} min";
          });

          final polyline = route['geometry'];
          final polylinePoints = PolylinePoints();
          List<LatLng> polylineCoordinates = polylinePoints
              .decodePolyline(polyline)
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList();

          // Add polyline to the map
          setState(() {
            _polylines.add(Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.red,
              width: 5,
              points: polylineCoordinates,
            ));
          });

          // Optional: Zoom the camera to focus on the route or markers
          final controller = await mapController.future;
          controller.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(fromLat, fromLng),
              northeast: LatLng(toLat, toLng),
            ),
            50.0, // padding around the map
          ));
        } else {
          print('No routes found');
        }
      } else {
        print('Failed to load directions: ${response.statusCode}');
        throw Exception('Failed to load directions');
      }
    } catch (e) {
      print('Error during directions API call: $e');
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
      appBar: AppBar(title: const Text("Map Screen")),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: initial,
              markers: Set<Marker>.of(markerlist),
              polylines: _polylines, // Add polylines here
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
                  ),
                  SizedBox(height: 10),
                  if (distance.isNotEmpty && duration.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Text(
                            "Distance: $distance",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 20),
                          Text(
                            "Duration: $duration",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
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
    );
  }
}
