import 'package:bronco_bond/src/screens/welcome_page.dart';
import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('This is another page.'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SigninPage()),
                );
              },
              child: const Text('Go to Sign-Up Page'),
            ),
          ],
        ),
      ),
    );
  }
}
