import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_reminder/utils/ProviderStore.dart';
import 'package:provider/provider.dart';


import 'dart:math';
import '../database/database_helper.dart';


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
    List<Map<String, dynamic>> loadedReminders =
        await DatabaseHelper().getReminders();
    print("Lembretes carregados do banco de dados: $loadedReminders");
    setState(() {
      reminders =
          List.from(loadedReminders); // Cria uma cópia modificável da lista
    });
  }

  void _showReminderDialog({Map<String, dynamic>? reminder, int? index}) {
    List<bool> values = List.generate(
      context.read<LoadedEsps>().device.length,
          (index) => false,
    );
    final _titleController = TextEditingController(text: reminder?['title']);
    final _descriptionController =
        TextEditingController(text: reminder?['description']);
    print("Datas existentes: ${reminder?['date']}");
    DateTime? _selectedDate =
        reminder != null ? DateTime.parse(reminder['date']!) : null;

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
              const SizedBox(height: 10),
              Text(_selectedDate == null
                  ? 'No Date Chosen!'
                  : 'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!)}'),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      setState(() {
                        _selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Text('Choose Date and Time'),
              ),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {

                          return Dialog(
                            insetPadding: EdgeInsets.all(30),

                            child: SizedBox(

                                height: 550,
                                child:Column(

                              children: [
                                const Text("Dispositivos disponíveis:", style: TextStyle(fontSize: 22),),
                                SizedBox(

                                  child:ListView.builder(
                                  padding:  const EdgeInsets.all(20),
                                    shrinkWrap: true,
                                    itemCount: context
                                        .read<LoadedEsps>()
                                        .device
                                        .length,
                                    itemBuilder: (context, index) {

                                      return Card(
                                          child: CheckboxListTile(
                                            enableFeedback: true,

                                            title: Text(context
                                                .read<LoadedEsps>()
                                                .device[index]
                                                .name),
                                            subtitle: Text(
                                                "Status: ${(context.read<LoadedEsps>().device[index].getStatusConection())?"Conectado":"Desconectado"} \nID: ${context.read<LoadedEsps>().device[index].subtittle}"),
                                            value: values[index],
                                            selected: values[index],

                                            onChanged: (bool? value) {
                                              setState(() {
                                              print("Item $index clicado");
                                              values[index]=value!;
                                              print(values[index]);
                                            });
                                              setState(() {

                                              });
                                              },
                                          )
                                      );
                                    }), ),
                                const SizedBox(height: 10),
                              ],
                            )),
                          );
                        });
                  },
                  child: const Text("Selecionar Device responsvel"))
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
                      'date': _selectedDate!.toString(),
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
                      _showReminderDialog(
                          reminder: reminders[index], index: index);
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
