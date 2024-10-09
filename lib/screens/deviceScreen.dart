import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'dart:math';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Devices',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255),
                Random().nextInt(255), 1),
            child: ListTile(
              title: const Text('ESP-32 Room'),
              subtitle: const Text('Active'),
              trailing: const Icon(Icons.check),
              onTap: () {
                // Navigate to episode details
              },
            ),
          ),
          Card(
            color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255),
                Random().nextInt(255), Random().nextDouble()),
            child: ListTile(
              title: const Text('ESP-32 Office'),
              subtitle: const Text('Description '),
              trailing: const Icon(Icons.check),
              onTap: () {
                // Navigate to episode details
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the AddDevice dialog when the button is pressed
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddDevice();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  List<Esp> devices = [];

  @override
  void initState() {
    super.initState();
    devices = getEsp(); // Inicializa a lista de dispositivos ao criar o widget
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16.0), // Adiciona padding ao conteúdo
        child: Column(
          mainAxisSize: MainAxisSize.min, // Define o tamanho do Column
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Add Device",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20), // Tamanho da fonte opcional
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Text(
                "Device List",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
              ),
              LoadingAnimationWidget.hexagonDots(
                  color: Colors.black, size: 20),
            ]),
            Center(
              child: SizedBox(
                height: 200, // Define uma altura para o ListView
                child: buildCards(devices),
              ),
            ),
            const Text("Digite o apelido:"),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nome do dispositivo',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            FloatingActionButton(onPressed: (){},
            child: const Text("Salvar"),)
          ],
        ),
      ),
    );
  }
}

@override
Widget buildCards(List<Esp> espss) => ListView.builder(
      itemCount: espss.length,
      itemBuilder: (context, index) {
        final esp = espss[index];

        return Card(
          child: ListTile(
            title: const Text('Nome Esp '),
            subtitle: const Text('Configuração adicional'),
            onTap: () =>{},
          ),
        );
      },
    );

List<Esp> getEsp() {
  const data = [
    {"name": "Esp1", "subtittle": "teste1"},
    {"name": "Esp2", "subtittle": "teste2"},
    {"name": "Esp1", "subtittle": "teste1"},
    {"name": "Esp2", "subtittle": "teste2"},
    {"name": "Esp1", "subtittle": "teste1"},
    {"name": "Esp2", "subtittle": "teste2"},
    {"name": "Esp1", "subtittle": "teste1"},
    {"name": "Esp2", "subtittle": "teste2"},
    {"name": "Esp1", "subtittle": "teste1"},
    {"name": "Esp2", "subtittle": "teste2"},
    {"name": "Esp1", "subtittle": "teste1"},
    {"name": "Esp2", "subtittle": "teste2"},
    {"name": "Esp1", "subtittle": "teste1"},
    {"name": "Esp2", "subtittle": "teste2"},
    {"name": "Esp1", "subtittle": "teste1"},
    {"name": "Esp2", "subtittle": "teste2"},

  ];

  return data.map<Esp>(Esp.fromJson).toList();
}

class Esp {
  final String name;
  final String subtittle;

  const Esp({required this.name, required this.subtittle});

  static Esp fromJson(json) =>
      Esp(name: json['name'], subtittle: json['subtittle']);
}
