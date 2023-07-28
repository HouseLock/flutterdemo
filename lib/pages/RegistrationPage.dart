import 'package:flutter/material.dart';
import 'package:flutterdemo/models/User.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class MyAppState extends ChangeNotifier {}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int _currentStep = 0;

  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  //User pageUser = new User(userId: 0, accessToken: accessToken, refreshToken: refreshToken, appRole: appRole)
  List<Step> _steps = [
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
              //  controller: _nameController,
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
                  border: OutlineInputBorder(), labelText: 'Pec', hintText: ''),
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrazione'),
      ),
      body: Column(
        children: [
          Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              setState(() {
                if (_currentStep < _steps.length - 1) {
                  _currentStep++;
                } else {
                  // Registration complete
                  // Perform any final submission logic
                }
              });
            },
            onStepCancel: () {
              setState(() {
                if (_currentStep > 0) {
                  _currentStep--;
                }
              });
            },
            onStepTapped: (int stepPressed) {
              setState(() {
                if (_currentStep != stepPressed) {
                  if (stepPressed < _steps.length) {
                    _currentStep = stepPressed;
                  }
                }
              });
            },
            controlsBuilder: (BuildContext context, ControlsDetails details) {
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
                            onPressed: details.onStepCancel,
                            child: Text('Indietro')))
                ]),
              ));
            },
            steps: _steps,
          ),
          /*Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: _buildStepContent(),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    return Container(
      child: _steps[_currentStep].content,
    );
  }
}
