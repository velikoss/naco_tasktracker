import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:naco_tasktracker/db.dart';
import 'package:naco_tasktracker/main.dart';
import 'package:naco_tasktracker/widgets/GroupWidget.dart';
import 'package:provider/provider.dart';

import 'ThemeProvider.dart';
import 'create_group_page.dart';
import 'models/Group.dart';
import 'models/Task.dart';
import 'models/User.dart' as IUser;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Set<Group> groups;

  Future<Set<Group>> getCurrentUserGroups(String id) async {
    Set<ID>? groupsIDs = (await DBConverter.getUserById(myCurrentUser!.email!))?.currentGroups!;
    Set<Group> groups = Set();
    if (groupsIDs == null) {
      return groups;
    }
    for (String groupId in groupsIDs!) {
      var group = await DBConverter.getGroupById(groupId);
      if (group != null) {
        groups.add(group);
      }
    }
    return groups;
  }

  @override
  void initState() {
    super.initState();
    myCurrentUser = FirebaseAuth.instance.currentUser;
    if (myCurrentUser?.email == null) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          Row(
            children: [
              Switch(
                value: Provider.of<ThemeProvider>(context).themeData.brightness == Brightness.dark,
                onChanged: (value) {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                },
              ),
              InkWell(
                borderRadius: BorderRadius.circular(5),
                hoverDuration: Duration(milliseconds: 100),
                onTap: () {
                  Navigator.of(context).pushNamed('/edit_profile'); // Переход на страницу редактирования
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      // Предполагаем, что у пользователя есть фото в профиле
                      backgroundImage: myCurrentUser?.photoURL != null ? NetworkImage(myCurrentUser!.photoURL!) : null,
                      child: myCurrentUser?.photoURL == null ? Icon(Icons.account_circle) : null,
                    ),
                    SizedBox(width: 8),
                    Text(myCurrentUser?.email ?? 'No email'),
                    SizedBox(width: 16),
                  ],
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.logout),

                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                tooltip: 'Logout',
              ),
            ],
          )
        ],
      ),
      body: myCurrentUser?.email == null ? Center(child: CircularProgressIndicator()) : FutureBuilder<Set<Group>>(
        future: getCurrentUserGroups(myCurrentUser!.email!), // Загрузка групп
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return Center(child: Text("Ошибка загрузки групп"));
          }
          if (snapshot.hasData) {
            Set<Group> groups = snapshot.data!;
            // Отображение списка групп
            return Container(
              width: (groups.length + 1) * 320,
              height: 400,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: groups.length + 1,
                itemBuilder: (context, index) {
                  if (index == groups.length) {
                    return _buildAddGroupButton(context);
                  }
                  Group group = groups.elementAt(index);
                  // Отображение виджета группы
                  return GroupWidget(groupId: group.id!, lastTask: '', lastUpdatedTime: DateTime.now(), groupName: group.name??"Групка", userCount: 0,);
                },
              ),
            );
          } else {
            return Center(child: Text("Группы не найдены"));
          }
        },
      ),
    );
  }

  Widget _buildAddGroupButton(BuildContext context) {
    bool isDarkTheme = Provider.of<ThemeProvider>(context).themeData.brightness == ThemeData.dark().brightness;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CreateGroupPage()),
        );
      },
      child: Container(
        width: 300,
        height: 400,
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: isDarkTheme ? Color.fromARGB(100, 116, 109, 105) : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.add_circle_outline,
            size: 50,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Task getLastTaskForGroup(String groupId) {
    // Здесь будет ваша логика получения последней задачи для группы
    return new Task(
        id: "0",
        priority: 0,
        title: "Task",
        description: "Desc",
        deadline: new DateTime(2024, 1, 1),
        assignee: 1,
        status: "[e",
        groupId: "0"
    );
  }
}
