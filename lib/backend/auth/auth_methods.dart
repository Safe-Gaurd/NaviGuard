import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:navigaurd/backend/models/user_model.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Signup with Email
  Future<String> handleSignUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String photoURL = "",
  }) async {
    String res = "";
    try {
      final UserCredential result =
          await auth.createUserWithEmailAndPassword(email: email, password: password);
      final User user = result.user!;
      UserModel data =
          UserModel(uid: user.uid, name: name, email: email, phonenumber: phoneNumber, photoURL: photoURL);
      await firestore.collection('users').doc(user.uid).set(data.toMap());
      res = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        res = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      } else if (e.code == "invalid-email") {
        res = "Email is badly formatted.";
      } else {
        res = e.message.toString();
      }
    } catch (e) {
      res = "Error creating user: ${e.toString()}";
    }
    return res;
  }

  // Login with Email
  Future<String> handleLoginWithEmail({
    required String email,
    required String password,
  }) async {
    String res = "";
    try {
      await FirebaseAppCheck.instance.activate();
      final UserCredential result=await auth.signInWithEmailAndPassword(email: email, password: password);
      final User? user = result.user;
      if(user!=null)
      {
        res = "success";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        res = 'Incorrect password.';
      } else {
        res = e.message.toString();
      }
    } catch (e) {
      res = "Error signing in: ${e.toString()}";
    }
    return res;
  }

  // Signup with Google
  Future<String> handleSignUpWithGoogle() async {
  String res = "";
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return "Google sign-in aborted.";
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final User user = userCredential.user!;

    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      UserModel data = UserModel(
        uid: user.uid,
        name: user.displayName ?? "Unknown",
        email: user.email ?? "No email",
        phonenumber: user.phoneNumber ?? "",
        photoURL: user.photoURL ?? "",
      );
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(data.toMap());
    } else {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'lastSignIn': FieldValue.serverTimestamp(),
      });
    }
    res = "success";
  } catch (e) {
    res = "Error signing in with Google: ${e.toString()}";
  }
  return res;
}


  // Forgot Password
  Future<String> resetPassword(String email) async {
    String res = '';
    try {
      await auth.sendPasswordResetEmail(email: email);
      res = 'Password Reset Email Sent to $email';
    } on FirebaseAuthException catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Logout
  Future<void> logout() async {
    await auth.signOut();
  }
}