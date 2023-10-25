import 'package:bronco_bond/src/screens/signup.dart';
import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
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
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
              },
              child: const Text('Go to Sign Up Page'),
            ),
          ],
        ),
      ),
    );
  }
}