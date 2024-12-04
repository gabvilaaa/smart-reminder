import 'dart:core';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
    _recuperarDados();
  }

  Esp espSalvo = Esp(name: "vazio", subtittle: "vazio");
  List<Esp> espAvaibles = [];

  Future _recuperarDados() async {
    String espName = "Vazio";
    String espSubtittle = "Vazio";
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      int i = 0;
      int tempInt = 0;

      Esp.getLastCode().asStream().listen((t) {
        tempInt = t;
        for (int i = 0; i <= tempInt; i++) {
          if (prefs.containsKey("devices/esp$i/nome") &&
              prefs.getString("devices/esp$i/nome") != "0xVAZIO") {
            espName = prefs.getString("devices/esp$i/nome") ?? "Vazio";
            espSubtittle = prefs.getString("devices/esp$i/subtitle") ?? "Vazio";

            (espAvaibles.any((esp) => espSubtittle == esp.subtittle))
                ? null
                : espAvaibles.add(Esp.conectado(
                name: espName,
                subtittle: espSubtittle,
                conectado: BluetoothDevice
                    .fromId(espSubtittle)
                    .isConnected,
                code: i));
          }
        }
      });
    });
  }

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
          title: Text(espAvaibles[index].name),
          subtitle: Text(espAvaibles[index].subtittle),
          trailing: (espAvaibles[index].getStatusConection())
              ? const Icon(Icons.check)
              : const Icon(Icons.cancel_outlined),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                (espAvaibles[index].getStatusConection())
                    ? const Text("Conectado")
                    : ElevatedButton(
                    onPressed: () {
                      try {
                        setState(() {
                          BluetoothDevice.fromId(
                              espAvaibles[index].subtittle)
                              .connect();
                          espAvaibles[index].chageStatusConection();
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
                                              espAvaibles[index].code, newName);

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
                      await _deletarDados(espAvaibles[index].code);
                      await _recuperarDados();
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
            children: List.generate(espAvaibles.length, (index) {

              return ((espAvaibles.isNotEmpty)
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
            _recuperarDados();

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
