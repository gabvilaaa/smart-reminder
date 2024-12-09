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
  BluetoothDevice _localDevice = BluetoothDevice.fromId("remoteId");
  bool conectado = false;
  int code = 0;
  BluetoothCharacteristic? characteristic;
  List<BluetoothService> services = [];

  // Esp({required this.name, required this.subtittle})
  //     : _localDevice = BluetoothDevice.fromId(subtittle);
  Esp(String nam, String sub){
    this.name = nam; this.subtittle = sub;
    _localDevice= BluetoothDevice.fromId(this.subtittle);
  }

  Esp.conectado(String n, String s, bool c, int co){
    this.name =n ;
    this.subtittle = s;
    this.conectado = c;
    this.code= co;
    _localDevice= BluetoothDevice.fromId(this.subtittle);
  }

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
    // _localDevice ?? BluetoothDevice.fromId(subtittle);
    // _localDevice.connectionState.listen((data){
    //   return data;
    // });

    return _localDevice.isConnected;
  }

  BluetoothConnectionState getConectionState(){
    // _localDevice ?? BluetoothDevice.fromId(subtittle);
    dynamic temp;
    _localDevice.connectionState.listen((data){
      temp = data;
    });
    return temp;
  }

  Future writeText(String indicador,String text, BuildContext context) async {
    characteristic??getServices();
    Future.delayed(const Duration(milliseconds: 1000));
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
    characteristic??getServices().whenComplete(() async {
      try {
        await characteristic?.write(code.codeUnits);
      } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Falha ao enviar texto!')),
      );
      throw e;
      }
    });


    try {
      await characteristic?.write(code.codeUnits);
      print("Data enviado ${code.codeUnits}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao enviar texto!')),
      );
      throw e;
    }

  }

  Future getServices() async {
    // _localDevice ??BluetoothDevice.fromId(subtittle);


    try {
        await _localDevice.clearGattCache();
        services = (await _localDevice.discoverServices(timeout: 5000));
    } catch (e) {
      print("Erro encontrado: " + e.toString());
    }
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.properties.write) {
          print("Characteristic encontrado: ${c.uuid.toString()}");
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
    // _localDevice ?? BluetoothDevice.fromId(subtittle);
    try {
      await _localDevice.connect().whenComplete((){
        print("Realmente Conectado");
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao enviar texto!')),
      );
    }
    characteristic??await getServices().whenComplete((){
        print([
          DateTime.now().year.toString(),
          DateTime.now().month.toString().padLeft(2, '0'),
          DateTime.now().day.toString().padLeft(2, '0'),
          DateTime.now().hour.toString().padLeft(2, '0'),
          DateTime.now().minute.toString().padLeft(2, '0'),
          DateTime.now().second.toString().padLeft(2, '0'),
        ].toString());
        this.writeListText("updateTime", [
          DateTime.now().year.toString(),
          DateTime.now().month.toString().padLeft(2, '0'),
          DateTime.now().day.toString().padLeft(2, '0'),
          DateTime.now().hour.toString().padLeft(2, '0'),
          DateTime.now().minute.toString().padLeft(2, '0'),
          DateTime.now().second.toString().padLeft(2, '0'),
        ], "@", context);
    });

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
             espName,
             espSubtittle,
             BluetoothDevice
                .fromId(espSubtittle)
                .isConnected,
             i));
        for(Esp e in context.read<LoadedEsps>().device)
        print("Elemento atualizado ${e.name}");
      }
    }
    context.read<LoadedEsps>().update();
  });

}