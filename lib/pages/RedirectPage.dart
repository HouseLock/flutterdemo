import 'package:flutter/material.dart';

class RedirectPage extends StatelessWidget {
  final int _secondsToWait = 5;
  @override
  Widget build(BuildContext context) {
    // Delay navigation to the home page by 15 seconds
    Future.delayed(Duration(seconds: _secondsToWait), () {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Redirect Page'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
                'Se la registrazione è avvenuta con successo riceverai una mail all\' indirizzo email fornito.'),
            Text(
                'Sarai reindirizzato alla pagina principale tra $_secondsToWait secondi...'),
            Text('Altrimenti clicca qui:'),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (route) => false);
                },
                child: Text('Login'))
          ],
        ),
      ),
    );
  }
}
