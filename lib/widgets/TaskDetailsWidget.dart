import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskDetailsWidget extends StatelessWidget {
  final String taskId;

  TaskDetailsWidget({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Здесь должна быть логика получения деталей задачи по taskId
    // Примерный виджет деталей задачи:

    return Scaffold(
      body: AlertDialog(
        clipBehavior: Clip.hardEdge,
        content: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Установите это, чтобы избежать вытягивания карточки на весь экран
            children: [
              AppBar(
                automaticallyImplyLeading: false, // Убираем кнопку "назад"
                title: Text('Детали задачи', style: Theme.of(context).textTheme.headline6 ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(), // Закрываем диалог
                  ),
                ],
              ),
              Text('Task 2', style: Theme.of(context).textTheme.headline6),
              Text('Assigned to: User'),
              Text('Deadline: Yesterday 2 PM'),
              Text('Status: Current Status'),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Description',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              // Дополнительная информация и действия для задачи
            ],
          ),
        ),
      ),
    );
  }
}
