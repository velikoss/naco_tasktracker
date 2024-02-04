import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'main.dart';
import 'models/Group.dart';
import 'models/GroupUser.dart';
import 'models/Task.dart';
import 'models/User.dart';

typedef Document = Map<String, dynamic>;

var db = FirebaseFirestore.instance;

class DBConverter {
  static Document userToDocument(User user) {
    return <String, dynamic> {
      'id': user.id,
      'passportSeries': user.passportSeries,
      'passportNumber': user.passportNumber,
      'birthDate': user.birthDate,
      'firstName': user.firstName,
      'middleName': user.middleName,
      'lastName': user.lastName,
      'currentGroups': user.currentGroups,
      'currentTasks': user.currentTasks,
    };
  }

  static Document groupToDocument (Group group) {
    return <String, dynamic> {
      'id': group.id,
      'name': group.name,
      'users': group.users,
      'tasks': group.tasks,
    };
  }

  static Document taskToDocument (Task task) {
    return <String, dynamic> {
      'id': task.id,
      'priority': task.priority,
      'title': task.title,
      'description': task.description,
      'deadline': task.deadline,
      'assignee': task.assignee,
      'status': task.status,
      'groupId': task.groupId,
    };
  }

  static Document groupUserToDocument (GroupUser groupUser) {
    return <String, dynamic> {
      'id': groupUser.id,
      'groupId': groupUser.groupId,
      'role': groupUser.role,
      'balance': groupUser.balance,
    };
  }

  static Future<DocumentReference> addUser (User user) {
    return db.collection("users").add(userToDocument(user));
  }

  static Future<DocumentReference> addGroup (Group group) {
    return db.collection("groups").add(groupToDocument(group));
  }

  static Future<DocumentReference> addTask (Task task) {
    return db.collection("tasks").add(taskToDocument(task));
  }

  static Future<DocumentReference> addGroupUser (GroupUser groupUser) {
    return db.collection("groupUsers").add(groupUserToDocument(groupUser));
  }

  static Future<User?> getUserById(ID id) async {
    var doc = await db.collection("users").doc(id).get();
    return doc.exists ? User.fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  static Future<Group?> getGroupById(ID id) async {
    var doc = await db.collection("groups").doc(id).get();
    return doc.exists ? Group.fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  static Future<Task?> getTaskById(ID id) async {
    var doc = await db.collection("tasks").doc(id).get();
    return doc.exists ? Task.fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  static Future<GroupUser?> getGroupUserById(ID id) async {
    var doc = await db.collection("groupUsers").doc(id).get();
    return doc.exists ? GroupUser.fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  static Future<void> whenTaskCompleted(ID currentUserID, int taskPriority) async {
    int curBalance = (await DBConverter.getGroupUserById(currentUserID))!.balance;
    await db.collection("groupUsers").doc(currentUserID).update({"balance": curBalance + (taskPriority)});
  }

  static Future<bool> whenUserBuySomething(ID currentUserID, int cost) async {
    int curBalance = (await DBConverter.getGroupUserById(currentUserID))!.balance;
    if (cost <= curBalance) {
      await db.collection("groupUsers").doc(currentUserID).update({"balance": curBalance - cost});
      return true;
    } else {
      return false;
    }
  }
}