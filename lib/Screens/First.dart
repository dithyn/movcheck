import 'package:flutter/material.dart';

class First extends StatefulWidget {
  const First({super.key});
  @override
  State<First> createState() => _FirstState();
}

class _FirstState extends State<First> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First Screen')),
      body: Center(
        child: Text(
          'Welcome to the First Screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
