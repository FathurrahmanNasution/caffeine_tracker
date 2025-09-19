import 'package:flutter/material.dart';

class TrackerPage extends StatelessWidget {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Caffeine Tracker"),
        backgroundColor: Colors.brown,
      ),
      body: const Center(
        child: Text(
          "Welcome to your tracker!\n(Here we will show caffeine stats)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
