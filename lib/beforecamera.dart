import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BeforeCameraPage extends StatelessWidget {
  const BeforeCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BeforeCamera')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BeforeCamera',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/camera'),
              child: const Text('次へ'),
            ),
          ],
        ),
      ),
    );
  }
}
