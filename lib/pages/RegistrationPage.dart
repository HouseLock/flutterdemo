import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutterdemo/main.dart';
import 'package:flutterdemo/models/Sector.dart';
import 'package:flutterdemo/models/User.dart';
import 'package:flutter/services.dart';
import 'package:flutterdemo/pages/RedirectPage.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../AppConst.dart';

final storage = FlutterSecureStorage();

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class MyAppState extends ChangeNotifier {}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();
  final _formKeyStep4 = GlobalKey<FormState>();

  final _nameFocusNode = FocusNode();
  final _surnameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _pecController = TextEditingController();
  final TextEditingController _taxIDCodeController = TextEditingController();
  final TextEditingController _vatNumberController = TextEditingController();
  final TextEditingController _sdiController = TextEditingController();

  Set<Sector> _selectedSectors = Set<Sector>();
  User user = User();

  int _currentStep = 0;
  List<Step> _steps = List.empty();
  int _currAppRole = -1;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  List<Sector> _sectors = List.empty();

  String? _nameError;
  String? _surnameError;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _onStepTabbed(int stepSelected) {
    if (_currentStep != stepSelected) {
      if (stepSelected < _steps.length) {
        if (stepSelected < _currentStep || isStepValid(stepSelected)) {
          setState(() => _currentStep = stepSelected);
        }
      }
    }
  }

  bool isStepValid(int stepSelected) {
    return _steps[stepSelected].state == StepState.complete;
  }

  Future<void> _onStepContinue() async {
    if (_currentStep < _steps.length - 1) {
      if (_currentStep == 0) {
        if (_currAppRole >= 0 && _currAppRole <= 1) {
          updateStepState(_currentStep, StepState.complete);
          setState(() => _currentStep += 1);
        } else {
          updateStepState(_currentStep, StepState.error);
        }
      } else if (_currentStep == 1) {
        if (_formKeyStep1.currentState!.validate()) {
          updateStepState(_currentStep, StepState.complete);
          if (_steps[2].state == StepState.disabled) {
            setState(() => _currentStep += 2);
          } else {
            setState(() => _currentStep += 1);
          }
        } else {
          updateStepState(_currentStep, StepState.error);
        }
      } else if (_currentStep == 2) {
        if (_formKeyStep2.currentState!.validate()) {
          updateStepState(_currentStep, StepState.complete);
          setState(() => _currentStep += 1);
        } else {
          updateStepState(_currentStep, StepState.error);
        }
      } else {
        updateStepState(_currentStep, StepState.complete);
        setState(() => _currentStep += 1);
        updateStepState(_currentStep, StepState.editing);
      }
    } else {
      //step finale superato
      if (_formKeyStep4.currentState!.validate()) {
        String userValue = _usernameController.value.text;
        if (userValue.isNotEmpty && userValue.length > 4) {
          Future<bool> userExists = checkUsernameExists(userValue);
          if (await userExists) {
            setState(() {
              _usernameError = 'Questo user esiste già.';
            });
            updateStepState(_currentStep, StepState.error);
          } else {
            setState(() {
              _usernameError = null;
            });
          }
        }
        if (_usernameError != null) return;

        String emailValue = _emailController.value.text;
        if (emailValue.isNotEmpty) {
          Future<bool> emailExists = checkEmailExists(emailValue);
          if (await emailExists) {
            setState(() {
              _emailError = 'Questa email esiste già.';
            });
            updateStepState(_currentStep, StepState.error);
            return;
          } else {
            setState(() {
              _emailError = null;
            });
          }
        }
        if (_emailError != null) return;

        updateStepState(_currentStep, StepState.complete);
        setState(() {
          user.name = _nameController.text;
          user.surname = _surnameController.text;
          user.username = _usernameController.text;
          user.email = _emailController.text;
          user.password = _passwordController.text;
          user.businessName = _businessNameController.text;
          user.pec = _pecController.text;
          user.taxIDCode = _taxIDCodeController.text;
          user.vatNumber = _vatNumberController.text;
          user.sdi = _sdiController.text;
          print(user.toJson());
        });
        doRegister(user);
      } else {
        updateStepState(_currentStep, StepState.error);
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
        _steps[_currentStep].state == StepState.disabled
            ? _currentStep -= 1
            : null;
        updateStepState(_currentStep, StepState.editing);
      });
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

  List<StepState> stepStates = [
    StepState.editing,
    StepState.indexed,
    StepState.indexed,
    StepState.indexed
  ];

  void updateStepState(int step, StepState state) {
    setState(() {
      stepStates[step] = state;
    });
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
            isActive: _currentStep == 0,
            state: stepStates[0],
            title: Text('Step 1'),
            content: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currAppRole = 0;
                        updateStepState(2, StepState.disabled);
                      });
                      //setState(() => _currAppRole = 0);
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
                      setState(() {
                        _currAppRole = 1;
                        updateStepState(2, StepState.indexed);
                      });
                      //setState(() => _currAppRole = 0);
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
          isActive: _currentStep == 1,
          state: stepStates[1],
          title: Text('Step 2'),
          content: Form(
            key: _formKeyStep1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      errorText: _nameError,
                      labelText: 'Nome *',
                      hintText: '',
                    ),
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          _nameError = 'Questo campo è obbligatorio';
                        });
                      } else {
                        setState(() {
                          _nameError = null;
                        });
                      }
                      return _nameError;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        errorText: _surnameError,
                        labelText: 'Cognome *',
                        hintText: ''),
                    controller: _surnameController,
                    focusNode: _surnameFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          _surnameError = 'Questo campo è obbligatorio';
                        });
                      } else {
                        setState(() {
                          _surnameError = null;
                        });
                      }
                      return _surnameError;
                    },
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
          ),
          subtitle: Text('Dati personali'),
        ),
        Step(
          isActive: _currentStep == 2,
          state: stepStates[2],
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
                    labelText: 'P.Iva *',
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
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _openSectorMultiSelectDialog(context),
                      child: Text('Settori'),
                    ),
                    Wrap(
                      children: _selectedSectors
                          .map((e) => Chip(
                                label: Text(e.sectorCode),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Text('Dati aziendali'),
        ),
        Step(
          isActive: _currentStep == 3,
          state: stepStates[3],
          title: Text('Step 4'),
          content: Form(
            key: _formKeyStep4,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        errorText: _usernameError,
                        labelText: 'Username *',
                        hintText: ''),
                    controller: _usernameController,
                    focusNode: _usernameFocusNode,
                    onFieldSubmitted: (value) async {
                      //String value = _usernameController.text;
                      if (value.isNotEmpty && value.length > 4) {
                        Future<bool> userExists = checkUsernameExists(value);
                        if (await userExists) {
                          setState(() {
                            _usernameError = 'Questo user esiste già.';
                          });
                        } else {
                          setState(() {
                            _usernameError = null;
                          });
                        }
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          _usernameError = 'Questo campo è obbligatorio.';
                        });
                      } else if (value.length < 4) {
                        setState(() {
                          _usernameError =
                              'Valore non valido, l\'username deve essere di almeno 4 caratteri.';
                        });
                      } else {
                        _usernameError = null;
                      }
                      return _usernameError;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        errorText: _emailError,
                        labelText: 'Email *',
                        hintText: ''),
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    onEditingComplete: () async {
                      String value = _emailController.text;
                      if (value.isNotEmpty && value.length > 4) {
                        Future<bool> emailExists = checkEmailExists(value);
                        if (await emailExists) {
                          setState(() {
                            _emailError = 'Questa email esiste già';
                          });
                        } else {
                          setState(() {
                            _emailError = null;
                          });
                        }
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          _emailError = 'Questo campo è obbligatorio';
                        });
                      } else {
                        setState(() {
                          _emailError = null;
                        });
                      }
                      return _emailError;
                    },
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
                      errorText: _passwordError,
                      labelText: 'Password *',
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
                          Tooltip(
                            message: 'Requisiti Password:\n'
                                '- Minimo 8 caratteri\n'
                                '- Massimo 20 caratteri\n'
                                '- Almeno una lettera maiuscola\n'
                                '- Almeno una lettera minuscola\n'
                                '- Almeno un numero\n'
                                '- Almeno un carattere speciale',
                            child: IconButton(
                              icon: Icon(Icons.help_outline),
                              onPressed: () {},
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
                /*if (_formKeyStep4.currentState != null &&
                    !_formKeyStep4.currentState!.validate())
                  Text(
                    _passwordErrorMessage,
                    style: TextStyle(color: Colors.red),
                  ),*/
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      errorText: _confirmPasswordError,
                      labelText: 'Conferma password *',
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
                    validator: validateConfirmPassword,
                    focusNode: _confirmPasswordFocusNode,
                  ),
                ),
              ],
            ),
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
            return Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Chiudi la tastiera quando l'utente tocca al di fuori del campo di input
                      FocusScope.of(context).unfocus();
                    },
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: stepper,
                      ),
                    ),
                  ),
                ),
              ],
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
    if (_sectors.isEmpty) {
      const url = '${API_URL}api/sector/findall';
      final uri = Uri.parse(url);
      Map<String, String> headersCall = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json',
        'Accept': '*/*'
      };

      try {
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
          return List.empty();
        }
      } on Exception catch (e) {
        print(e);
        print("Generic error - getSectors");
        _sectors = List.empty();
      }
      return _sectors;
    }
    return _sectors;
  }

  void _openSectorMultiSelectDialog(BuildContext context) async {
    final items = _builderSectors();
    final selectedItems = _selectedSectors.toList();

    await showDialog(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Expanded(
              child: AlertDialog(
                title: Text('Settori'),
                content: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        Expanded(
                          child: MultiSelectDialog(
                            separateSelectedItems: true,
                            title: Text('Seleziona uno o più settori:'),
                            searchHint: 'Cerca un settore...',
                            items: items,
                            searchable: true,
                            cancelText: Text('Indietro'),
                            initialValue: selectedItems,
                            onConfirm: (selectedItems) {
                              setState(() {
                                _selectedSectors = selectedItems.toSet();
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> checkEmailExists(String value) async {
    const url = '${API_URL}api/auth/emailinuse';
    final uri = Uri.parse(url);
    if (value.startsWith('"')) value = value.substring(1);
    if (value.endsWith('"')) value = value.substring(0, (value.length - 1));
    String bodyPost = value;
    Map<String, String> headersCall = {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
      'Accept': '*/*'
    };
    try {
      final response = await http.post(uri,
          body: jsonEncode(bodyPost), headers: headersCall);

      if (response.statusCode == 200) {
        final body = response.body;
        return body == 'true';
      } else {
        // Request failed, handle the error
        print('Request failed with status: ${response.statusCode}');
      }
    } on Exception {
      print("Generic error - checkEmailExists");
    }
    return false;
  }

  Future<bool> checkUsernameExists(String value) async {
    const url = '${API_URL}api/auth/usernameinuse';
    final uri = Uri.parse(url);
    if (value.startsWith('"')) value = value.substring(1);
    if (value.endsWith('"')) value = value.substring(0, (value.length - 1));
    String bodyPost = value;
    Map<String, String> headersCall = {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
      'Accept': '*/*'
    };
    try {
      final response = await http.post(uri,
          body: jsonEncode(bodyPost), headers: headersCall);

      if (response.statusCode == 200) {
        final body = response.body;
        return body == 'true';
      } else {
        // Request failed, handle the error
        print('Request failed with status: ${response.statusCode}');
      }
    } on Exception {
      print("Generic error - checkUsernameExists");
    }
    return false;
  }

  void doRegister(User user) async {
    const url = '${API_URL}api/auth/register';
    final uri = Uri.parse(url);
    Map<String, dynamic> bodyPost = user.toJson();
    Map<String, String> headersCall = {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
      'Accept': '*/*'
    };
    try {
      final response = await http.post(uri,
          body: jsonEncode(bodyPost), headers: headersCall);

      if (response.statusCode == 200) {
        final body = response.body;
        final json = jsonDecode(body);
        //users = json['results'];
      } else {
        // Request failed, handle the error
        print('Request failed with status: ${response.statusCode}');
      }
    } on Exception {
      print("Generic error - doRegister");
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _passwordError = 'Inserisci una password';
      });
    } else if (!isPasswordValid(value)) {
      setState(() {
        _passwordError =
            'La password deve essere di minimo 8 caratteri, contenere almeno una lettera maiuscola, una minuscola, un numero e un carattere speciale.';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
    return _passwordError;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Inserisci una password';
      });
    } else if (!isPasswordValid(value)) {
      setState(() {
        _confirmPasswordError =
            'La password deve essere di minimo 8 caratteri, contenere almeno una lettera maiuscola, una minuscola, un numero e un carattere speciale.';
      });
    } else if (value != _passwordController.text) {
      setState(() {
        _confirmPasswordError = 'Le password non sono uguali.';
      });
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }
    return _confirmPasswordError;
  }

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?\":{}|<>])(?=.{8,20}).*$');
    return passwordRegex.hasMatch(password);
  }
}
