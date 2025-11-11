import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final Function(String title, DateTime date) onSave;
  final DateTime initialDate;

  const TaskDialog({
    super.key,
    this.task,
    required this.onSave,
    required this.initialDate,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _controller = TextEditingController();
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.task?.title ?? '';
    _selectedDateTime = widget.task?.date ?? widget.initialDate;
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    // Elegir fecha (no permite fechas pasadas)
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (pickedDate == null) return;

    // Elegir hora
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedDateTime = combined;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime);

    return AlertDialog(
      title: Text(widget.task == null ? 'Nueva tarea' : 'Editar tarea'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration:
                  const InputDecoration(hintText: 'Descripción de la tarea'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('Fecha y hora: $formattedDate')),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDateTime,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onSave(_controller.text.trim(), _selectedDateTime);
              Navigator.pop(context);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
