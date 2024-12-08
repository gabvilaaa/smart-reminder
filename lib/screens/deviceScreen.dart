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
  Esp espSalvo = Esp("vazio", "vazio");

  List<Esp> espAvaibles = [Esp("NAD", "NADA")];

  @override
  void initState() {
    super.initState();
    recuperarDados(context);
  }

  @override
  void didChangeDependencies() async {
    espAvaibles = context.watch<LoadedEsps>().device;
    super.didChangeDependencies();
  }

  Future _deletarDados(int code) async {
    final prefs = await SharedPreferences.getInstance();
    (BluetoothDevice.fromId(
                prefs.getString("devices/esp$code/subtitle").toString())
            .isConnected)
        ? BluetoothDevice.fromId(
                prefs.getString("devices/esp$code/subtitle").toString())
            .disconnect()
        : null;
    Future.delayed(const Duration(milliseconds: 500));
    await prefs.setString("devices/esp$code/nome", "0xVAZIO");
    await prefs.remove("devices/esp$code/subtitle").whenComplete(() {
      recuperarDados(context);
      Future.delayed(const Duration(milliseconds: 500)).whenComplete(() {
        setState(() {});
      });
    });
  }

  Future _updateDados(int code, String newName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("devices/esp$code/nome");
    await prefs.setString("devices/esp$code/nome", newName).whenComplete(() {
      recuperarDados(context);
      Future.delayed(const Duration(milliseconds: 500)).whenComplete(() {
        setState(() {});
      });
    });
  }

  Widget _conectDevice(int index) {

    if (context.read<LoadedEsps>().device[index].getStatusConection()) {
      return const Icon(Icons.check);
    } 
    else {
      try {
        context.read<LoadedEsps>().device[index].connectBluetooth(context).whenComplete((){
          context.read<LoadedEsps>().update();

        });
        // context.read<LoadedEsps>().connectDevice(index, context);
        return const Icon(Icons.downloading);
      } catch (e) {
        return const Icon(Icons.cancel_outlined);
      }
    }
    // else if( statusConexao == BluetoothConnectionState.connecting){
    //   return const Icon(Icons.downloading);
    // }
  }

  Widget _getExpansionTile(int index, VoidCallback onUpdate) {
    return Card(
        color: Colors.greenAccent,
        child: ExpansionTile(
          title: Text(espAvaibles[index].name),
          subtitle: Text(espAvaibles[index].subtittle),
          trailing: _conectDevice(index),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                                              context
                                                  .read<LoadedEsps>()
                                                  .device[index]
                                                  .code,
                                              newName);
                                          setState(() {
                                            Future.delayed(const Duration(
                                                    milliseconds: 500))
                                                .whenComplete(() {
                                              // recuperarDados(context);
                                            });
                                          });
                                          onUpdate();

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
                      await recuperarDados(context);
                      setState(() {
                        recuperarDados(context);
                        Future.delayed(const Duration(milliseconds: 500))
                            .whenComplete(() {
                          setState(() {});
                        });
                      });
                      onUpdate();
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
                  ? _getExpansionTile(index, () {
                      setState(() {

                      });
                    })
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
