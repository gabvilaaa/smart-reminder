import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/ProviderStore.dart';
import 'addDeviceScreen.dart';
import 'package:projeto_reminder/utils/esp.dart';

class DeviceScreen extends StatefulWidget {
  final bool start;

  const DeviceScreen({super.key, this.start = true});

  @override
  _CreateDeviceScreen createState() => _CreateDeviceScreen();
}

class _CreateDeviceScreen extends State<DeviceScreen> {
  @override
  void initState() {
    super.initState();
    recuperarDados(context);
  }

  Esp espSalvo = Esp(name: "vazio", subtittle: "vazio");
  // List<Esp> espAvaibles = [];



  Future _deletarDados(int code) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("devices/esp$code/nome", "0xVAZIO");
    prefs.remove("devices/esp$code/subtitle");
    setState(() {});
  }

  Future _updateDados(int code, String newName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("devices/esp$code/nome");
    await prefs.setString("devices/esp$code/nome", newName);
    setState(() {});
  }

  Widget _getExpansionTile(int index) {
    return Card(
        color: Colors.greenAccent,
        child: ExpansionTile(
          title: Text(context.read<LoadedEsps>().device[index].name),
          subtitle: Text(context.read<LoadedEsps>().device[index].subtittle),
          trailing: (context.read<LoadedEsps>().device[index].getStatusConection())
              ? const Icon(Icons.check)
              : const Icon(Icons.cancel_outlined),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                (context.read<LoadedEsps>().device[index].getStatusConection())
                    ? const Text("Conectado")
                    : ElevatedButton(
                    onPressed: () {
                      try {
                        setState(() {
                          BluetoothDevice.fromId(
                              context.read<LoadedEsps>().device[index].subtittle)
                              .connect();
                          context.read<LoadedEsps>().device[index].chageStatusConection();
                        });
                      } catch (e) {
                        print("Erro encontrado $e");
                      }
                    },
                    child: Text("Conectar")),
                IconButton(
                  onPressed: () {
                    setState(() {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String newName = "", newSub;
                            return AlertDialog(
                              content: Dialog(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("Novo nome: "),
                                    TextField(
                                      onChanged: (String text) {
                                        setState(() {
                                          newName = text;
                                        });
                                      },
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          _updateDados(
                                              context.read<LoadedEsps>().device[index].code, newName);

                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Salvar"))
                                  ],
                                ),
                              ),
                            );
                          }).whenComplete(() {
                        Future.delayed(const Duration(milliseconds: 500))
                            .whenComplete(() {});
                      });
                      setState(() {});

                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                    onPressed: () async {
                      await _deletarDados(context.read<LoadedEsps>().device[index].code);
                      await recuperarDados(context);
                    },
                    icon: const Icon(Icons.delete))
              ],
            ),
          ],
        ));
  }

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
          Column(
            children: List.generate(context.read<LoadedEsps>().device.length, (index) {

              return ((context.read<LoadedEsps>().device.isNotEmpty)
                  ? _getExpansionTile(index)
                  : const Card());
            }),
          )
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
          ).whenComplete(() {
            recuperarDados(context);

            Future.delayed(const Duration(milliseconds: 500)).whenComplete(() {
              setState(() {});
            });
          });
        },
        child: const Icon(Icons.add),
      ),
    );
    // children: List.generate(espAvaibles.length, (index) {
  }
}
