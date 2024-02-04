import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naco_tasktracker/db.dart';

import '../models/Group.dart';
import '../models/Task.dart';
import 'TaskDetailsWidget.dart';

class TaskListWidget extends StatefulWidget {
  final String groupId;

  TaskListWidget({Key? key, required this.groupId}) : super(key: key);

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  List<Task> tasks = [];
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  _loadTasks() async {
    Group? group = await DBConverter.getGroupById(widget.groupId);
    List<Task> loadedTasks = [];
    for (String taskID in group!.tasks!) {
      Task? task = await DBConverter.getTaskById(taskID);
      if (task != null) {
        loadedTasks.add(task);
      }
    }
    setState(() {
      tasks = loadedTasks;
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isReady ?  Scaffold(
      body: tasks.isEmpty
          ? const Center(child: Text("Нет задач"))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          Task task = tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description??""),
            // Остальные свойства ListTile...
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailsWidget(taskId: task.id!,),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Добавить задачу',
      ),
    ) : const CircularProgressIndicator();
  }

  void _showAddTaskDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить задачу'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Добавить'),
            onPressed: () {
              _addTask(titleController.text, descriptionController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _addTask(String title, String description) async {
    Task newTask = Task(
      title: title,
      description: description,
      groupId: widget.groupId
    );
    // Добавление задачи в базу данных
    var doc = await DBConverter.addTask(newTask);

    Group? group = await DBConverter.getGroupById(widget.groupId);
    group?.tasks?.add(doc.id);
    db.collection("groups").doc(widget.groupId).update({"tasks": group?.tasks != null? group?.tasks : []});


    _loadTasks(); // Перезагрузка списка задач
  }
}
