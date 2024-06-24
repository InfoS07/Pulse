import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModalePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modale Page'),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false, // Hides the back button
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'This is a modale page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
