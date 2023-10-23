import 'package:flutter/material.dart';
import 'package:flutterdemo/AppConst.dart';
import 'package:flutterdemo/models/AuthProvider.dart';
import 'package:provider/provider.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Verifica se l'utente è autenticato
    if (authProvider.isAuthenticated()) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Index Page'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                // Effettua il logout tramite AuthProvider
                authProvider.logout();
                // Naviga indietro alla pagina di login o altrove
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Benvenuto nella pagina di index!'),
              DropdownButton<String>(
                value: 'Option 1', // Valore predefinito
                items: <String>[
                  'Option 1',
                  'Option 2',
                  'Option 3',
                  'Option 4',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Gestisci la selezione dell'elemento nel menu a tendina
                  print('Hai selezionato: $newValue');
                },
              ),
            ],
          ),
        ),
      );
    } else {
      // Se l'utente non è autenticato, reindirizzalo alla pagina di login
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, ROUTE_HOME);
      });

      return Container(); // Puoi restituire un widget vuoto in attesa del reindirizzamento
    }
  }
}
