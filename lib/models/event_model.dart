import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String poster, title, description, location, time;
  final double price;
  final int duration;

  Event({
    required this.poster,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.time,
    required this.duration,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      poster: data['poster'],
      title: data['title'],
      description: data['description'],
      location: data['location'],
      price: data['price'].toDouble(),
      time: data['time'],
      duration: data['duration'],
    );
  }
}
