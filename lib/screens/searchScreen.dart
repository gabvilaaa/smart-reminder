import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'dart:math';

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
                  color: Color.fromRGBO(Random().nextInt(255),
                    Random().nextInt(255),
                    Random().nextInt(255),
                    Random().nextDouble()),
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