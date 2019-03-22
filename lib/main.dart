import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_auth/flutter_phone_auth.dart';
import 'package:flutter_phone_auth/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      routes: {
        '/phone': (context) => FlutterPhoneAuth(),
        '/home': (context) => HomeScreen(),
      },
      home: FutureBuilder(
        initialData: false,
        future: _isUserLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return snapshot.data ? HomeScreen() : FlutterPhoneAuth();
        },
      ),
    );
  }

  Future<bool> _isUserLoggedIn() async {
    return await _auth.currentUser().then((user) {
      if (user != null) {
        return true;
      } else
        return false;
    });
  }
}
