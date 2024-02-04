import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naco_tasktracker/main.dart';
import 'package:naco_tasktracker/widgets/TaskDetailsWidget.dart';
import 'package:naco_tasktracker/widgets/TaskListWidget.dart';

import 'db.dart';
import 'models/Group.dart';
import 'models/GroupUser.dart';
import 'models/Task.dart';

class GroupPage extends StatefulWidget {
  final ID groupId; // ID группы для получения данных

  GroupPage({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  Group? group;
  GroupUser? groupUser;
  bool isLoading = true;

  get userRole => "owner";

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    Group? loadedGroup = await DBConverter.getGroupById(widget.groupId);
    final QuerySnapshot userSnapshot = await db
        .collection('groupUsers')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser?.email!)
        .where('groupId', isEqualTo: group?.id)
        .get();
    groupUser = await DBConverter.getGroupUserById(userSnapshot.docs.last.id);
    if (mounted) {
      setState(() {
        group = loadedGroup;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Group Not Found')),
        body: Center(child: Text('Group not found or error loading the group')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(group!.name??"Групка"), actions: [
        Row(
          children: [
            Text(groupUser!.balance.toString(), style: TextStyle(fontSize: 20),),
            Icon(Icons.star)
          ],
        ),
        IconButton(
          padding: EdgeInsets.all(16),
          icon: Icon(Icons.settings),
          onPressed: (){},
        )
      ], ),
      body: Builder(// Замените на вашу функцию получения задач группы
        builder: (context) {
            return TaskListWidget(groupId: group!.id!,);
        })
      );
  }
  void _showAddTaskDialog(BuildContext context) {
    // Состояние формы для создания задачи
    String taskTitle = '';
    String taskDescription = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => taskTitle = value,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              onChanged: (value) => taskDescription = value,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              // Добавление задачи в Firestoreы
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }


}