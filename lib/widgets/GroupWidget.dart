import 'package:flutter/material.dart';

class GroupWidget extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String lastTask;
  final DateTime lastUpdatedTime;
  final int userCount;

  GroupWidget({
    required this.groupId,
    required this.groupName,
    required this.lastTask,
    required this.lastUpdatedTime,
    required this.userCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(groupName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Last task assigned to user: $lastTask'),
          SizedBox(height: 10),
          Text('Last updated time: ${lastUpdatedTime.toLocal()}'),
          SizedBox(height: 10),
          Text('User Count: $userCount'),
        ],
      ),
    );
  }
}
