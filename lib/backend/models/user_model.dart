import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel
{
  final String uid;
  final String name;
  final String email;
  final String phonenumber;
  final String? photoURL;
  final String? location;

  UserModel({
    required this.uid, 
    required this.name, 
    required this.email, 
    required this.phonenumber,
    this.photoURL="",
    this.location="Bhimavaram",
    });

    Map<String, dynamic> toMap()
    {
      return {
        'uid': uid,
        'name': name,
        'email': email,
        'phonenumber': phonenumber,
        'photoURL': photoURL,
        'location': location,
      };
    }

   static UserModel fromSnapshot(DocumentSnapshot documentSnapshot) {
  var map = documentSnapshot.data() as Map<String, dynamic>?;

  if (map == null) {
    throw Exception("Document snapshot data is null");
  }

  return UserModel(
    uid: map['uid'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phonenumber: map['phonenumber'] ?? '',
    photoURL: map['photoURL'] ?? '',
    location: map['location'] ?? '',
  );
}

}