import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()?['role'] == 'admin';
  }
  Future<void> updateDisplayName(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Update Firebase Auth profile
      await user.updateDisplayName(name);
      
      // Optionally update Firestore user document if you store redundant data
      /*
      await FirebaseFirestore.instance .collection('users').doc(user.uid).update({
        'displayName': name,
      });
      */
    }
  }
}
