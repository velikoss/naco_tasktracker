import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskDetailsWidget extends StatelessWidget {
  final String taskId;

  TaskDetailsWidget({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Здесь должна быть логика получения деталей задачи по taskId
    // Примерный виджет деталей задачи:

    return Card(
        child: Column(
            children: [
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
    );
  }
}