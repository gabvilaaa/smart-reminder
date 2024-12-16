import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:projeto_reminder/utils/ProviderStore.dart';

// import 'package:projeto_reminder/utils/snackbar.dart';
import 'package:provider/provider.dart';

import 'dart:math';
import '../database/database_helper.dart';
import '../utils/esp.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> reminders = [];
  List<Map<String, dynamic>> addedDevices = [];
  late List<bool> valuesLocal;
  late List<Esp> espAvaibles = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadReminders();
    context.read<LoadedEsps>().valuesCreate();

    if (espAvaibles.isEmpty) {
      await recuperarDados(context);
    } else {
      for (Esp esp in context
          .read<LoadedEsps>()
          .device) {
        try {
          if (!esp.getStatusConection()) {
            esp.connectBluetooth(context).whenComplete(() async {
              context.read<LoadedEsps>().update();
              List<Map<String, dynamic>> relatedDevices = await DatabaseHelper()
                  .getRemindersForDevice(esp.code);


              for (var remind in relatedDevices) {

                if (DateTime.parse(remind['date'].toString()).isAfter(
                    DateTime.now())) {
                  Future.delayed(const Duration(milliseconds: 500))
                      .whenComplete(() {
                    esp.writeListText(
                      "newReminder",
                      [
                        remind['title'], remind['description'], remind['date']],
                      "@",
                      context,
                    );
                  });
                }
              }
            });
          }
        } catch (e) {}
        print("Fim try catch");
      }
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    espAvaibles = context
        .watch<LoadedEsps>()
        .device;
    valuesLocal = context
        .watch<LoadedEsps>()
        .values;
  }

  Future<void> _loadReminders() async {
    List<Map<String, dynamic>> loadedReminders =
    await DatabaseHelper().getReminders();
    List<Map<String, dynamic>> loadedAdded =
    await DatabaseHelper().getAddedDevices();
    print("Lembretes carregados do banco de dados: $loadedReminders");
    print("Relações carregados do banco de dados: $loadedAdded");
    setState(() {
      reminders = List.from(loadedReminders);
      addedDevices = List.from(loadedAdded);
    });
  }

  _defineEsptoReminders() {
    showDialog(
        context: context,
        builder: (BuildContext mainContex) {
          return Dialog(
            insetPadding: const EdgeInsets.all(30),
            child: SizedBox(
                height: 550,
                child: Column(
                  children: [
                    const Text("Dispositivos disponíveis:",
                        style: TextStyle(fontSize: 22)),
                    SizedBox(
                      child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          shrinkWrap: true,
                          itemCount:
                          mainContex
                              .read<LoadedEsps>()
                              .device
                              .length,
                          itemBuilder: (context, index) {
                            return Card(
                                child: CheckboxListTile(
                                  title: Text(espAvaibles[index].name),
                                  subtitle: Text(
                                      "Status: ${(espAvaibles[index]
                                          .getStatusConection() ?? false)
                                          ? "Conectado"
                                          : "Desconectado"} \n"
                                          "ID: ${espAvaibles[index]
                                          .subtittle}"),
                                  value: context
                                      .watch<LoadedEsps>()
                                      .values[index],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      context
                                          .read<LoadedEsps>()
                                          .addValues(index, value!);
                                      print(
                                          "Atualizou para ${valuesLocal[index]} na posicao $index");
                                    });
                                  },
                                ));
                          }),
                    ),
                    const SizedBox(height: 10),
                    MaterialButton(
                        child: const Text("Salvar Lembretes"),
                        onPressed: () async {
                          reminders = await DatabaseHelper().getReminders();
                          setState(() {
                            Navigator.of(context).pop();
                          });
                        })
                  ],
                )),
          );
        });
  }

  void _showReminderDialog(
      {Map<String, dynamic>? reminder, required int index}) {
    final titleController = TextEditingController(text: reminder?['title']);
    final descriptionController =
    TextEditingController(text: reminder?['description']);
    print("Datas existentes: ${reminder?['date']}");
    DateTime? selectedDate =
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
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              Text(selectedDate == null
                  ? 'No Date Chosen!'
                  : 'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(
                  selectedDate!)}'),
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
                        selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                      setState(() {

                      });
                    }
                  }
                },

                child: const Text('Choose Date and Time'),
              ),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: () {
                    setState(() {
                      _defineEsptoReminders();
                      print("Atualizando");
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    selectedDate != null) {
                  final newReminder = {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'date': selectedDate!.toString(),
                  };

                  if (index == -1) {
                    setState(() {
                      DatabaseHelper().insertReminder(newReminder);
                      _loadReminders();
                    });
                  } else {
                    int id = reminders[index]['id'];
                    setState(() {
                      DatabaseHelper().updateReminder(id, newReminder);
                      _loadReminders();
                    });
                  }
                  for (int i = 0; i < valuesLocal.length; i++) {
                    if (valuesLocal[i]) {
                      _loadReminders().whenComplete(() {
                        final newAdded = {
                          'id_reminder': (index != -1) ? index : reminders
                              .last['id'],
                          'id_device': i.toString()
                        };
                        DatabaseHelper().insertAddedDevices(newAdded);
                        int temp = (index != -1) ? index : reminders.last['id']-1;
                        espAvaibles[i].writeListText(
                            "newReminder",
                            [
                              reminders[temp]['title'],
                              reminders[temp]['description'],
                              reminders[temp]['date']
                            ],
                            "@",
                            context);
                      });
                    }
                  }

                  _loadReminders();
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
    setState(() {});

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
                if (DateTime.parse(reminders[index]['date']).isBefore(
                    DateTime.now())) {
                  return Card();
                } else {
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
                        '${reminders[index]['description']} - ${DateFormat(
                            'yyyy/MM/dd HH:mm').format(DateTime.parse(
                            reminders[index]['date']))}',
                      ),
                      trailing: const Icon(Icons.notifications_active),
                      onTap: () {
                        // Editar lembrete ao clicar
                        _showReminderDialog(
                            reminder: reminders[index], index: index);
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReminderDialog(index: -1),
        child: const Icon(Icons.add),
      ),
    );
  }
}
