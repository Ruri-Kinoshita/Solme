import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConceptPage extends StatelessWidget {
  const ConceptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BeforeCamera')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Concept',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/bunsin'),
              child: const Text('次へ'),
            ),
          ],
        ),
      ),
    );
  }
}
