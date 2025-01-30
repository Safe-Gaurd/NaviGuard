import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigaurd/backend/models/report.dart';
import 'package:navigaurd/backend/storage/firebase_storage.dart';
import 'package:navigaurd/constants/image_picker.dart';

class ReportDataProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get uid => _auth.currentUser?.uid;

  List<ReportDataModel>? _report;
  List<ReportDataModel>? get report => _report;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Photos List
  List<String> _photosList = [];
  List<String> get photosList => _photosList;

  // For handling image selection and upload
  Uint8List? _reportImage;
  Uint8List? get reportImage => _reportImage;

  String? _reportPhotoURL;
  String? get reportPhotoURL => _reportPhotoURL;

  /// Fetch reports from Firestore
  Future<void> fetchReport() async {
    _setLoading(true);
    try {
      QuerySnapshot snapshot = await _firestore.collection('reports').get();
      _report = snapshot.docs.map((doc) => ReportDataModel.fromMap(doc)).toList();
    } catch (e) {
      print('Error fetching reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Select an image
  void selectImage(ImageSource source) async {
    try {
      Uint8List image = await pickImage(source);
      _reportImage = image;
      if (image.isNotEmpty) {
        await generateReportUrl();
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
    notifyListeners();
  }

  /// Generate a URL for the selected image
  Future<void> generateReportUrl() async {
    if (_reportImage == null) return;
    try {
      _reportPhotoURL = await StorageMethods.uploadImageToStorage(
        childName: 'report',
        file: _reportImage!,
      );
      _photosList.add(_reportPhotoURL!); // Add to the photos list
      notifyListeners();
    } catch (e) {
      print('Error generating report photo URL: $e');
    }
  }

  /// Add a report to Firestore
  Future<String> addReport({
    required String town,
    required String description,
    String? landMark,
    LatLng? coordinates,
  }) async {
    String res="";
    if (coordinates == null) {
      print('Coordinates are required to add a report.');
      res="";
    }

    final report = ReportDataModel(
      landMark: landMark,
      town: town,
      description: description,
      coordinates: coordinates,
      time: DateTime.now().toString(), // You can format this as needed
      photosList: _photosList,
    );

    try {
      // Use latitude and longitude as the document ID
      String documentId = '${coordinates?.latitude},${coordinates?.longitude}';

      await _firestore.collection('reports').doc(documentId).set(report.toMap());
      res="success";
      // Clear the local photos list after successfully adding the report
      _photosList.clear();
      notifyListeners();
    } catch (e) {
      print('Error adding report: $e');
    }
    return res;
  }
}
