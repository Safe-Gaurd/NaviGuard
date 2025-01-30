import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class ReportDataModel {
  final String? landMark;
  final String? town;
  final String? description;
  final LatLng? coordinates;
  final String? time;
  final List<String?>? photosList;

  ReportDataModel({
    this.landMark,
    required this.town,
    required this.description,
    required this.coordinates,
    this.time,
    this.photosList,
  });

  /// Format time to `day, date, month, year, hh:mm`
  String _formatTime() {
    final now = DateTime.now();
    return DateFormat('EEEE, dd MMMM yyyy, hh:mm a').format(now);
  }

  Map<String, dynamic> toMap() {
    return {
      'landmark': landMark ?? "Vishnu College",
      'town': town ?? "Bhimavaram",
      'description': description ?? "",
      'coordinates': coordinates != null
          ? {'latitude': coordinates!.latitude, 'longitude': coordinates!.longitude}
          : {'latitude': 16.568821984802113, 'longitude': 81.52605148094995},
      'time': time ?? _formatTime(),
      'photosList': photosList ?? [],
    };
  }

  static ReportDataModel fromMap(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document snapshot data is null for ID: ${documentSnapshot.id}");
    }

    final coordinatesData = data['coordinates'] as Map<String, dynamic>?;
    LatLng? coordinates;
    if (coordinatesData != null) {
      final latitude = coordinatesData['latitude'];
      final longitude = coordinatesData['longitude'];
      if (latitude != null && longitude != null) {
        coordinates = LatLng(latitude, longitude);
      }
    }

    return ReportDataModel(
      landMark: data['landmark'] ?? "",
      town: data['town'] ?? "",
      description: data['description'] ?? "",
      coordinates: coordinates ?? const LatLng(16.568821984802113, 81.52605148094995),
      time: data['time'] ?? "",
      photosList: List<String>.from(data['photosList'] ?? []),
    );
  }
}
