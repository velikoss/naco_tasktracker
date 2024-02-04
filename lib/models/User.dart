import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';
import 'Task.dart';

class User {
  ID? id;
  int? passportSeries;
  int? passportNumber;
  DateTime? birthDate;
  String? firstName;
  String? lastName;
  String? middleName;
  Set<ID>? currentGroups;
  Set<Task>? currentTasks;

  User({
    this.id,
    this.passportSeries,
    this.passportNumber,
    this.birthDate,
    this.firstName,
    this.lastName,
    this.middleName,
    this.currentGroups,
    this.currentTasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passportSeries': passportSeries,
      'passportNumber': passportNumber,
      'bornDate': birthDate?.millisecondsSinceEpoch,
      'name': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'currentGroups': currentGroups,
      'currentTasks': currentTasks?.map((task) => task.toJson()).toList(),
    };
  }

  static User fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    Set<Task> tasks = Set();
    if (snapshot['currentTasks'] != null) {
      tasks = Set<Task>.from(snapshot['currentTasks'].map((item) => Task.fromJson(item)));
    }

    return User(
      id: snap.id,
      passportSeries: snapshot['passportSeries'],
      passportNumber: snapshot['passportNumber'],
      birthDate: snapshot['bornDate'] != null ? DateTime.fromMillisecondsSinceEpoch(snapshot['bornDate']) : null,
      firstName: snapshot['name'],
      lastName: snapshot['lastName'],
      middleName: snapshot['middleName'],
      currentGroups: Set<String>.from(snapshot['currentGroups']),
      currentTasks: tasks,
    );
  }

  static User fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    passportSeries: json['passportSeries'],
    passportNumber: json['passportNumber'],
    birthDate: json['bornDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['bornDate']) : null,
    firstName: json['name'],
    lastName: json['lastName'],
    middleName: json['middleName'],
    currentGroups: Set<String>.from(json['currentGroups'] ?? []),
    currentTasks: json['currentTasks'] != null
        ? Set<Task>.from(json['currentTasks'].map((taskJson) => Task.fromJson(taskJson)))
        : Set(),
  );
}