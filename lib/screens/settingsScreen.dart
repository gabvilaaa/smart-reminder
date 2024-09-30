import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

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

