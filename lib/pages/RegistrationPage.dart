import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterdemo/models/Sector.dart';
import 'package:flutterdemo/models/User.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class MyAppState extends ChangeNotifier {}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _pecController = TextEditingController();
  final TextEditingController _taxIDCodeController = TextEditingController();
  final TextEditingController _vatNumberController = TextEditingController();
  final TextEditingController _sdiController = TextEditingController();

  List<Sector> _selectedSectors = [];

  User user = User();

  int _currentStep = 0;
  List<Step> _steps = List.empty();
  int _currAppRole = -1;

  List<Sector> _sectors = List.empty();

  void _onStepTabbed(int stepSelected) {
    if (_currentStep != stepSelected) {
      if (stepSelected < _steps.length) {
        setState(() => _currentStep = stepSelected);
      }
    }
  }

  void _onStepContinue() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep += 1);
    } else {
      // Final step: Register user
      setState(() {
        user.name = _nameController.text;
        user.surname = _surnameController.text;
        user.email = _emailController.text;
        user.password = _passwordController.text;
        user.businessName = _businessNameController.text;
        user.pec = _pecController.text;
        user.taxIDCode = _taxIDCodeController.text;
        user.vatNumber = _vatNumberController.text;
        user.sdi = _sdiController.text;

        // Print user data (for demonstration purposes)
        print(user.toJson());
      });
      // Here you can proceed with further actions, e.g., saving the user data or navigating to a new page.
    }
  }

  void _onClientClick() {
    if (_currAppRole != 0) {
      setState(() => _currAppRole = 0);
    }
  }

  void _onManutentorClick() {
    if (_currAppRole != 1) {
      setState(() => _currAppRole = 1);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Container _controlsBuilder(BuildContext context, ControlsDetails details) {
    final _isLastStep = _currentStep == _steps.length - 1;
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Expanded(
            child: ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(_isLastStep ? 'Registrati' : 'Avanti'))),
        const SizedBox(
          width: 12,
        ),
        if (_currentStep != 0)
          Expanded(
              child: ElevatedButton(
                  onPressed: details.onStepCancel, child: Text('Indietro')))
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var stepper = Stepper(
      currentStep: _currentStep,
      onStepContinue: _onStepContinue,
      onStepCancel: _onStepCancel,
      onStepTapped: _onStepTabbed,
      controlsBuilder: _controlsBuilder,
      steps: [
        Step(
            title: Text('Step 1'),
            content: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _currAppRole = 0);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        _currAppRole == 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text('Cliente'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _currAppRole = 1);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        _currAppRole == 1 ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text('Manutentore'),
                  ),
                ),
              ],
            ),
            subtitle: Text('Ruolo')),
        Step(
          title: Text('Step 2'),
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nome',
                    hintText: '',
                  ),
                  controller: _nameController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Cognome',
                      hintText: ''),
                  controller: _surnameController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Codice Fiscale',
                      hintText: ''),
                  controller: _taxIDCodeController,
                ),
              ),
            ],
          ),
          subtitle: Text('Dati personali'),
        ),
        Step(
          title: Text('Step 3'),
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'P.Iva',
                    hintText: '',
                  ),
                  controller: _vatNumberController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'SDI',
                    hintText: '',
                  ),
                  controller: _sdiController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ragione sociale',
                      hintText: ''),
                  controller: _businessNameController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Pec',
                      hintText: ''),
                  controller: _pecController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: MultiSelectChipDisplay<Sector>(
                  items: _builderSectors(),
                  //textStyle: _selectedSectors.contains(this) ? TextStyle(color: Colors.blue) : TextStyle(color: Colors.yellow),
                  onTap: (sectorPressed) {
                    if (!_selectedSectors
                        .map((e) => e.sectorCode)
                        .contains(sectorPressed.sectorCode)) {
                      setState(() {
                        _selectedSectors.add(sectorPressed);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          subtitle: Text('Dati aziendali'),
        ),
        Step(
          title: Text('Step 4'),
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: ''),
                  controller: _emailController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: ''),
                  controller: _passwordController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Conferma password',
                      hintText: ''),
                  controller: _confirmPasswordController,
                ),
              ),
            ],
          ),
          subtitle: Text('Dati generali'),
        ),
      ],
    );
    _steps = stepper.steps;
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrazione'),
      ),
      body: FutureBuilder<List<Sector>>(
        future: getSectors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Visualizza uno spinner di caricamento durante l'attesa del Future
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Gestisce gli errori se si verificano durante il recupero dei dati
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Sector> sectors = snapshot.data!;
            _sectors = sectors;
            return GestureDetector(
              onTap: () {
                // Chiudi la tastiera quando l'utente tocca al di fuori del campo di input
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: stepper,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  List<MultiSelectItem<Sector>> _builderSectors() {
    return _sectors
        .map((sector) => MultiSelectItem<Sector>(sector, sector.sectorCode))
        .toList();
  }

  Future<List<Sector>> getSectors() async {
    const url = 'http://localhost:8080/api/sector/findall';
    final uri = Uri.parse(url);
    Map<String, String> headersCall = {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
      'Accept': '*/*'
    };
    final response = await http.get(uri, headers: headersCall);

    if (response.statusCode == 200) {
      final body = response.body;
      final json = jsonDecode(body);
      List<Sector> sectors = [];
      for (final item in json) {
        sectors.add(Sector(
            sectorId: item['id'],
            sectorCode: item['code'],
            sectorDescription: item['description']));
      }
      return sectors;
    } else {
      // Request failed, handle the error
      print('Request failed with status: ${response.statusCode}');
    }
    return List.empty();
  }
}
