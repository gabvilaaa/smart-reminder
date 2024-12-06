import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'esp.dart';

class LoadedEsps with ChangeNotifier{
  List<Esp> device = [];


  addDevices(Esp d){
    this.device.add(d);
    notifyListeners();
  }


}