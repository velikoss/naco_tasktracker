import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naco_tasktracker/db.dart';
import 'package:provider/provider.dart';

import '../ThemeProvider.dart';
import '../group_page.dart';
import '../models/Group.dart';
import '../models/Task.dart';
import 'TaskDetailsWidget.dart';
import 'TaskWidget.dart';

class TaskListWidget extends StatefulWidget {
  final String groupId;

  TaskListWidget({Key? key, required this.groupId}) : super(key: key);

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  List<Task> tasks = [];
  bool isReady = false;
  late bool isDarkTheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  _loadTasks() async {
    Group? group = await DBConverter.getGroupById(widget.groupId);
    List<Task> loadedTasks = [];
    for (String taskID in group!.tasks!) {
      Task? task = await DBConverter.getTaskById(taskID);
      if (task != null) {
        task.id = taskID;
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
    isDarkTheme = Provider.of<ThemeProvider>(context).themeData.brightness == ThemeData.dark().brightness;

    return isReady ?  Scaffold(
      body: tasks.isEmpty
          ? Center(child: Text("Нет задач", style: Theme.of(context).textTheme.displayMedium?.copyWith(color: isDarkTheme ? Colors.white : Colors.black),))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          Task task = tasks[index];
          return TaskWidget(
            title: task.title,
            task: task,
            assignedTo: (task.assignee == null ? "Not assigned to anyone" : task.assignee == FirebaseAuth.instance.currentUser?.email! ? "Assigned to You" : "Assigned to Other"),
            isAssignedToYou: (task.assignee??"") == FirebaseAuth.instance.currentUser?.email!, id: task.id!,
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
    int? selectedPriority; // Для хранения выбранного приоритета
    DateTime? selectedDeadline; // Для хранения выбранного дедлайна

    // Функция для отображения DatePicker
    _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDeadline ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != selectedDeadline) {
        setState(() {
          selectedDeadline = picked;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Добавить задачу', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: isDarkTheme ? Colors.white : Colors.black)),
        content: SingleChildScrollView(
          child: Column(
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
              DropdownButtonFormField<int>(
                value: selectedPriority,
                items: List<DropdownMenuItem<int>>.generate(
                  10,
                      (int index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('Приоритет ${index + 1}'),
                  ),
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedPriority = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Приоритет'),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDeadline == null
                          ? 'Выберите дедлайн'
                          : 'Дедлайн: ${selectedDeadline!.toLocal()}'.split(' ')[0],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDarkTheme ? Colors.white : Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Выбрать дату'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => GroupPage(groupId: widget.groupId)),
              );
            },
          ),
          TextButton(
            child: const Text('Добавить'),
            onPressed: () {
              _addTask(
                titleController.text,
                descriptionController.text,
                selectedPriority ?? 1, // Установите значение по умолчанию, если не выбрано
                selectedDeadline ?? DateTime.now(), // Установите значение по умолчанию, если не выбрано
              );
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => GroupPage(groupId: widget.groupId)),
              );
            },
          ),
        ],
      ),
    );
  }

  void _addTask(String title, String description, int priority, DateTime deadline) async {
    Task newTask = Task(
      title: title,
      description: description,
      priority: priority,
      deadline: deadline,
      // Установите остальные свойства задачи
    );
    // Добавление задачи в базу данных
    var doc = await DBConverter.addTask(newTask);

    Group? group = await DBConverter.getGroupById(widget.groupId);
    group?.tasks?.add(doc.id);
    db.collection("groups").doc(widget.groupId).update({"tasks": group?.tasks != null? group?.tasks : []});


    _loadTasks(); // Перезагрузка списка задач
  }
}
