import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:naco_tasktracker/models/Task.dart';

import '../main.dart';

class Group {
  ID? id;
  String? name;
  Set<ID>? users;
  Set<Task>? tasks;

  Group({this.id, this.name, users, tasks}) {
    this.users = users ?? Set<ID>();
    this.tasks = tasks ?? Set<ID>();
  }

  get lastUpdatedTime => 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'users': users,
      'tasks': tasks,
    };
  }

  static Group fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Group(
      id: snapshot['id'],
      name: snapshot['name'],
      users: List<String>.from(snapshot['users']),
      tasks: List<int>.from(snapshot['tasks']),
    );
  }

  static Group fromJson(Map<String, dynamic> json) => Group(
    id: json['id'],
    name: json['name'],
    users: List<String>.from(json['users'] ?? []),
    tasks: List<int>.from(json['tasks'] ?? []),
  );
}
