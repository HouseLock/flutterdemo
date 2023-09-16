import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterdemo/AppConst.dart';

class ActivationPage extends StatefulWidget {
  final String? dataConfirm;

  ActivationPage({required this.dataConfirm});

  @override
  _ActivationPageState createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  String userEmail = '';
  String token = '';

  @override
  Widget build(BuildContext context) {
    String? data = widget.dataConfirm;
    if (data != null) {
      setParametersFromQueryString(data);
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamedAndRemoveUntil(
            context, ROUTE_HOME, (route) => false);
      });
    }
    if (userEmail.isEmpty || token.isEmpty) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamedAndRemoveUntil(
            context, ROUTE_HOME, (route) => false);
      });
    }
    doActivation();
    Future.delayed(Duration.zero, () {
      Navigator.pushNamedAndRemoveUntil(
          context, ROUTE_REDIRECT, (route) => false,
          arguments: {"fromPage": ROUTE_ACTIVATION});
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Conferma registrazione'),
      ),
    );
  }

  setParametersFromQueryString(String value) {
    value = base64.normalize(value);
    List<int> decodedBytes = base64Url.decode(value);
    String decodedString = utf8.decode(decodedBytes);
    List<String> valueSplit = decodedString.split('|');
    if (valueSplit.isEmpty || valueSplit.length != 2) return;
    userEmail = valueSplit[0];
    token = valueSplit[1];
  }

  void doActivation() async {
    const url = '${API_URL}api/auth/activeuser';
    final uri = Uri.parse(url);
    Map<String, String> bodyPost = {'token': token, 'email': userEmail};
    Map<String, String> headersCall = {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
      'Accept': '*/*'
    };
    try {
      final response = await http.post(uri,
          body: jsonEncode(bodyPost), headers: headersCall);

      if (response.statusCode == 200) {
      } else {
        // Request failed, handle the error
        print('Request failed with status: ${response.statusCode}');
      }
    } on Exception {
      print("Generic error - doUpdatePassword");
    }
  }
}
