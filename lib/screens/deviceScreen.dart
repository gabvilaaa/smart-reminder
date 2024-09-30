import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

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
            color: const Color.fromARGB(255, 223, 219, 219),
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
            color: const Color.fromARGB(255, 223, 219, 219),
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

class AddDevice extends StatelessWidget {
  const AddDevice({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Adiciona padding ao conteúdo
        child: Column(
          mainAxisSize: MainAxisSize.min, // Define o tamanho do Column
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Add Device",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20), // Tamanho da fonte opcional
            ),
            TextButton(
                onPressed: () {},
                child: const Text(
                  "Search Device",
                  textAlign: TextAlign.left ,
                  style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1),),
                )),
          ],
        ),
      ),
    );
  }
}
