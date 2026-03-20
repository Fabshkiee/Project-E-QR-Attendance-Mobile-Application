import 'package:flutter/material.dart';

class StaffAuthorizationPage extends StatelessWidget {
  const StaffAuthorizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Authorization'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is the Staff Authorization Page'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/success');
              },
              child: const Text('Authorize & Register'),
            ),
          ],
        ),
      ),
    );
  }
}
