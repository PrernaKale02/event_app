import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';

class BookmarkService {
  final _db = FirebaseFirestore.instance;

  Future<bool> isBookmarked(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot = await _db
        .collection('bookmarks')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> toggleBookmark(String eventId, bool isBookmarked) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final collection = _db.collection('bookmarks');

    if (isBookmarked) {
      final snapshot = await collection
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } else {
      await collection.add({
        'eventId': eventId,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<Event>> getBookmarkedEvents() {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('bookmarks')
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
