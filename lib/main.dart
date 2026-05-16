import 'package:flutter/material.dart';
import 'game_page.dart';

void main() {
  runApp(const MainApplication());
}

class MainApplication extends StatelessWidget {
  const MainApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Birdle'),
          ),
        ),
        body: const Center(child: GamePage()),
      ),
    );
  }
}
