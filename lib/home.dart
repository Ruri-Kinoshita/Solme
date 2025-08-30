import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Home',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
