import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class Task {
  final String id;
  final String title;
  final DateTime dateTime;

  Task({required this.id, required this.title, required this.dateTime});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateTime': dateTime.toIso8601String(),
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        dateTime: DateTime.parse(json['dateTime']),
      );
}

class CalendarScreen extends StatefulWidget {
  final String username;
  const CalendarScreen({super.key, required this.username});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Task>> _tasks;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tasks = {};
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks_${widget.username}');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      final loaded = decoded.map((e) => Task.fromJson(e)).toList();
      setState(() {
        for (var task in loaded) {
          final day = DateTime.utc(task.dateTime.year, task.dateTime.month, task.dateTime.day);
          _tasks[day] = [...(_tasks[day] ?? []), task];
        }
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final allTasks = _tasks.values.expand((e) => e).toList();
    await prefs.setString('tasks_${widget.username}', jsonEncode(allTasks));
  }

  void _addTask(String title, DateTime dateTime) async {
    if (dateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes agregar tareas en fechas pasadas')),
      );
      return;
    }

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      dateTime: dateTime,
    );

    setState(() {
      final day = DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
      _tasks[day] = [...(_tasks[day] ?? []), task];
    });

    await _saveTasks();
  }

  void _deleteTask(Task task) async {
    setState(() {
      _tasks.forEach((key, list) => list.removeWhere((t) => t.id == task.id));
    });
    await _saveTasks();
  }

  void _editTask(Task task) async {
    final controller = TextEditingController(text: task.title);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar tarea'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() {
                final updated = Task(
                  id: task.id,
                  title: controller.text,
                  dateTime: task.dateTime,
                );
                final day =
                    DateTime.utc(task.dateTime.year, task.dateTime.month, task.dateTime.day);
                _tasks[day] = _tasks[day]!
                    .map((t) => t.id == task.id ? updated : t)
                    .toList();
              });
              _saveTasks();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  List<Task> _getTasksForDay(DateTime day) {
    final date = DateTime.utc(day.year, day.month, day.day);
    return _tasks[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Bienvenido, ${widget.username}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account, color: Colors.white),
            tooltip: 'Cambiar de cuenta',
            onPressed: () async {
              await UserService.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Card(
              color: Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  locale: 'es_ES',
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2100, 1, 1),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.indigoAccent.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ListView(
                  children: _getTasksForDay(_selectedDay ?? _focusedDay)
                      .map(
                        (t) => Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade200,
                              child: const Icon(Icons.event_note, color: Colors.white),
                            ),
                            title: Text(
                              t.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${t.dateTime.hour.toString().padLeft(2, '0')}:${t.dateTime.minute.toString().padLeft(2, '0')} hs',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () => _editTask(t),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteTask(t),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            final controller = TextEditingController();
            DateTime selectedDate = _selectedDay ?? DateTime.now();
            TimeOfDay selectedTime = TimeOfDay.now();

            await showDialog(
              context: context,
              builder: (_) => StatefulBuilder(
                builder: (context, setStateDialog) => AlertDialog(
                  title: const Text('Nueva tarea'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(labelText: 'Título'),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              ),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setStateDialog(() => selectedDate = date);
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: TextButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text(
                                '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              ),
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (time != null) {
                                  setStateDialog(() => selectedTime = time);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                    TextButton(
                      onPressed: () {
                        final dateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        _addTask(controller.text, dateTime);
                        Navigator.pop(context);
                      },
                      child: const Text('Agregar'),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
