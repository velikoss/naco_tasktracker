import 'package:cloud_firestore/cloud_firestore.dart';

class TaskRef {
  String groupId;
  String taskId;

  TaskRef({
    required this.groupId,
    required this.taskId,
  });

  // Конструктор fromJson
  factory TaskRef.fromJson(Map<String, dynamic> json) => TaskRef(
    groupId: json['groupId'],
    taskId: json['taskId'],
  );

  // Метод toJson
  Map<String, dynamic> toJson() => {
    'groupId': groupId,
    'taskId': taskId,
  };

  // Конструктор fromDocument
  factory TaskRef.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>; // Предполагаем, что data() не возвращает null
    return TaskRef(
      groupId: data['groupId'],
      taskId: data['taskId'],
    );
  }
}
