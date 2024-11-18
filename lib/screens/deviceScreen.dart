import 'dart:core';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class DeviceScreen extends StatefulWidget {
  final bool start;

  const DeviceScreen({super.key, this.start = true});

  @override
  _CreateDeviceScreen createState() => _CreateDeviceScreen();
}

class _CreateDeviceScreen extends State<DeviceScreen> {
  @override
  void initState() {
    _recuperarDados();
    super.initState();
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

                      _recuperarDados();
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
          setState(() {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AlertDialog(
                  content: AddDevice(),
                );
              },
            ).whenComplete(() {
              _recuperarDados();
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
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
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

    _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
      if (state != BluetoothAdapterState.on) {
        FlutterBluePlus.turnOn();
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
        width: 700,
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
                  setState(() {});
                  Navigator.pop(context);
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
  int code = 0;

  Esp({required this.name, required this.subtittle});

  Esp.conectado(
      {required this.name,
      required this.subtittle,
      required this.conectado,
      required this.code});

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
