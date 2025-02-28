import 'dart:async';
import 'dart:convert';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:direct_caller_sim_choice/direct_caller_sim_choice.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:permission_handler/permission_handler.dart';

class BloodBanksMapScreen extends StatefulWidget {
  const BloodBanksMapScreen({super.key});

  @override
  State<BloodBanksMapScreen> createState() => BloodBanksMapScreenState();
}

class BloodBanksMapScreenState extends State<BloodBanksMapScreen> {
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(16.544793, 81.516580),
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

  Map<String, Map<String, dynamic>> bloodBanks = {
    "ASN Raju Charitable Trust Blood Centre": {
      "location": LatLng(16.544793480565474, 81.51658062276479),
      "phone": "9876543210",
    },
    "Palakol Voluntary Blood Center": {
      "location": LatLng(16.514625502921238, 81.72648167723521),
      "phone": "9876543211",
    },
    "Dharani Blood Bank": {
      "location": LatLng(16.545235703803968, 81.51616215828004),
      "phone": "9876543212",
    },
    "Uddaraju Ananda Raju Foundation": {
      "location": LatLng(16.544412098773684, 81.51681668364004),
      "phone": "9876543213",
    },
    "Sri Lakshmi Blood Bank": {
      "location": LatLng(16.5448410577951, 81.51636734331235),
      "phone": "9876543214",
    },
    "Ananda Blood Bank": {
      "location": LatLng(16.54362355223938, 81.51742705244165),
      "phone": "9876543215",
    },
    "Red Cross Blood Bank": {
      "location": LatLng(16.538305747718844, 81.50723184832331),
      "phone": "9876543216",
    },
    "Dr. Mulla Pudi Harishchandra Prasad Red Cross Blood Bank": {
      "location": LatLng(16.757517137214034, 81.68067109908927),
      "phone": "9876543217",
    },
    "Buddala Blood Bank": {
      "location": LatLng(16.75591615352696, 81.68062320701566),
      "phone": "9876543218",
    },
    "Indian Red Cross Society Blood Bank Tanuku": {
      "location": LatLng(16.75052268179303, 81.68711208188871),
      "phone": "9876543219",
    },
    "Hope Blood Donation Centre": {
      "location": LatLng(16.541987, 81.513456),
      "phone": "9876543220",
    },
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
      
      // Initialize blood bank markers
      initializeBloodBanks();
      
      isMapLoading = false;
    });

    // Start tracking position for updates
    startLocationTracking();
  }

  void initializeBloodBanks() {
    // Loop through the blood banks Map and create markers
    bloodBanks.forEach((name, data) {
      LatLng position = data["location"];
      String phone = data["phone"];
      
      Marker bloodBankMarker = Marker(
        markerId: MarkerId(name),
        position: position,
        infoWindow: InfoWindow(
          title: name,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          showBloodBankDetails(name, position, phone);
        },
      );
      
      setState(() {
        _markers.add(bloodBankMarker);
      });
    });
  }
  
  // Show blood bank details dialog
  void showBloodBankDetails(String name, LatLng position, String phone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Blood Bank Details", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Location: ${position.latitude}, ${position.longitude}"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => makePhoneCall(context, "+916303642297" ),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setDestination(position, name);
              },
              child: const Text("Navigate"),
            ),
          ],
        );
      },
    );
  }
  
  // Function to make a phone call
  Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    var status = await Permission.phone.request();

    if (status.isGranted) {
      DirectCaller().makePhoneCall('$phoneNumber');
    } else {
      toastMessage(
        context: context,
        message: "Phone Call Permission was Denied",
        position: DelightSnackbarPosition.top,
        leadingIcon: const Icon(Icons.message),
        toastColor: Colors.yellow[300],
        borderColor: Colors.orange,
      );
    }
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
        distanceFilter: 20, // Update every 20 meters
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
        title: const Text('Blood Banks Map'),
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
              child: const Text('Blood Bank',
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