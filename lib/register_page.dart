import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:naco_tasktracker/db.dart';
import 'package:naco_tasktracker/main.dart';
import 'package:naco_tasktracker/models/User.dart' as IUser;

class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final double minWidthPixels = 300; // Задайте минимальную ширину поля ввода

  Future<void> registerWithEmailPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Проверяем, что userCredential.user не равно null
      User? user = userCredential.user;
      if (user != null) {
        // Создаем пустой профиль пользователя в Firestore
        DBConverter.addUser(IUser.User(id: user.email!, currentGroups: Set(), currentTasks: Set()));
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error registering: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
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
                  ElevatedButton(onPressed: () => registerWithEmailPassword(context), child: Text('Register'))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
