import 'package:flutter/material.dart';
import 'package:flutterdemo/AppConst.dart';

class RedirectPage extends StatefulWidget {
  @override
  _RedirectPageState createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage> {
  final int _secondsToWait = 5;
  @override
  Widget build(BuildContext context) {
    final Map<String, String>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    if (args == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamedAndRemoveUntil(
            context, ROUTE_HOME, (route) => false);
      });

      return Scaffold(
        appBar: AppBar(
          title: Text('Redirect Page'),
        ),
        body: Center(),
      );
    } else {
      final fromPage = args['fromPage'];
      String textToShow = '';
      if (fromPage == ROUTE_ACTIVATION) {
        textToShow =
            'Account attivato correttamente, adesso potrai effettuare il login.';
      } else if (fromPage == ROUTE_REGISTER) {
        textToShow =
            'Se la registrazione è avvenuta con successo riceverai una mail all\' indirizzo email fornito.';
      } else if (fromPage == ROUTE_FORGOT_PW) {
        textToShow =
            'Un link per il recupero della password è stato inviato al tuo indirizzo email.';
      } else if (fromPage == ROUTE_RESET_PW) {
        textToShow =
            'Password aggiornata correttamente, adesso potrai effettuare il login con la nuova password.';
      }

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
              Text(textToShow),
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
}
