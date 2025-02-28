import 'dart:async';
import 'dart:convert';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';

class HospitalsMapScreen extends StatefulWidget {
  const HospitalsMapScreen({super.key});

  @override
  State<HospitalsMapScreen> createState() => HospitalsMapScreenState();
}

class HospitalsMapScreenState extends State<HospitalsMapScreen> {
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
  Set<Marker> _markers = {};
  String _distance = "";
  String _duration = "";
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription? _positionStreamSubscription;
  Position? _lastPosition;
  String _responseText = "";
  LatLng? _currentLocation;

  Map<String, LatLng> hospitals = {
  'Bhimavaram Hospitals': LatLng(16.555831469004392, 81.5104441298582),
  'Varma Hospitals': LatLng(16.568851077276268, 81.50765441652196),
  'Imperial Hospitals': LatLng(16.582013315874402, 81.53786681826817),
  'Rajarshi Hospitals': LatLng(16.622541202209433, 81.52688074356473),
  'Vinayaka Hospitals': LatLng(16.582511389306703, 81.52962707324839),
  'Sri Venkateswara Hospitals': LatLng(16.60062030990332, 81.49666808894601),
  'Akshara Speciality Hospitals': LatLng(16.569897938803994, 81.4966683418185),
  'Mithra Medicare Hospital': LatLng(16.59885351771753, 81.4829354319339),
  'Nallaparaju Venkata Raju Hospital': LatLng(16.59982425775163, 81.63399718633626),
  'Sri Lakshmi Hospitals': LatLng(16.593073165133877, 81.52413390935429),
  'Subhadra Hospitals': LatLng(16.58991022692723, 81.4911749246604),
  'RK Gayathri Hospital': LatLng(16.611530483655162, 81.58455871290661),
  'Sai Indian Hospitals': LatLng(16.595174654167238, 81.6285040235068),
  'London Hospital': LatLng(16.609592419322126, 81.66583613669226),
  'Spandana Emergency Hospital': LatLng(16.62951818560511, 81.6614630074646),
};

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isMapLoading = false;
      });
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          isMapLoading = false;
        });
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isMapLoading = false;
      });
      return Future.error('Location permissions are permanently denied.');
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Store the user's current location
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      
      // Set current location as origin
      _origin = Marker(
        markerId: const MarkerId('origin'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      
      _markers.add(_origin!);
      
      // Initialize hospital markers
      initializeHospitals();
      
      isMapLoading = false;
    });

    // Start tracking position for updates
    startLocationTracking();
  }

  void initializeHospitals() {
    // Loop through the hospitals Map and create markers
    hospitals.forEach((name, position) {
      Marker hospitalMarker = Marker(
        markerId: MarkerId(name),
        position: position,
        infoWindow: InfoWindow(
          title: name,
          snippet: "Tap to navigate",
          onTap: () {
            setDestination(position, name);
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          setDestination(position, name);
        },
      );
      
      setState(() {
        _markers.add(hospitalMarker);
      });
    });
  }

  void setDestination(LatLng position, String name) {
    setState(() {
      // Clear previous destination if exists
      if (_destination != null) {
        _markers.remove(_destination);
      }
      
      // Set new destination
      _destination = Marker(
        markerId: const MarkerId('destination'),
        position: position,
        infoWindow: InfoWindow(title: name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      
      _markers.add(_destination!);
      
      // Update route
      getRoute();
    });
  }

  void startLocationTracking() {
    // Cancel any existing subscriptions
    _positionStreamSubscription?.cancel();
    
    // Listen to location updates
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20, // Update every 10 meters
      ),
    ).listen((Position position) {
      // Only update if position has changed significantly
      if (_lastPosition == null ||
          _lastPosition!.latitude != position.latitude ||
          _lastPosition!.longitude != position.longitude) {
        
        setState(() {
          _lastPosition = position;
          _currentLocation = LatLng(position.latitude, position.longitude);
          
          // Update origin marker
          if (_origin != null) {
            _markers.remove(_origin);
          }
          
          _origin = Marker(
            markerId: const MarkerId('origin'),
            position: _currentLocation!,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          );
          
          _markers.add(_origin!);
        });
        
        // If we have a destination, update the route
        if (_destination != null) {
          getRoute();
        }
        
        // Check for slow regions
        sendRequestToModel(position.latitude, position.longitude);
      }
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

  Future<void> getRoute() async {
    if (_origin == null || _destination == null) return;

    // Clear previous routes
    setState(() {
      _polylines.clear();
      polylineCoordinates.clear();
      _distance = "";
      _duration = "";
    });

    final originLat = _origin!.position.latitude;
    final originLng = _origin!.position.longitude;
    final destLat = _destination!.position.latitude;
    final destLng = _destination!.position.longitude;

    final url =
        "https://router.project-osrm.org/route/v1/driving/$originLng,$originLat;$destLng,$destLat?overview=full&geometries=polyline";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final routes = decodedData['routes'];

        if (routes.isNotEmpty) {
          final route = routes[0];

          final polyline = route['geometry'];
          final distanceMeters = route['legs'][0]['distance'];
          final durationSeconds = route['legs'][0]['duration'];

          setState(() {
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

            _polylines.add(Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.red,
              width: 5,
              points: polylineCoordinates,
            ));
          });
          
          // Fit the map to show both origin and destination
          LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(
              [originLat, destLat].reduce((value, element) => value < element ? value : element),
              [originLng, destLng].reduce((value, element) => value < element ? value : element),
            ),
            northeast: LatLng(
              [originLat, destLat].reduce((value, element) => value > element ? value : element),
              [originLng, destLng].reduce((value, element) => value > element ? value : element),
            ),
          );
          
          _googleMapController.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 50.0),
          );
        }
      } else {
        print("Failed to fetch route: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospitals Map'),
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
                  const Text('Your Location', style: TextStyle(color: Colors.white)),
            ),
          const SizedBox(width: 10),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _destination!.position, zoom: 14.5),
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.indigo[900]),
              child: const Text('Hospital',
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
              mapController.complete(controller);
            },
            markers: _markers,
            polylines: _polylines,
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
            bottom: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              backgroundColor: blueColor,
              child: const Icon(Icons.my_location),
              onPressed: () {
                if (_currentLocation != null) {
                  _googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: _currentLocation!, zoom: 14.5),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}