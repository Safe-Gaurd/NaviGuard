import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigaurd/backend/models/report.dart';
import 'package:navigaurd/constants/date_time.dart';
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
  final List<String> _photosList = [];
  List<String> get photosList => _photosList;

  void fetchReport() {
    _isLoading = true;
    notifyListeners();

    _firestore.collection('reports').snapshots().listen((snapshot) {
      _report =
          snapshot.docs.map((doc) => ReportDataModel.fromMap(doc)).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      //print('Error fetching reports: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  File? _reportImage;
  File? get reportImage => _reportImage;

  String? _photoURL;
  String? get photoURL => _photoURL;

  Future<void> selectImage(ImageSource source) async {
    _isLoading = true;
    try {
      //print("📷 Selecting image...");
      File? image = await CustomImagePicker(isReport: true).pickImage(source);
      _reportImage = image;
      notifyListeners();

      if (image != null) {
        await generateProfileUrl();
      }
    } catch (e) {
      //print("❌ Error selecting image: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateProfileUrl() async {
    try {
      //print("⏳ Uploading image...");
      String? imageUrl = await CustomImagePicker(isReport: true)
          .uploadToCloudinary(isReport: true, imageFile: reportImage);
      //print("✅ Image uploaded to Cloudinary successfully: $imageUrl");

      if (imageUrl != null && imageUrl.isNotEmpty) {
        _photoURL = imageUrl;
        _photosList.add(_photoURL!);
        notifyListeners();
      }
    } catch (e) {
      //print("❌ Error uploading image: $e");
    }
  }

  Future<String> addReport({
    required String town,
    required String description,
    String? landMark,
    LatLng? coordinates,
  }) async {
    String res = "";
    if (coordinates == null) {
      //print('Coordinates are required to add a report.');
      res = "";
    }

    final String timeFormatted = '$formattedDate, $formattedTime';
    final report = ReportDataModel(
      landMark: landMark,
      town: town,
      description: description,
      coordinates: coordinates,
      time: timeFormatted,
      photosList: _photosList,
    );

    try {
      String documentId = '${coordinates?.latitude},${coordinates?.longitude}';

      await _firestore
          .collection('reports')
          .doc(documentId)
          .set(report.toMap());
      res = "success";
      _photosList.clear();
      notifyListeners();
    } catch (e) {
      //print('Error adding report: ${e.toString()}');
    }
    return res;
  }
}
