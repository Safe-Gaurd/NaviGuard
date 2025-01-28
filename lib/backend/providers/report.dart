import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigaurd/backend/models/report.dart';
import 'package:navigaurd/backend/storage/firebase_storage.dart';
import 'package:navigaurd/constants/image_picker.dart';

class ReportDataProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  List<ReportDataModel>? _report;
  List<ReportDataModel>? get report => _report;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Fetch reports from Firestore and map them to `ReportDataModel`
  Future<void> fetchReport() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Fetch all documents from the "reports" collection
      QuerySnapshot snapshot = await _firestore.collection('reports').get();

      // Map the documents to a list of `ReportDataModel`
      _report = snapshot.docs.map((doc) {
        return ReportDataModel.fromMap(doc);
      }).toList();

      print('Fetched ${_report?.length ?? 0} reports');
    } catch (e) {
      print('Error fetching reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Uint8List? _uploadImage;
  Uint8List? get uploadImage => _uploadImage;

  void selectImage(ImageSource source) async {
    XFile? image = await pickImage(source);
    if (image != null) {
      _uploadImage = await image.readAsBytes();
      await generateuploadUrl();
    } else {
      _uploadImage = null;
    }
    notifyListeners();
  }

  String? _uploadUrl;
  String? get uploadUrl => _uploadUrl;

  Future<void> generateuploadUrl() async {
    if (uploadImage == null) {
      print('No image selected for upload');
      return;
    }

    try {
      _uploadUrl = await StorageMethods.uploadImageToStorage(
        childName: 'media',
        file: uploadImage!,
      );
      notifyListeners();
    } catch (e) {
      print('Error uploading image: ${e.toString()}');
    }
  }

  Future<String> addReportPhotos(String id) async {
    try {
      await _firestore
          .collection('reports')
          .doc(id)
          .collection('photos')
          .add({'image': uploadUrl});
      return 'done';
    } catch (e) {
      print('Error adding photo: ${e.toString()}');
      return e.toString();
    }
  }

  Future<String> addReportDescription({
    required String id,
    required ReportDataModel reportEach
     }) async {
    try {
      await _firestore
          .collection('reports')
          .doc(id)
          .set(reportEach.toMap());
          // .add({'text': description});
      return 'done';
    } catch (e) {
      print('Error adding description: ${e.toString()}');
      return e.toString();
    }
  }
}
