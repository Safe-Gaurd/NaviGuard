import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigaurd/backend/models/user_model.dart';
import 'package:navigaurd/constants/image_picker.dart';

class UserProvider extends ChangeNotifier {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;
  UserModel get user => _user!;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      print("📥 Fetching user data...");
      var snap = await _firestore.collection('users').doc(uid).get();
      _user = UserModel.fromSnapshot(snap);
      print("✅ User data fetched successfully!");
    } catch (e) {
      print("❌ Error fetching user data: $e");
    }
    finally {
      _isLoading=false;
      notifyListeners();
    }
  }

  File? _profileImage;
  File? get profileImage => _profileImage;

  String? _photoURL;
  String? get photoURL => _photoURL;

  Future<void> selectImage(ImageSource source) async {
    _isLoading=true;
    notifyListeners();
    try {
      print("📷 Selecting image...");
      File? image = await CustomImagePicker(isReport: false).pickImage(source);
      _profileImage = image;
      notifyListeners();

      if (image != null) {
        await generateProfileUrl();
      }
    } catch (e) {
      print("❌ Error selecting image: $e");
    }
    finally {
      _isLoading=false;
      notifyListeners();
    }
  }

  Future<void> generateProfileUrl() async {
    try {
      print("⏳ Uploading image...");
      String? imageUrl = await CustomImagePicker(isReport: false).uploadToCloudinary(isReport:false ,imageFile: profileImage);
      print("✅ Image uploaded to Cloudinary successfully: $imageUrl");

      if (imageUrl != null && imageUrl.isNotEmpty) {
        _photoURL = imageUrl; 
        notifyListeners();
      }
    } catch (e) {
      print("❌ Error uploading image: $e");
    }
  }

  bool _isUpdate = false;
  bool get isUpdate => _isUpdate;

  Future<String> updateUserDetails({
    required String name,
    required String email,
    required String phonenumber,
    required String location,
  }) async {
    String res = '';
    
    try {

      final updatedUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        phonenumber: phonenumber,
        photoURL: photoURL, 
        location: location,
      );

      _isUpdate = true;
      notifyListeners();
      print("✍️ Updating user details in Firestore...");

      await _firestore.collection('users').doc(uid).update(updatedUser.toMap());
      _isUpdate = false;
      res = 'update';
      print("✅ User details and photo URL updated successfully!");

      await fetchUser();
      notifyListeners();

    } catch (error) {
      res = error.toString();
      print("❌ Error updating user details: $error");
      throw Exception(error.toString());
    }

    return res;
  }
}
