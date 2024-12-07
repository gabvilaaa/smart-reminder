import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProviderStore.dart';
//
class Esp{
  late final String name;
  late final String subtittle;
  late BluetoothDevice _localDevice;
  bool conectado = false;
  int code = 0;
  BluetoothCharacteristic? characteristic;
  List<BluetoothService> services = [];

  // Esp({required this.name, required this.subtittle})
  //     : _localDevice = BluetoothDevice.fromId(subtittle);
  Esp(String nam, String sub){
    this.name = nam; this.subtittle = sub;
  }

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
      temp.device.advName.toString(),
      temp.device.remoteId.toString(),
    );
  }

  void salvarEsp(String nickName) async {
    int tempInt = 0;
    getLastCode().asStream().listen((t) {
      tempInt = t;
    });
    final prefs = await SharedPreferences.getInstance();

    Future.delayed(const Duration(milliseconds:500 ), () async {
      if (nickName.isNotEmpty) {
        await prefs.setString("devices/esp$tempInt/nome", nickName);
      } else {
        await prefs.setString("devices/esp$tempInt/nome", this.name);
      }
      await prefs.setString("devices/esp$tempInt/subtitle", this.subtittle);
      print("Item salvo com sucesso com o código $tempInt");
    });

  }

  void chageStatusConection() {
    this.conectado = !this.conectado;
  }

  bool getStatusConection() {
    _localDevice = BluetoothDevice.fromId(subtittle);
    return _localDevice.isConnected;
  }

  BluetoothConnectionState getConectionState(){
    _localDevice = BluetoothDevice.fromId(subtittle);
    dynamic temp;
    _localDevice.connectionState.listen((data){
      temp = data;
    });
    return temp;
  }

  Future writeText(String indicador,String text, BuildContext context) async {
    try {
      await characteristic?.write(indicador.codeUnits+text.codeUnits);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao enviar texto!')),
      );
      throw e;
    }
    print("Data enviado ${text.codeUnits}");
  }

  Future writeListText(String indicador, List<String> text,String caracterSep, BuildContext context) async {
    text.insert(0, indicador);
    String code = text.join(caracterSep).toString();

    try {
      await characteristic?.write(code.codeUnits);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao enviar texto!')),
      );
      throw e;
    }
    print("Data enviado ${code.codeUnits}");
  }


  Future getServices() async {
    _localDevice = BluetoothDevice.fromId(subtittle);
    try {
      await _localDevice.clearGattCache();
      services = await _localDevice.discoverServices(timeout: 5000);
    } catch (e) {
      print("Erro encontrado: " + e.toString());
    }
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.uuid.toString() == "6a1981ae-6033-456a-88a9-a0d6b3eab72f") {
          // UUID correto
          characteristic = c;
          break;
        }
      }
    }

    if (characteristic == null) {
      print("Erro: Characteristic não encontrada.");
    }
  }

  Future<void> connectBluetooth(BuildContext context) async {
    _localDevice = BluetoothDevice.fromId(subtittle);
    try {
      await _localDevice.connect().whenComplete;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao enviar texto!')),
      );
    }
    await getServices();
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

Future recuperarDados(BuildContext context) async {
  context.read<LoadedEsps>().device.clear();
  String espName = "Vazio";
  String espSubtittle = "Vazio";
  final prefs = await SharedPreferences.getInstance();

  int i = 0;
  int tempInt = 0;

  Esp.getLastCode().asStream().listen((t) {
    tempInt = t;
    for (int i = 0; i <= tempInt; i++) {
      if (prefs.containsKey("devices/esp$i/nome") &&
          prefs.getString("devices/esp$i/nome") != "0xVAZIO") {
        espName = prefs.getString("devices/esp$i/nome") ?? "Vazio";
        espSubtittle = prefs.getString("devices/esp$i/subtitle") ?? "Vazio";
        print("Novo nome$espName" );
        (context.read<LoadedEsps>().device.any((esp) => espSubtittle == esp.subtittle))
            ? null
            : context.read<LoadedEsps>().addDevices(Esp.conectado(
            name: espName,
            subtittle: espSubtittle,
            conectado: BluetoothDevice
                .fromId(espSubtittle)
                .isConnected,
            code: i));
        for(Esp e in context.read<LoadedEsps>().device)
        print("Elemento atualizado ${e.name}");
      }
    }
    context.read<LoadedEsps>().update();
  });

}