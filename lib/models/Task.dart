import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

class Task {
  ID? id;
  int priority;
  String title;
  String? description;
  DateTime? deadline;
  ID? assignee;
  String? status;
  ID? groupId;

  Task({this.id, this.priority = 0, required this.title, this.description, this.deadline, this.assignee, this.status, this.groupId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'priority': priority,
      'title': title,
      'description': description,
      'deadline': deadline?.millisecondsSinceEpoch,
      'assignee': assignee,
      'status': status,
      'groupId': groupId,
    };
  }

  static Task fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Task(
      id: snapshot['id'],
      priority: snapshot['priority'],
      title: snapshot['title'],
      description: snapshot['description'],
      // Используйте Timestamp.toDate() для преобразования в DateTime
      deadline: snapshot['deadline'] != null ? (snapshot['deadline'] as Timestamp).toDate() : null,
      assignee: snapshot['assignee'],
      status: snapshot['status'],
      groupId: snapshot['groupId'],
    );
  }


  static Task fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    priority: json['priority'],
    title: json['title'],
    description: json['description'],
    // Проверьте, является ли значение Timestamp, и преобразуйте его соответствующим образом
    deadline: json['deadline'] != null ? (json['deadline'] is Timestamp ? json['deadline'].toDate() : DateTime.fromMillisecondsSinceEpoch(json['deadline'])) : null,
    assignee: json['assignee'],
    status: json['status'],
    groupId: json['groupId'],
  );

}
