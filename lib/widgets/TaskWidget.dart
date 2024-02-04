import 'package:flutter/material.dart';
import 'package:naco_tasktracker/widgets/TaskDetailsWidget.dart';

class TaskWidget extends StatelessWidget {
  final String id;
  final String title;
  final String assignedTo;
  final bool isAssignedToYou;

  TaskWidget({
    Key? key,
    required this.id,
    required this.title,
    required this.assignedTo,
    this.isAssignedToYou = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: isAssignedToYou
            ? const Icon(Icons.check_box_outline_blank)
            : const SizedBox(width: 24, height: 24), // Placeholder to keep the title aligned
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(assignedTo),
        trailing: Icon(isAssignedToYou ? Icons.more_vert : Icons.remove_red_eye),
        onTap: () {
          showDialog(context: context, builder: (BuildContext context) {
            return TaskDetailsWidget(taskId: id);
          }, );
        },
      ),
    );
  }
}
