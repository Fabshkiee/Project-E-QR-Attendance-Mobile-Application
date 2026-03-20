import 'package:flutter/material.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project-E Scanner'),
      ),
      body: const Center(
        child: Text('This is the QR Scanner Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/registration');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
