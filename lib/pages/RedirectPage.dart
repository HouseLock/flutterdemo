import 'package:flutter/material.dart';
import 'package:flutterdemo/AppConst.dart';

class RedirectPage extends StatefulWidget {
  final String? fromPage;

  RedirectPage({required this.fromPage});

  @override
  _RedirectPageState createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage> {
  final int _secondsToWait = 5;
  @override
  Widget build(BuildContext context) {
    if (_secondsToWait > 0) {
      Future.delayed(Duration(seconds: _secondsToWait), () {
        Navigator.pushNamedAndRemoveUntil(
            context, ROUTE_HOME, (route) => false);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Redirect Page'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(widget.fromPage!),
            Text(
                'Se la registrazione è avvenuta con successo riceverai una mail all\' indirizzo email fornito.'),
            Text(
                'Sarai reindirizzato alla pagina principale tra $_secondsToWait secondi...'),
            Text('Altrimenti clicca qui:'),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, ROUTE_HOME, (route) => false);
                },
                child: Text('Login'))
          ],
        ),
      ),
    );
  }
}
