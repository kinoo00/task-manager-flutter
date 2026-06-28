import 'package:flutter/material.dart';
import 'package:task_manager/data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onMarkDone;

  const TaskCard({super.key, required this.task, required this.onMarkDone});

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (task.priority.toLowerCase()) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text('Priority: ${task.priority}'),
        leading: CircleAvatar(
          backgroundColor: priorityColor,
          child: Text(task.priority[0].toUpperCase()),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(task.status,style: TextStyle(color: Colors.black),),
              backgroundColor: task.status == 'Done'
                  ? Colors.green.shade100
                  : task.status == 'In Progress'
                  ? Colors.blue.shade100
                  : Colors.grey.shade200,
            ),
            if (task.status != 'Done')
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: onMarkDone,
                tooltip: 'Mark as Done',
              ),
          ],
        ),
      ),
    );
  }
}