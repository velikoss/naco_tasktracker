import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:naco_tasktracker/group_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ThemeProvider.dart';
import 'create_group_page.dart';
import 'edit_profile_page.dart';
import 'firebase_options.dart';
import 'signIn_page.dart';
import 'register_page.dart';
import 'home_page.dart'; // Создайте этот файл для домашней страницы
import 'models/User.dart' as IUser;

typedef ID = String;

late SharedPreferences prefs;

late User? myCurrentUser;
late IUser.User? dbUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance(); // Инициализация SharedPreferences
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyAppWrapper()); // Запускаем обертку для MyApp
}

class MyAppWrapper extends StatelessWidget {
  // Этот виджет является корнем вашего приложения.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(isDarkMode: prefs.getBool('darkMode') ?? false),
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      theme: themeProvider.themeData.copyWith(
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.black, displayColor: Colors.black, fontFamily: 'system-ui'),
      ),
      darkTheme: themeProvider.themeData.copyWith(
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white, fontFamily: 'system-ui'),
      ),
      themeMode: ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            myCurrentUser = snapshot.data;
            if (myCurrentUser == null) {
              return SignInPage();
            }
            return HomePage();
          }
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
      routes: {
        '/login': (context) => SignInPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/edit_profile': (context) => EditProfilePage(), // Добавьте новый маршрут
        '/create_group': (context) => CreateGroupPage(),
        '/group': (context) => GroupPage(groupId: "sosi)))"),
      },
    );
  }
}
