import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naco_tasktracker/db.dart';
import 'package:naco_tasktracker/models/Group.dart';
import 'package:naco_tasktracker/models/GroupUser.dart';
import 'package:naco_tasktracker/models/User.dart' as IUser;

import 'main.dart';
// Импортировать необходимые пакеты Firebase

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController groupNameController = TextEditingController();

  final double minWidthPixels = 300; // Задайте минимальную ширину поля ввода

  Future<void> createGroup(BuildContext context) async {
    final CollectionReference groups = FirebaseFirestore.instance.collection('groups');
    try {

      Group group = Group(
        name: groupNameController.text,
      );
      DocumentReference groupRef = await DBConverter.addGroup(group);
      groupRef.update({"id": groupRef.id});
      GroupUser groupUser = GroupUser(
        id: myCurrentUser!.email!,
        groupId: groupRef.id,
        role: "owner",
        balance: 0
      );

      DocumentReference groupUserRef = await DBConverter.addGroupUser(groupUser);
      group.users?.add(groupUserRef.id);
      groupRef.update({"users": group.users});

      IUser.User user = (await DBConverter.getUserById(FirebaseAuth.instance.currentUser!.email!))!;
      user.currentGroups?.add(groupRef.id!);
      db.collection("users").doc(FirebaseAuth.instance.currentUser!.email!).update({"currentGroups": user.currentGroups?.toList()});

      Navigator.of(context).pushReplacementNamed("/home");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error creating group: $e")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Register')),
        body: LayoutBuilder(
        builder: (context, constraints) {
          double inputWidth = constraints.maxWidth > minWidthPixels * 3
              ? constraints.maxWidth / 3
              : minWidthPixels;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: minWidthPixels, maxWidth: inputWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => createGroup(context),
                    child: Text('Create Group'),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
