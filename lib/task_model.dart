import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime creationDate;
  final DateTime deadline;

  Task({required this.id, required this.title, required this.description, required this.creationDate, required this.deadline});

  // Konvertera från Firestore
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      deadline: (data['deadline'] as Timestamp).toDate(),
    );
  }

  // Konvertera till Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'creationDate': creationDate,
      'deadline': deadline,
    };
  }
}
