import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProviderStore.dart';
//
class Esp{
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

Future recuperarDados(BuildContext context) async {
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

        (context.read<LoadedEsps>().device.any((esp) => espSubtittle == esp.subtittle))
            ? null
            : context.read<LoadedEsps>().addDevices(Esp.conectado(
            name: espName,
            subtittle: espSubtittle,
            conectado: BluetoothDevice
                .fromId(espSubtittle)
                .isConnected,
            code: i));
      }
    }
  });

}