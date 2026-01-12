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
          category: data['category'] ?? 'General',
        );
      }).toList();
    });
  }

  Future<void> updateEvent(Event event) async {
    await _db.collection('events').doc(event.id).update({
      'title': event.title,
      'location': event.location,
      'date': event.date,
      'description': event.description,
      'category': event.category,
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }
}
