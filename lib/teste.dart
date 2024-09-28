import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reminders App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePageWidget(),
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
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
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
        return const PodcastsScreen();
      case 4:
        return const SearchScreen();
      default:
        return const HomeScreen();
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Your Reminders',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                color: const Color.fromARGB(255, 223, 219, 219),

                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Reminder ${index + 1}'),
                  subtitle: Text('This is a reminder description.'),
                  trailing: Icon(Icons.notifications_active),
                  onTap: () {
                    // Navigate to a detailed reminder page
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // User Account Section
          const Text(
            'User Account',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildUserProfile(context),
          const SizedBox(height: 20),

          // Settings Options
          const Text(
            'Settings Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: true,
            onChanged: (value) {
              // Update notification settings
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: false,
            onChanged: (value) {
              // Update theme settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 223, 219, 219),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage('https://img.olympics.com/images/image/private/t_1-1_300/f_auto/v1687307644/primary/cqxzrctscdr8x47rly1g'),
        ),
        title: const Text('Lionel Messi', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('lionel@gmail.com'),
        trailing: const Icon(Icons.edit),
        onTap: () {
          // Navigate to edit profile screen
        },
      ),
    );
  }
}


class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),  
    
      child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Events',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color.fromARGB(255, 223, 219, 219),
            elevation: 5,
            child: ListTile(
              title: const Text('Meeting with team'),
              subtitle: const Text('Tomorrow at 10:00 AM'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                // Navigate to event details
              },
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: const Color.fromARGB(255, 223, 219, 219),
            elevation: 5,
            child: ListTile(
              title: const Text('Project Deadline'),
              subtitle: const Text('Due by end of the week'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                // Navigate to event details
              },
            ),
          ),
        ],
      ),
    ),
  );
  }
}

class PodcastsScreen extends StatelessWidget {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Devices',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Card(
          color: const Color.fromARGB(255, 223, 219, 219),
          child: ListTile(
            title: const Text('ESP-32 Room'),
            subtitle: const Text('Active'),
            trailing: const Icon(Icons.check),
            onTap: () {
              // Navigate to episode details
            },
          ),
        ),
        Card(
          color: const Color.fromARGB(255, 223, 219, 219),
          child: ListTile(
            title: const Text('ESP-32 Office'),
            subtitle: const Text('Description '),
            trailing: const Icon(Icons.check),
            onTap: () {
              // Navigate to episode details
            },
          ),
        ),
      ],
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Search',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'Search...',
              border: OutlineInputBorder(),
              suffixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color.fromARGB(255, 223, 219, 219),
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Search Result ${index + 1}'),
                    onTap: () {
                      // Handle search result tap
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
