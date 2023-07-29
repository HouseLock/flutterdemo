import 'package:flutter/material.dart';
import 'package:flutterdemo/models/User.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class MyAppState extends ChangeNotifier {}

class _RegistrationPageState extends State<RegistrationPage> {
  // Step 1
  final TextEditingController _nameController = TextEditingController();
  // Step 2
  final TextEditingController _surnameController = TextEditingController();
  // Step 3
  final TextEditingController _emailController = TextEditingController();

  User user = User();

  int _currentStep = 0;
  List<Step> _steps = List.empty();

  void _onStepTabbed(int stepSelected) {
    if (_currentStep != stepSelected) {
      if (stepSelected < 3) {
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

        // Print user data (for demonstration purposes)
        print(user.toJson());
      });
      // Here you can proceed with further actions, e.g., saving the user data or navigating to a new page.
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
                  // controller: surnameController,
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
                  // controller: surnameController,
                ),
              ),
            ],
          ),
          subtitle: Text('Dati personali'),
        ),
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
                  labelText: 'P.Iva',
                  hintText: '',
                ) //,controller: nameController,
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
                  // controller: surnameController,
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
                ),
              ),
            ],
          ),
          subtitle: Text('Dati aziendali'),
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
                      labelText: 'Email',
                      hintText: ''),
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
                  // controller: surnameController,
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
                  // controller: surnameController,
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
      body: GestureDetector(
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
      ),
    );
  }
}
