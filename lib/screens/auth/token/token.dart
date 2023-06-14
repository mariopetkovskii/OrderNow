import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';

class TokenDisplayScreen extends StatefulWidget {
  const TokenDisplayScreen({Key? key}) : super(key: key);

  @override
  _TokenDisplayScreenState createState() => _TokenDisplayScreenState();
}

class _TokenDisplayScreenState extends State<TokenDisplayScreen> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      _token = token;
    });
  }

  void _logout() async {	
  final prefs = await SharedPreferences.getInstance();	
  await prefs.remove('token');
  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: 'Dart',)),
                  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Token Display Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: _token != null
            ? Text('Token: $_token')
            : CircularProgressIndicator(),
      ),
    );
  }
}