import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naco_tasktracker/db.dart'; // Убедитесь, что импортировали необходимый класс для работы с базой данных
import 'package:provider/provider.dart';
import '../ThemeProvider.dart';
import '../group_page.dart';
import '../models/Group.dart';
import '../models/User.dart' as IUser;

import 'package:flutter/material.dart';
import 'package:naco_tasktracker/db.dart'; // Убедитесь, что импортировали необходимый класс для работы с базой данных
import '../models/Task.dart';

class TaskDetailsWidget extends StatelessWidget {
  final String taskId;

  TaskDetailsWidget({Key? key, required this.taskId}) : super(key: key);

  Future<Task> _loadTask() async {
    Task? task = await DBConverter.getTaskById(taskId);
    if (task != null) {
      return task;
    } else {
      throw Exception('Task not found');
    }
  }

  // Примерный метод для определения, является ли текущий пользователь админом или создателем задачи
  Future<bool> _isUserAdminOrCreator(String userId, String groupId) async {
    // Здесь должна быть логика для определения роли пользователя
    return true; // Примерное значение
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Task>(
        future: _loadTask(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Произошла ошибка при загрузке данных'));
          }

          Task task = snapshot.data!;

          bool isDarkTheme = Provider.of<ThemeProvider>(context).themeData.brightness == ThemeData.dark().brightness;

          return Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.5,
                minHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      automaticallyImplyLeading: false,
                      title: Text(task.title, style: Theme.of(context).textTheme.headline6?.copyWith(color: isDarkTheme ? Colors.white : Colors.black)),
                      centerTitle: true,
                      actions: [
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    ListTile(
                      title: Text('Assigned to: ${task.assignee ?? "Not assigned"}'),
                      subtitle: Text('Deadline: ${task.deadline != null ? DateFormat('dd/MM/yyyy HH:mm').format(task.deadline!) : "No deadline"}'),
                    ),
                    ListTile(
                      title: Text('Status: ${task.status ?? "In process"}'),
                      subtitle: Text(task.description ?? "No description provided"),
                    ),
                    SizedBox(width: 1, height: 100),
                    FutureBuilder<bool>(
                      future: Future<bool>(() => true),
                      builder: (context, adminSnapshot) {
                        if (adminSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        bool isAdminOrCreator = adminSnapshot.data ?? false;
                        return Visibility(
                          visible: isAdminOrCreator,
                          child: ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                              task.assignee == FirebaseAuth.instance.currentUser?.email!?
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                label: const Text('Закончить выполнение'),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  task.status = "completed";
                                  db.collection("tasks").doc(taskId).update({"status": task.status});

                                  final QuerySnapshot groupUserSnapshot = await db
                                      .collection('groupUsers')
                                      .where('id', isEqualTo: task.assignee)
                                      .get();

                                  DBConverter.whenTaskCompleted(groupUserSnapshot.docs.first.id, task.priority);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => GroupPage(groupId: task.groupId!)),
                                  );
                                },
                              ):
                              ElevatedButton.icon(
                                icon: const Icon(Icons.person_add),
                                label: const Text('Назначить'),
                                onPressed: () async {
                                  final TextEditingController emailController = TextEditingController();
                                  // Отображение диалогового окна для ввода email
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Назначить пользователя'),
                                      content: TextField(
                                        controller: emailController,
                                        decoration: const InputDecoration(hintText: "Email пользователя"),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Отмена'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Назначить'),
                                          onPressed: () async {
                                            // Логика назначения задачи пользователю
                                            String userEmail = emailController.text;
                                            await assignTaskToUser(taskId, userEmail, context);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.delete),
                                label: const Text('Удалить'),
                                onPressed: () async {
                                  final db = FirebaseFirestore.instance;

                                  // Показываем диалог подтверждения перед удалением
                                  final confirmResult = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Подтверждение'),
                                        content: const Text('Вы уверены, что хотите удалить эту задачу?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Отмена'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Удалить'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmResult == true) {
                                    // Удаление задачи
                                    await db.collection("tasks").doc(taskId).delete();
                                    Group? group = await DBConverter.getGroupById(task.groupId!);
                                    group?.tasks?.remove(taskId);
                                    db.collection("groups").doc(task.groupId!).update({"tasks": group?.tasks != null? group?.tasks : []});

                                    IUser.User? user = await DBConverter.getUserById(task.assignee!);
                                    user?.currentTasks?.remove(taskId);
                                    db.collection("users").doc(task.assignee!).update({"currentTasks": user?.currentTasks != null? user?.currentTasks : []});

                                    // Обновляем UI или возвращаемся назад
                                    Navigator.of(context).pop(); // Закрываем диалоговое окно деталей задачи
                                    // Можно также вызвать setState или использовать другой метод для обновления списка задач
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => GroupPage(groupId: task.groupId!)),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> assignTaskToUser(String taskId, String userEmail, BuildContext context) async {
    try {
      // Получаем пользователя по email
      final userQuerySnapshot = await db.collection("users").where('id', isEqualTo: userEmail).get();
      if (userQuerySnapshot.docs.isNotEmpty) {
        final userDoc = userQuerySnapshot.docs.first;
        final userID = userDoc.id; // ID пользователя в Firestore
        IUser.User? addUser = IUser.User.fromSnapshot(userDoc); // Создаем объект пользователя из документа

        // Назначаем задачу пользователю, обновляя поле assignee в документе задачи
        await db.collection("tasks").doc(taskId).update({
          'assignee': userID // Или userEmail, в зависимости от того, как вы хотите идентифицировать пользователя
        });

        // Дополнительно: Если нужно обновить список задач пользователя, добавьте taskId в его документ
        // Убедитесь, что у пользователя есть поле для хранения ID задач, например, List<String> taskIds
        List<String> updatedTasks = List.from(addUser?.currentTasks ?? Set())..add(taskId);
        await db.collection("users").doc(userID).update({
          'taskIds': updatedTasks
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task $taskId has been successfully assigned to user $userEmail.")));
      } else {
        print("User with email $userEmail not found.");
      }
    } catch (e) {
      print("Error assigning task: $e");
    }
  }
}



