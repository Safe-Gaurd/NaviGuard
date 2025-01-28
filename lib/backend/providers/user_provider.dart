import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigaurd/backend/models/user_model.dart';
import 'package:navigaurd/backend/storage/firebase_storage.dart';
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

    try {
      var snap = await _firestore.collection('users').doc(uid).get();
      _user = UserModel.fromSnapshot(snap);
    } catch (e) {
      print(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }


  Uint8List? _profileImage;
  Uint8List? get profileImage => _profileImage;

  void selectImage(ImageSource source) async {
    Uint8List image = await pickImage(source);
    _profileImage = image;
    if (image.isNotEmpty) {
      generateProfileUrl();
    }
    notifyListeners();
  }

  String? _photoURL;
  String? get photoURL => _photoURL;

  Future<void> generateProfileUrl() async {
    try {
      _photoURL = await StorageMethods.uploadImageToStorage(
        childName: 'profile',
        file: profileImage!,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  bool _isUpdate = false;
  bool get isUpdate => _isUpdate;
  Future<String> updateUserDetails({
    required String name,
    required String email,
    required String phonenumber,
    required String photoURL,
    required String location

  }) async {
    String res = '';
    final updatedUser = UserModel(
      uid: uid,
      name: name,
      email: email,
      phonenumber: phonenumber,
      photoURL: photoURL,
      location: location,
    );

    try {
      _isUpdate = true;
      notifyListeners();
      await _firestore
            .collection('users')
            .doc(uid)
            .update(updatedUser.toMap());
      _isUpdate = false;
      res = 'update';
      fetchUser();
      notifyListeners();
    } catch (error) {
      res = error.toString();
      throw Exception(error.toString());
    }
    return res;
  }
}
