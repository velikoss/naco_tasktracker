import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final double minWidthPixels = 300; // Задайте минимальную ширину поля ввода
  // Добавьте контроллеры и переменные для других полей...

  Future<void> updateProfile(BuildContext context) async {
    final CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      await users.doc(user?.uid).update({
        'name': nameController.text,
        'surname': surnameController.text,
        // Добавьте обновления для других полей...
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Edit profile')),
        body: LayoutBuilder(
        builder: (context, constraints)
    {
      double inputWidth = constraints.maxWidth > minWidthPixels * 3
          ? constraints.maxWidth / 3
          : minWidthPixels;
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: minWidthPixels, maxWidth: inputWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 40), // Здесь может быть аватар пользователя
              SizedBox(height: 20),
              TextField(controller: nameController,
                  decoration: InputDecoration(labelText: 'Name')),
              SizedBox(height: 20),
              TextField(controller: surnameController,
                  decoration: InputDecoration(labelText: 'Surname')),
              // Добавьте другие поля для редактирования...
              SizedBox(height: 20),
              ElevatedButton(onPressed: () => updateProfile(context),
                  child: Text('Update Profile'))
            ],
          ),
        ),
      );
    }),);
  }
}
