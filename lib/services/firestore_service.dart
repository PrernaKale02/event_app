import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Event>> getEvents() {
    return _db.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Event(
          id: doc.id,
          title: data['title'],
          location: data['location'],
          date: data['date'],
          description: data['description'],
        );
      }).toList();
    });
  }
}
