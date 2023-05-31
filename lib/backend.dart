import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo/firebase_options.dart';
import 'structs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

final reminderCollection = FirebaseFirestore.instance.collection('reminders');

class ToDoConverter {
  static Map<String, dynamic> toFirestore(ToDo todo, SetOptions? options) {
    return {
      'title': todo.title,
      'description': todo.description,
      'completed': todo.completed,
      'dueDate': todo.dueDate,
    };
  }

  static ToDo fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    return ToDo(
        title: data['title'],
        description: data['description'],
        completed: data['completed'],
        dueDate: data['dueDate'].toDate());
  }
}

final reminderConverter = reminderCollection.withConverter<ToDo>(
  fromFirestore: ToDoConverter.fromFirestore,
  toFirestore: ToDoConverter.toFirestore,
);

Stream<List<ToDo>> read() {
  return reminderConverter
      .orderBy('dueDate', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
}

Future<void> create(ToDo todo) async {
  try {
    await reminderConverter.add(todo);
  } catch (e) {
    print(e);
  }
}
