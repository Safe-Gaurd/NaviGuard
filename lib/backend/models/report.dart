import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportDataModel {
  final String? landMark;
  final String? town;
  final String? description;
  final LatLng? coordinates;
  final String? time;

  ReportDataModel({
    this.landMark,
    required this.town,
    required this.description,
    required this.coordinates,
    this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'landmark': landMark ?? "Vishnu College",
      'town': town ?? "Bhimavaram",
      'description': description ?? "",
      'coordinates': coordinates != null
          ? {'latitude': coordinates!.latitude, 'longitude': coordinates!.longitude}
          : const LatLng(16.568821984802113, 81.52605148094995),
      'time': time,

    };
  }

  static ReportDataModel fromMap(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data() as Map<String, dynamic>?;

    if (data == null) {
    throw Exception("Document snapshot data is null");
  }

    return ReportDataModel(
      landMark: data['landmark'] ?? "",
      town: data['town'] ?? "",
      description: data['description'] ?? "",
      coordinates: data['coordinates'] ?? const LatLng(16.568821984802113, 81.52605148094995),
      time: data['time'] ?? "",
    );
  }
}
