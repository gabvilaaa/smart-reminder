import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'esp.dart';

class LoadedEsps with ChangeNotifier{
  List<Esp> device = [];
  List<bool> values = [];

  valuesCreate(){
    values = List.generate(
      100,
          (index) => false,
    );
    print("values criado");
    notifyListeners();
  }

  addValues(int index, bool v){
    values[index] = v;
    notifyListeners();
  }

  addDevices(Esp d){
    this.device.add(d);
    notifyListeners();
  }
  clearList(){
    device.clear();
    notifyListeners();
  }
  updateDevice(Esp old, Esp ne) {
    final index = this.device.indexOf(old);
    if (index != -1) {

      this.device[index] = ne;
    } else {

      this.device.add(ne);
    }
    notifyListeners();
  }

  update(){
    notifyListeners();
  }

}