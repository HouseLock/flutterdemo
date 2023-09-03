import 'dart:convert';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdemo/pages/ForgotPasswordPage.dart';
import 'package:flutterdemo/pages/RedirectPage.dart';
import 'package:flutterdemo/pages/ResetPasswordPage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutterdemo/pages/RegistrationPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'AppConst.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

final storage = FlutterSecureStorage();

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Inizializza il binding
  SystemChannels.textInput
      .invokeMethod('TextInput.hide'); // Chiudi la tastiera al lancio dell'app
  runApp(MyApp());
  setUrlStrategy(PathUrlStrategy());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, String> initialParams = _getInitialParamsFromUrl();
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'CliMan',
        initialRoute: '/',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          if (settings.name!.startsWith(ROUTE_RESET_PW)) {
            // Estrarre i parametri dalla query dell'URL
            final uri = Uri.parse(settings.name as String);
            final dataResetPassword = uri.queryParameters['dataResetPassword'];

            return MaterialPageRoute(
              builder: (context) => ResetPasswordPage(
                dataResetPassword: dataResetPassword,
              ),
            );
          }

          return null; // Gestisci le altre rotte qui se necessario
        },
        routes: {
          ROUTE_HOME: (context) => MyHomePage(),
          ROUTE_REDIRECT: (context) => RedirectPage(),
          ROUTE_REGISTER: (context) => RegistrationPage(),
          ROUTE_FORGOT_PW: (context) => ForgotPasswordPage(),
          ROUTE_RESET_PW: (context) => ResetPasswordPage(
                dataResetPassword: '',
              ),
        },
      ),
    );
  }

  Map<String, String> _getInitialParamsFromUrl() {
    // Recupera l'URL all'avvio dell'app
    final uri = Uri.base;
    return uri.queryParameters;
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  FocusNode _emailFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login"),
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
                  //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: validateEmail,
                    focusNode: _emailFocusNode,
                  )),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Password...'),
                  controller: passwordController,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, ROUTE_FORGOT_PW);
                },
                child: Text(
                  'Password dimenticata',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
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
                      print('Il nome inserito ');
                      doLogin(emailController.text, passwordController.text);
                      Navigator.pushNamed(context, ROUTE_HOME);
                      // TODO navigate to home Navigator.pushNamed(context, '/redirect');
                    } else {
                      _emailFocusNode.requestFocus();
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
              SizedBox(
                height: 130,
              ),
              Container(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, ROUTE_REGISTER);
                  },
                  child: Text(
                    'Nuovo utente? Crea qui il tuo account',
                    style:
                        TextStyle(color: Colors.primaries.first, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Inserisci un indirizzo email';
  }
  if (!isEmailValid(value)) {
    return 'Inserisci un indirizzo email valido';
  }
  return null; // The value is valid
}

bool isEmailValid(String email) {
  final emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
  return emailRegex.hasMatch(email);
}

void doLogin(String email, String password) async {
  String test = email;
  String test2 = password;
  const url = '${API_URL}api/auth/login';
  final uri = Uri.parse(url);
  Map<String, String> bodyPost = {'username': 'admin', 'password': 'password'};
  Map<String, String> headersCall = {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
    'Accept': '*/*'
  };
  final response =
      await http.post(uri, body: jsonEncode(bodyPost), headers: headersCall);

  if (response.statusCode == 200) {
    final body = response.body;
    final json = jsonDecode(body);
    //users = json['results'];
    String accessToken = json['accessToken'];
    String refreshToken = json['refreshToken'];
    // Salva il token di accesso
    await storage.write(key: 'access_token', value: accessToken);

    // Salva il token di aggiornamento
    await storage.write(key: 'refresh_token', value: refreshToken);
  } else {
    // Request failed, handle the error
    print('Request failed with status: ${response.statusCode}');
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          )
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
