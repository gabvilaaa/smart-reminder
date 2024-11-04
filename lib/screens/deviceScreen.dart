import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projeto_reminder/widgets/scan_result_tile.dart';
import 'dart:math';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'scan_screen2.dart';

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

  _recuperarDados() async {
    String espName = "Vazio";
    String espSubtittle = "Vazio";
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      int i = 0;
      int tempInt = 0;

      Esp.getLastCode().asStream().listen((t) {
        tempInt = t;
        for (int i = 0; i <= tempInt; i++) {
          if (prefs.containsKey("devices/esp$i/nome")) {
            espName = prefs.getString("devices/esp$i/nome") ?? "Vazio";
            espSubtittle = prefs.getString("devices/esp$i/subtitle") ?? "Vazio";

            (espAvaibles.any((esp) => espSubtittle == esp.subtittle))
                ? null
                : espAvaibles.add(Esp(name: espName, subtittle: espSubtittle));

            // if((espAvaibles.any((esp) => espSubtittle == esp.subtittle))){
            //
            // }else{
            //   espAvaibles.add(Esp(name: espName, subtittle: espSubtittle));
            //   print("Item adicionado com sucesso");
            // }
          }
        }
      });
    });
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
              return (espAvaibles.isNotEmpty)
                  ? Card(
                      color: Colors.greenAccent,

                      child: ExpansionTile(
                        title: Text(espAvaibles[index].name),
                        subtitle: Text(espAvaibles[index].subtittle),
                        trailing: (espAvaibles[index].getStatusConection())
                            ? const Icon(Icons.check)
                            : const Icon(Icons.cancel_outlined),
                        dense: true,
                        children: [
                          (espAvaibles[index].getStatusConection())
                              ? Text("Conectado")
                              : ElevatedButton(
                                  onPressed: () {
                                    try {
                                      BluetoothDevice.fromId(
                                              espAvaibles[index].subtittle)
                                          .connect();
                                      espAvaibles[index].chageStatusConection();
                                    } catch (e) {
                                      print("Erro encontrado $e");
                                    }
                                    setState(() {});
                                  },
                                  child: Text("Conectar"))
                        ],
                      ),

                      // child: ScanResultTile(result: espAvaibles[index]),
                    )
                  : Card();
            }
                //   return (results.isNotEmpty)
                //       ? Card(
                //     color: Colors.greenAccent,
                //     child: ListTile(
                //       title: Text(results[index].device.name.toString()),
                //       subtitle: Text(results[index].rssi.toString()),
                //       trailing: const Icon(Icons.check),
                //       onTap: () {
                //         // Navigate to episode details
                //       },
                //     ),
                //   )
                //       : Card();
                // }

                ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the AddDevice dialog when the button is pressed
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddDevice();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
    // children: List.generate(espAvaibles.length, (index) {
  }
}

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  List<Esp> devices = [];
  Esp espSelecionado = Esp(name: "name", subtittle: "subtittle");
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  late List<ScanResult> results = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  bool _isScanning = false;

  Future _requestBluetoothPermission() async {
    if (await Permission.bluetooth.isDenied ||
        await Permission.bluetoothConnect.isDenied ||
        await Permission.bluetoothScan.isDenied ||
        await Permission.location.isDenied) {
      await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ].request();
    } else {}
  }

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermission();

    _scanResultsSubscription =
        FlutterBluePlus.scanResults.listen((tempResults) {
      results = tempResults;

      if (mounted) {
        setState(() {});
      }
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future getResults() async {
    await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
        androidScanMode: AndroidScanMode.balanced,
        androidLegacy: false);
    if (mounted) {
      setState(() {});
    }
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return results
        .map(
          (r) => Card(
            child: ListTile(
                title: Text(r.device.advName),
                subtitle: Text(r.device.platformName)),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    String apelido = "";
    return Dialog(
      child: SizedBox(
        height: 900,
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text(
                  "Device List",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
                (FlutterBluePlus.isScanningNow)
                    ? LoadingAnimationWidget.hexagonDots(
                        color: Colors.black, size: 20)
                    : FloatingActionButton(
                        onPressed: getResults,
                        child: const Text("Scan"),
                      ),
              ]),
              Center(
                child: SizedBox(
                  height: 200, // Define uma altura para o ListView
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final espAdded = Esp.deviceToEsp(results[index]);
                      return Card(
                        child: RadioListTile(
                          title: Text(espAdded.name),
                          subtitle: Text(espAdded.subtittle),
                          value: espAdded,
                          groupValue: espSelecionado,
                          onChanged: (Esp? escolhido) {
                            setState(() {
                              espSelecionado = escolhido!;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Text("Digite o apelido:"),
              TextField(
                onChanged: (String text) {
                  apelido = text;
                },
                decoration: const InputDecoration(
                  labelText: 'Nome do dispositivo',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  if (espSelecionado.name != "vazio") {
                    espSelecionado.salvarEsp(apelido);
                  }
                },
                child: const Text("Salvar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Esp {
  final String name;
  final String subtittle;
  bool conectado = false;

  Esp({required this.name, required this.subtittle});

  static Future<int> getLastCode() async {
    final prefs = await SharedPreferences.getInstance();
    int i = 0;

    for (i = 0; prefs.containsKey("devices/esp$i/nome"); i++);
    return i;
  }

  static Esp deviceToEsp(ScanResult temp) {
    return Esp(
      name: temp.device.advName.toString(),
      subtittle: temp.device.remoteId.toString(),
    );
  }

  static Esp fromJson(json) =>
      Esp(name: json['name'], subtittle: json['subtittle']);

  void salvarEsp(String nickName) async {
    int tempInt = 0;
    getLastCode().asStream().listen((t) {
      tempInt = t;
    });
    final prefs = await SharedPreferences.getInstance();

    if (nickName.isNotEmpty) {
      await prefs.setString("devices/esp$tempInt/nome", nickName);
    } else {
      await prefs.setString("devices/esp$tempInt/nome", this.name);
    }
    await prefs.setString("devices/esp$tempInt/subtitle", this.subtittle);
    print("Item salvo com sucesso com o código $tempInt");
  }

  void chageStatusConection() {
    this.conectado = !this.conectado;
  }

  bool getStatusConection() {
    return this.conectado;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Esp &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          subtittle == other.subtittle;

  @override
  int get hashCode => name.hashCode ^ subtittle.hashCode;
}
