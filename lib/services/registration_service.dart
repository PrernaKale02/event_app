import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';

class RegistrationService {
  final _db = FirebaseFirestore.instance;

  Future<bool> isRegistered(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot = await _db
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> register(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('registrations').add({
      'eventId': eventId,
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Event>> getRegisteredEvents() {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('registrations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final eventIds = snapshot.docs
              .map((doc) => doc['eventId'] as String)
              .toList();

          if (eventIds.isEmpty) return [];

          final eventsSnapshot = await FirebaseFirestore.instance
              .collection('events')
              .where(FieldPath.documentId, whereIn: eventIds)
              .get();

          return eventsSnapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .toList();
        });
  }
}
