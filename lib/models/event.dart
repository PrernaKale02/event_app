import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String location;
  final String date;
  final String description;
  final String category;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.description,
    required this.category,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
    );
  }
}
