// import "package:flutter/material.dart";
import "dart:typed_data";

import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:uuid/uuid.dart";

//use this file for the storing the media in the firebase and get the network url
class StorageMethods {
  static final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<String> uploadImageToStorage(
      {required String
          childName, //child name is like the profile or post like name
      required Uint8List file,
      String? chatId}) async {
    //don't use chat id now
    Reference storageRef =
        firebaseStorage.ref().child(childName).child(auth.currentUser!.uid);
    if (chatId != null) {
      String uuid = const Uuid().v1();
      storageRef = storageRef.child(chatId).child(uuid);
    }
    SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
    UploadTask uploadTask = storageRef.putData(file, metadata);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }
}
