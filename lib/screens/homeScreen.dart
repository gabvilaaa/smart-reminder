import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'dart:math';
import '../database/database_helper.dart';
import 'package:sqflite/sqflite.dart'; // Importando o arquivo do banco de dados

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> reminders = List.empty(growable: true);

  bool _estaAtualizando = true;

  @override
  void initState() {
    super.initState();
    _loadReminders(); // Carregar lembretes ao iniciar
  }

  Future<void> _loadReminders() async {
    List<Map<String, dynamic>> loadedReminders = await DatabaseHelper().getReminders();
    print("Lembretes carregados do banco de dados: $loadedReminders");
    setState(() {
      reminders = List.from(loadedReminders); // Cria uma cópia modificável da lista
    });
  }

  void _showReminderDialog({Map<String, dynamic>? reminder, int? index}) {
    final _titleController = TextEditingController(text: reminder?['title']);
    final _descriptionController = TextEditingController(text: reminder?['description']);
    DateTime? _selectedDate = reminder != null ? DateTime.parse(reminder['date']!) : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(reminder == null ? 'Add New Reminder' : 'Edit Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(_selectedDate == null
                      ? 'No Date Chosen!'
                      : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text('Choose Date'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty &&
                    _selectedDate != null) {
                  setState(() {
                    final newReminder = {
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'date': _selectedDate!.toLocal().toString().split(' ')[0],
                    };
                    if (index == null) {
                      // Adicionar novo lembrete ao banco de dados
                      DatabaseHelper().insertReminder(newReminder);
                      print("dados: ${DatabaseHelper().getReminders()}");
                      reminders.add(newReminder); // Atualizar lista local
                    } else {
                      // Atualizar lembrete existente
                      int id = reminders[index]['id'];
                      DatabaseHelper().updateReminder(id, newReminder);

                      reminders[index] = newReminder; // Atualizar lista local
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text(reminder == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Reminders',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Color.fromRGBO(
                    Random().nextInt(255),
                    Random().nextInt(255),
                    Random().nextInt(255),
                    Random().nextDouble(),
                  ),
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(reminders[index]['title']),
                    subtitle: Text(
                      '${reminders[index]['description']} - ${reminders[index]['date']}',
                    ),
                    trailing: Icon(Icons.notifications_active),
                    onTap: () {
                      // Editar lembrete ao clicar
                      _showReminderDialog(reminder: reminders[index], index: index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReminderDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
