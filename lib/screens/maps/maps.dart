import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

class OpenSourceMapScreen extends StatefulWidget {
  @override
  _OpenSourceMapScreenState createState() => _OpenSourceMapScreenState();
}

class _OpenSourceMapScreenState extends State<OpenSourceMapScreen> {
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(16.566222371638474, 81.5225554105058), 
    zoom: 11.5,
  );

  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  String _distance = "";
  String _duration = "";

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route with OSRM'),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _origin!.position, zoom: 14.5),
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Origin', style: TextStyle(color: Colors.white)),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _destination!.position, zoom: 14.5),
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
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
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
            },
            polylines: _polylines,
            onLongPress: _addMarker,
          ),
          if (_distance.isNotEmpty && _duration.isNotEmpty)
            Positioned(
              top: 20.0,
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
        ],
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
