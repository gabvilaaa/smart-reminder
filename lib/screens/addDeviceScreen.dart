import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';

import 'package:projeto_reminder/utils/esp.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  Esp espSelecionado = Esp("name", "subtittle");
  final BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
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
    }
  }

  Future _connectBlue() async{

    if(FlutterBluePlus.adapterStateNow == BluetoothAdapterState.off){
      await FlutterBluePlus.turnOn();
    }

  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    _requestBluetoothPermission();

    _connectBlue();

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
    FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
        androidScanMode: AndroidScanMode.balanced,
        androidLegacy: false);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String apelido = "";
    final TextEditingController _textFieldKey = TextEditingController();
    return Dialog(
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
              height: 550,
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Add Device",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
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
              SizedBox(
                height: (MediaQuery.of(context).size.height>600)?250:100,
                
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
              const Text("Digite o apelido:"),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _textFieldKey,
                onChanged: (String text) {
                  apelido = text;
                },
                decoration: const InputDecoration(
                  labelText: 'Nome do dispositivo',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              FloatingActionButton(

                onPressed: () {

                  if (espSelecionado.name != "vazio") {
                  _textFieldKey.text ="";
                    espSelecionado.salvarEsp(apelido);

                  }
                  Navigator.of(context).pop("update");
                },
                child: const Text("Salvar"),

              )
            ],
          ))),
    );
  }
}
