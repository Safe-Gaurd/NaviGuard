import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/maps/accident_report.dart';
import 'package:navigaurd/screens/maps/button.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(16.566222371638474, 81.5225554105058),
    zoom: 12.5,
  );

  bool isMapLoading = false;

  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  String _distance = "";
  String _duration = "";
  Completer<GoogleMapController> mapController = Completer();

  @override
  void initState() {
    super.initState();
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

    // Simulating some loading time for the map data update
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isMapLoading = false;
    });
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey'),
        backgroundColor: blueColor,
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _origin!.position, zoom: 14.5),
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Source', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 20,),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _destination!.position, zoom: 14.5),
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.indigo[900]),
              child: const Text('Destination', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _googleMapController = controller;
              mapController.complete(controller); // Completes the mapController
            },
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
            },
            polylines: _polylines,
            onLongPress: _addMarker,
          ),
          if (isMapLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_distance.isNotEmpty && _duration.isNotEmpty)
            Positioned(
              top: 30.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 6.0),
                  ],
                ),
                child: Text(
                  "Distance: $_distance, Duration: $_duration",
                  style: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          Positioned(
            bottom: 18.0,
            left: 10.0,
            child: Row(
              children: [
                CustomElevatedButton(
                  backgroundColor: blueColor,
                  foregroundColor: backgroundColor,
                  onPressed: () async {
                    final controller = await mapController.future;
                    controller.animateCamera(CameraUpdate.zoomIn());
                  },
                  isIcon: true,
                  icon: Icons.zoom_in,
                  text: '',
                ),
                SizedBox(width: 10),
                CustomElevatedButton(
                  backgroundColor: blueColor,
                  foregroundColor: backgroundColor,
                  onPressed: () async {
                    final controller = await mapController.future;
                    controller.animateCamera(CameraUpdate.zoomOut());
                  },
                  text: "",
                  isIcon: true,
                  icon: Icons.zoom_out,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: CustomElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => MapButtonScreen()));
        }, 
        foregroundColor: backgroundColor,
        backgroundColor: blueColor,
        text: "Report An Accident",
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    setState(() {
      if (_origin == null || (_origin != null && _destination != null)) {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Origin'),
        );
        _destination = null;
        _polylines.clear();
        polylineCoordinates.clear();
        _distance = "";
        _duration = "";
      } else {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Destination'),
        );

        _getRoute();
      }
    });
  }

  Future<void> _getRoute() async {
    if (_origin == null || _destination == null) return;

    final originLat = _origin!.position.latitude;
    final originLng = _origin!.position.longitude;
    final destLat = _destination!.position.latitude;
    final destLng = _destination!.position.longitude;

    final url =
        "https://router.project-osrm.org/route/v1/driving/$originLng,$originLat;$destLng,$destLat?overview=full&geometries=polyline";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      final routes = decodedData['routes'];

      if (routes.isNotEmpty) {
        final route = routes[0]; 

        final polyline = route['geometry'];
        final distanceMeters = route['legs'][0]['distance'];
        final durationSeconds = route['legs'][0]['duration'];

        _distance = (distanceMeters > 1000)
            ? "${(distanceMeters / 1000).toStringAsFixed(2)} km"
            : "$distanceMeters m";

        _duration = (durationSeconds > 3600)
            ? "${(durationSeconds / 3600).toStringAsFixed(1)} hr"
            : "${(durationSeconds / 60).toStringAsFixed(1)} min";

        polylineCoordinates = PolylinePoints()
            .decodePolyline(polyline)
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList();

        setState(() {
          _polylines.add(Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.red,
            width: 5,
            points: polylineCoordinates,
          ));
        });
      }
    } else {
      print("Failed to fetch route: ${response.body}");
    }
  }
}
