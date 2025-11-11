import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onEdit;
  final Function(Task) onDelete;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No hay tareas para este día'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(task.title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => onEdit(task)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => onDelete(task)),
              ],
            ),
          ),
        );
      },
    );
  }
}
