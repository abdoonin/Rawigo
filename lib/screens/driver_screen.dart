import 'package:flutter/material.dart';
//لازم اخليها تظهر  للسواق فقط

class DriverScreen extends StatelessWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Driver Screen!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin-orders');
              },
              child: const Text('Go to Admin Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
