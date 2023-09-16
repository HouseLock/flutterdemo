import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterdemo/AppConst.dart';

import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String _message = '';

  Future<void> _resetPassword() async {
    final email = _emailController.text;
    const url = '${API_URL}api/auth/forgotpassword';
    final uri = Uri.parse(url);
    Map<String, String> bodyPost = {'email': email};
    Map<String, String> headersCall = {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
      'Accept': '*/*'
    };
    try {
      final response = await http.post(uri,
          body: jsonEncode(bodyPost), headers: headersCall);

      if (response.statusCode == 200) {
        Future.delayed(Duration.zero, () {
          Navigator.pushNamedAndRemoveUntil(
              context, ROUTE_REDIRECT, (route) => false,
              arguments: {"fromPage": ROUTE_FORGOT_PW});
        });
      } else {
        setState(() {
          _message =
              'Errore durante il recupero della password. Riprova più tardi.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Si è verificato un errore. Riprova più tardi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recupero Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Indirizzo Email',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text('Recupera Password'),
            ),
            SizedBox(height: 16.0),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
