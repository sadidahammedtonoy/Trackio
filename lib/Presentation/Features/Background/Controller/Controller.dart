import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../Core/snakbar.dart';

class backgroundController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save selected background (color or image) for current user
  Future<void> saveUserBackground({
    required bool isColor,
    required String source,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw "User not logged in!";
      }

      final monthRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('background');

      // Create/update a document for the current month/year or timestamp
      final docRef = monthRef.doc("current");

      await docRef.set({
        'isColor': isColor,
        'source': source,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      AppSnackbar.show("Background saved successfully".tr);
      print("Background saved successfully!");
    } catch (e) {
      print("Error saving background: $e");
    }
  }

  // Stream method to listen to user's background selection
  Stream<Map<String, dynamic>?> userBackgroundStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If no logged-in user, return empty stream
      return Stream.value(null);
    }

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('background')
        .doc('current'); // assuming you save it under a doc named 'current'

    return docRef.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!;
      } else {
        return null;
      }
    });
  }


}