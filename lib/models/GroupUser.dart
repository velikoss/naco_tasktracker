import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

class GroupUser {
  ID? id;
  String groupId;
  String role; // Owner, Admin, User
  int balance;

  GroupUser({required this.id, required this.groupId, required this.role, this.balance = 0});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'role': role,
      'balance': balance,
    };
  }

  static GroupUser fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return GroupUser(
      id: snapshot['id'],
      groupId: snapshot['groupId'],
      role: snapshot['role'],
      balance: snapshot['balance'],
    );
  }

  static GroupUser fromJson(Map<String, dynamic> json) => GroupUser(
    id: json['id'],
    groupId: json['groupId'],
    role: json['role'],
    balance: json['balance'],
  );
}
