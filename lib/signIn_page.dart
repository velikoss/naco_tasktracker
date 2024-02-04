import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final double minWidthPixels = 300; // Минимальная ширина поля ввода

  Future<void> signInWithEmailPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error signing in: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double inputWidth = constraints.maxWidth > minWidthPixels * 3 ? constraints.maxWidth / 3 : minWidthPixels;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidthPixels, maxWidth: inputWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
                  SizedBox(height: 20),
                  TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: () => signInWithEmailPassword(context), child: Text('Sign In')),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/register'),
                    child: Text('Don\'t have an account? Register'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
