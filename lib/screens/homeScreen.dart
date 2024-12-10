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
  List<Map<String, dynamic>> reminders = List.empty(growable: true);
  late List<bool> valuesLocal;

  late List<Esp> espAvaibles = [];

  @override
  void initState() {
    super.initState();
    espAvaibles.isEmpty
        ? recuperarDados(context).whenComplete(() {
            context.read<LoadedEsps>().valuesCreate();
          })
        : null;

    _loadReminders();
  }

  @override
  void didChangeDependencies() async {
    espAvaibles = context.watch<LoadedEsps>().device;
    valuesLocal = context.watch<LoadedEsps>().values;

    super.didChangeDependencies();
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
                              mainContex.read<LoadedEsps>().device.length,
                          itemBuilder: (context, index) {
                            if (!context
                                .read<LoadedEsps>()
                                .device[index]
                                .getStatusConection()) {
                              try {
                                context
                                    .read<LoadedEsps>()
                                    .device[index]
                                    .connectBluetooth(context)
                                    .whenComplete(() {
                                  context.read<LoadedEsps>().update();
                                });
                              } catch (e) {}
                            }

                            return Card(
                                child: CheckboxListTile(
                              title: Text(espAvaibles[index].name),
                              subtitle: Text(
                                  "Status: ${(espAvaibles[index].getStatusConection() ?? false) ? "Conectado" : "Desconectado"} \n"
                                  "ID: ${espAvaibles[index].subtittle}"),
                              value: context.watch<LoadedEsps>().values[index],
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
        // valuesLocal = List.generate(
        //   espAvaibles.length,
        //       (index) => false,
        // );
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
                  : 'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDate!)}'),
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
                    }
                  }
                },
                child: Text('Choose Date and Time'),
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
                  setState(() {
                    final newReminder = {
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'date': selectedDate!.toString(),
                    };
                    if (reminders.isNotEmpty) {
                      for (int i = 0; i < valuesLocal.length; i++) {
                        if (valuesLocal[i]) {
                          int temp = index?.toInt() ?? 0;

                          // print("Status conexão: ${espAvaibles[i].getStatusConection()}");
                          // print ("Characteristic encontrado ${espAvaibles[i].characteristic?.uuid.toString()}");
                          espAvaibles[temp].writeListText(
                              "newReminder",
                              [
                                reminders[temp]['title'],
                                reminders[temp]['description'],
                                reminders[temp]['date']
                              ],
                              "@",
                              context);
                        }
                      }
                      DatabaseHelper().insertReminder(newReminder);
                      print("dados: ${DatabaseHelper().getReminders()}");
                      reminders.add(newReminder);
                    } else {
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
                    trailing: const Icon(Icons.notifications_active),
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
        onPressed: () => _showReminderDialog(index: 0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
