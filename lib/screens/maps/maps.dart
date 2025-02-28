import 'dart:async';
import 'dart:convert';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:navigaurd/screens/maps/accident_report.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';

class MapScreen extends StatefulWidget {
  final LatLng? accidentCoordinates;

  const MapScreen({super.key, this.accidentCoordinates});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(16.566222371638474, 81.5225554105058),
    zoom: 12.5,
  );

  bool isMapLoading = true;
  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  String _distance = "";
  String _duration = "";
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription? _positionStreamSubscription;
  Position? _lastPosition;
  String _responseText = "";
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

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

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Store the user's current location
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      isMapLoading = false;
    });

  }

  // Function to send request to the model when location changes
  Future<void> sendRequestToModel(double latitude, double longitude) async {
    final url = "https://navigaurd-ml-model.onrender.com/predict";
    final requestBody =
        jsonEncode({'latitude': latitude, 'longitude': longitude});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _responseText =
              "Slow Region: ${data['slow_region']}, Group: ${data['group']}";
        });

        // Ensure that the toast is displayed after the UI is updated
        if (data['slow_region'].contains("1")) {
          toastMessage(
            context: context,
            message: "There is a ${data['group']} NearBy. Please Go Slow",
            leadingIcon: const Icon(Icons.message),
            toastColor: Colors.yellow[300],
            borderColor: Colors.orange,
            position: DelightSnackbarPosition.top,
          );
        }
      } else {
        setState(() {
          _responseText = "Request failed: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _responseText = "Error: $e";
      });
    }

    print(_responseText);
  }

  @override
  void dispose() {
    // Cancel location stream when widget is disposed
    _positionStreamSubscription?.cancel();
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
              child:
                  const Text('Source', style: TextStyle(color: Colors.white)),
            ),
          SizedBox(width: 20),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _destination!.position, zoom: 14.5),
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.indigo[900]),
              child: const Text('Destination',
                  style: TextStyle(color: Colors.white)),
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
              if (widget.accidentCoordinates != null)
                Marker(
                  markerId: const MarkerId('Accident'),
                  position: widget.accidentCoordinates!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                  infoWindow: const InfoWindow(title: 'Accident Location'),
                ),
            },
            polylines: _polylines,
            onLongPress: addMarker,
          ),
          if (isMapLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_distance.isNotEmpty && _duration.isNotEmpty)
            Positioned(
              top: 30.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0),
                  ],
                ),
                child: Text(
                  "Distance: $_distance, Duration: $_duration",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600),
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
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AccidentReportScreen(
              coordinates: _currentLocation ?? LatLng(16.56222, 81.522555),
            ),
          ));
        },
        foregroundColor: backgroundColor,
        backgroundColor: blueColor,
        text: "Report An Accident",
      ),
    );
  }

  void addMarker(LatLng pos) async {
    setState(() {
      if (_origin == null || (_origin != null && _destination != null)) {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          position: pos,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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

        getRoute();
      }
    });
  }

  Future<void> getRoute() async {
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

      sendRequestToModel(originLat, originLng);

      // Listen to location updates
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy:
              LocationAccuracy.high, // This is the new way to set accuracy
          distanceFilter: 50, // Only updates every 10 meters of movement
        ),
      ).listen((Position position) {
        // Only call the function if the position has changed
        if (_lastPosition == null ||
            _lastPosition!.latitude != position.latitude ||
            _lastPosition!.longitude != position.longitude) {
          _lastPosition = position;
          Future.delayed(Duration(minutes: 5), () {
            sendRequestToModel(position.latitude, position.longitude);
          });
        }
      });
    } else {
      print("Failed to fetch route: ${response.body}");
    }
  }
}