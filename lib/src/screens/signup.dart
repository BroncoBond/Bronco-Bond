import 'package:bronco_bond/src/screens/interests.dart';
import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Page'),
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
                  MaterialPageRoute(builder: (context) => const InterestsPage()),
                );
              },
              child: const Text('Go to Interests Page'),
            ),
          ],
        ),
      ),
    );
  }
}