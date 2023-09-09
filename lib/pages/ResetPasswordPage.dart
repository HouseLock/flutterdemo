import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterdemo/AppConst.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? dataResetPassword;

  ResetPasswordPage({required this.dataResetPassword});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  String userEmail = '';
  String token = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    String? data = widget.dataResetPassword;
    if (data != null) {
      setParametersFromQueryString(data);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, ROUTE_HOME, (route) => false);
    }
    if (userEmail.isEmpty || token.isEmpty) {
      Navigator.pushNamedAndRemoveUntil(context, ROUTE_HOME, (route) => false);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 150,
                    /*decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50.0)),*/
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nuova password',
                    hintText: '',
                    suffixIcon: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Allinea a destra
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          child: Tooltip(
                            message: _isPasswordVisible
                                ? 'Nascondi password'
                                : 'Mostra password',
                            child: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  controller: _passwordController,
                  validator: validatePassword,
                  focusNode: _passwordFocusNode,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Conferma password',
                    hintText: '',
                    suffixIcon: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Allinea a destra
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          child: Tooltip(
                            message: _isConfirmPasswordVisible
                                ? 'Nascondi password'
                                : 'Mostra password',
                            child: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  controller: _confirmPasswordController,
                  validator: validatePassword,
                  focusNode: _confirmPasswordFocusNode,
                ),
              ),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      doUpdatePassword(_passwordController.text,
                          _confirmPasswordController.text);
                      Navigator.pushNamed(context, ROUTE_REDIRECT);
                    } else {
                      // TODO
                    }
                  },
                  child: Text(
                    'Conferma',
                    style: TextStyle(color: Colors.lightBlue, fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
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

  String? validatePassword(String? value) {
    String error = '';
    if (value == null || value.isEmpty) {
      error = 'Inserisci una password';
      return error;
    }
    if (!isPasswordValid(value)) {
      error =
          'La password deve essere di minimo 8 caratteri, contenere almeno una lettera maiuscola, una minuscola, un numero e un carattere speciale.';
      return error;
    }
    return null; // The value is valid
  }

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?\":{}|<>])(?=.{8,20}).*$');
    return passwordRegex.hasMatch(password);
  }

  void doUpdatePassword(String newPw, String confirmPw) async {
    const url = '${API_URL}api/auth/updatepassword';
    final uri = Uri.parse(url);
    Map<String, String> bodyPost = {
      'token': token,
      'email': userEmail,
      'password': newPw,
      'confirmPassword': confirmPw
    };
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
