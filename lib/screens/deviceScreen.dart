import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  _CreateDeviceScreen createState() => _CreateDeviceScreen();
}

class _CreateDeviceScreen extends State<DeviceScreen> {
  Esp espSalvo = new Esp(name: "vazio", subtittle: "vazio", code: 0);
  List<Esp> espAvaibles = [];

  _recuperarDados() async {
    String espName = "Vazio";
    String espSubtittle = "Vazio";
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      int i = 1;
      for (int i = 1; i <= getEsp().length; i++) {
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
          );
        },
        child: const Icon(Icons.add),
      ),
    );
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

  @override
  void initState() {
    super.initState();
    devices = getEsp();
  }

  @override
  Widget build(BuildContext context) {
    String apelido = "";
    return Dialog(
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
              LoadingAnimationWidget.hexagonDots(color: Colors.black, size: 20),
            ]),
            Center(
              child: SizedBox(
                height: 200, // Define uma altura para o ListView
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final espAdded = devices[index];
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
    );
  }
}

List<Esp> getEsp() {
  const data = [
    {"name": "EspCasa", "subtittle": "teste", "code": 1},
    {"name": "EspQuarto", "subtittle": "teste", "code": 2},
    {"name": "EspSala", "subtittle": "teste", "code": 3},
    {"name": "EspCozinha", "subtittle": "teste", "code": 4},
    {"name": "EspBanheiro", "subtittle": "teste", "code": 5},
    {"name": "EspEscritório", "subtittle": "teste", "code": 6},
    {"name": "EspGaragem", "subtittle": "teste", "code": 7},
    {"name": "EspJardim", "subtittle": "teste", "code": 8},
    {"name": "EspVaranda", "subtittle": "teste", "code": 9},
    {"name": "EspLavanderia", "subtittle": "teste", "code": 10},
    {"name": "EspSalaTV", "subtittle": "teste", "code": 11},
    {"name": "EspBiblioteca", "subtittle": "teste", "code": 12},
    {"name": "EspHall", "subtittle": "teste", "code": 13},
    {"name": "EspSótão", "subtittle": "teste", "code": 14},
    {"name": "EspAdega", "subtittle": "teste", "code": 15},
    {"name": "EspPorão", "subtittle": "teste", "code": 16},
  ];
  return data.map<Esp>(Esp.fromJson).toList();
}

class Esp {
  final String name;
  final String subtittle;
  final int code;

  const Esp({required this.name, required this.subtittle, required this.code});

  static Esp fromJson(json) =>
      Esp(name: json['name'], subtittle: json['subtittle'], code: json['code']);

  void salvarEsp(String nickName) async {
    final prefs = await SharedPreferences.getInstance();
    if(nickName.isNotEmpty) {
      await prefs.setString("devices/esp${this.code}/nome", nickName);
    }else{
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
