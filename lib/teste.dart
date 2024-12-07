import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:projeto_reminder/utils/esp.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'screens/settingsScreen.dart';
import 'screens/calendarScreen.dart';
import 'screens/deviceScreen.dart';
import 'screens/homeScreen.dart';
import 'screens/searchScreen.dart';
import 'utils/ProviderStore.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => LoadedEsps()),
  ], child: const MyApp()));
  // runApp(const DeviceScreen());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    recuperarDados(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reminders App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePageWidget(),
      navigatorObservers: [BluetoothAdapterStateObserver()],
      // home: DeviceScreen(),
    );
  }
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  int _selectedItemPosition = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SafeArea(
        child: _getBody(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SnakeNavigationBar.color(
      behaviour: SnakeBarBehaviour.floating,
      snakeShape: SnakeShape.circle,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      padding: const EdgeInsets.all(12),
      snakeViewColor: Colors.black,
      selectedItemColor: const Color.fromARGB(255, 223, 219, 219),
      unselectedItemColor: Colors.blueGrey,
      currentIndex: _selectedItemPosition,
      onTap: (index) {
        setState(() => _selectedItemPosition = index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Devices'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
    );
  }

  Widget _getBody() {
    switch (_selectedItemPosition) {
      case 0:
        return const SettingsScreen();
      case 1:
        return const CalendarScreen();
      case 2:
        return const HomeScreen();
      case 3:
        return const DeviceScreen();
      case 4:
        return const SearchScreen();
      default:
        return const HomeScreen();
    }
  }
}

class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<BluetoothConnectionState>? _controleState;

  Future _requestBluetoothPermission() async {
    if (await Permission.bluetooth.isDenied ||
        await Permission.bluetoothConnect.isDenied ||
        await Permission.bluetoothScan.isDenied) {
      await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan
      ].request();
    }
  }


  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        // navigator?.pop();
        _requestBluetoothPermission();
        FlutterBluePlus.turnOn();
      }
    });
  }
}
