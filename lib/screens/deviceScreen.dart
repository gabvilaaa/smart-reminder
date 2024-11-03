import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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
  }

  Esp espSalvo = const Esp(name: "vazio", subtittle: "vazio", code: 0);
  List<Esp> espAvaibles = [];

  _recuperarDados() async {
    String espName = "Vazio";
    String espSubtittle = "Vazio";
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      int i = 1;
      for (int i = -100; i <= 100; i++) {
        if (prefs.containsKey("devices/esp$i/nome")) {
          espName = prefs.getString("devices/esp$i/nome") ?? "Vazio";
          espSubtittle = prefs.getString("devices/esp$i/subtitle") ?? "Vazio";
          (espAvaibles.any((esp) => esp.code == i))
              ? null
              : espAvaibles
                  .add(Esp(name: espName, subtittle: espSubtittle, code: i));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool primeiroAcesso = true;
    if (primeiroAcesso) {
      _recuperarDados();
      primeiroAcesso = false;
    }

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
                      child: ListTile(
                        title: Text(espAvaibles[index].name),
                        subtitle: Text(espAvaibles[index].subtittle),
                        trailing: const Icon(Icons.check),
                        onTap: () {
                          // Navigate to episode details
                        },
                      ),
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
  Esp espSelecionado = const Esp(name: "name", subtittle: "subtittle", code: 0);
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
  final int code;

  const Esp({required this.name, required this.subtittle, required this.code});

  static Future<int> getLastCode() async{
    final prefs = await SharedPreferences.getInstance();
    int i=0;
    for(i =0; prefs.getString("devices/esp$i/nome")!.isNotEmpty;i++ );
    return i;
  }

  static Esp deviceToEsp(ScanResult temp) {
    int tempCode = getLastCode();
    return Esp(
        name: temp.device.advName.toString(),
        subtittle: temp.device.remoteId.toString(),
        code: temp.rssi);
  }

  static Esp fromJson(json) =>
      Esp(name: json['name'], subtittle: json['subtittle'], code: json['code']);

  void salvarEsp(String nickName) async {
    final prefs = await SharedPreferences.getInstance();
    if (nickName.isNotEmpty) {
      await prefs.setString("devices/esp${this.code}/nome", nickName);
    } else {
      await prefs.setString("devices/esp${this.code}/nome", this.name);
    }
    await prefs.setString("devices/esp${this.code}/subtitle", this.subtittle);
    print("Item salvo com sucesso com o código ${this.code}");
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Esp &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name &&
          subtittle == other.subtittle;

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ subtittle.hashCode;
}
