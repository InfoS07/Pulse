import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModalePage extends StatelessWidget {
  const ModalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modale Page'),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false, // Hides the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'This is a modale page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
