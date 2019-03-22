import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentUser = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _auth.currentUser().then((user) {
      setState(() {
        _currentUser = user.phoneNumber.toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Welcome User'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _currentUser,
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 24.0),
            RaisedButton(
              elevation: 2.0,
              color: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              textColor: Colors.white.withOpacity(0.9),
              onPressed: _onSignOutButtonClick,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                child: Text(
                  'Sign Out',
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSignOutButtonClick() {
    _auth.signOut().then((_) {
      Navigator.of(context).pushReplacementNamed('/phone');
    });
  }
}
