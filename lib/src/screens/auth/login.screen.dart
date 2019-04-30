import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'package:password_manager/src/models/setting.model.dart';
import 'package:password_manager/src/utils/db.util.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _localAuth = LocalAuthentication();
  final _settingsProvider = SettingsProvider();
  SettingsModel _settings = SettingsModel();
  DbHelper _dbHelper = new DbHelper();
  bool _fingerprintEnabled = false;
  String _pin = '';
  String _password = '';
  bool _error = false;

  _save() async {
    _error = false;
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Please, fill in all required fields')));
      return;
    }
    // Check pin code
    if (_settings.pin.isNotEmpty && _pin != _settings.pin) {
      setState(() {
        _error = true;
      });
      _formKey.currentState.validate();
      return;
    }
    // Check master password
    var password =
        _settings.pin.isNotEmpty ? _settings.masterPassword : _password;
    bool isValid = await _dbHelper.decryptDb(password);
    if (!isValid) {
      setState(() {
        _error = true;
      });
      _formKey.currentState.validate();
      return;
    }
    // Pin or password is valid
    await _success();
  }

  _success() async {
    if (_settings.masterPassword.isEmpty) {
      _settings.masterPassword = _password;
      await _settingsProvider.setSettings(_settings);
    }
    // await dbHelper.deleteDb();
    await _dbHelper.database;
    _scaffoldKey.currentState.hideCurrentSnackBar();
    Navigator.pushNamed(context, '/credentials');
  }

  Future<SettingsModel> _fetchSettings() async {
    _settings = await _settingsProvider.getSettings();
    return _settings;
  }

  _renderTextField() {
    if (_settings.pin.isNotEmpty) {
      return TextFormField(
        key: Key('pin'),
        autocorrect: false,
        autofocus: true,
        obscureText: true,
        maxLength: 4,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'PIN code',
        ),
        validator: (value) {
          if (value.isEmpty || value.length < 4) {
            return 'Please enter the code';
          }
          if (_error) {
            return 'PIN code is invalid';
          }
        },
        onSaved: (text) {
          _pin = text;
        },
      );
    }

    return TextFormField(
      key: Key('password'),
      autocorrect: false,
      autofocus: true,
      obscureText: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Master password',
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter password';
        }
        if (_error) {
          return 'Password is invalid';
        }
      },
      onSaved: (text) {
        _password = text;
      },
    );
  }

  initFingerprint() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      return;
    }

    List<BiometricType> availableBiometrics =
        await _localAuth.getAvailableBiometrics();
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      _fingerprintEnabled = true;
      bool didAuthenticate = await _localAuth.authenticateWithBiometrics(
          localizedReason: 'Please authenticate to show account balance');
      if (didAuthenticate) {
        _success();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initFingerprint();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder<SettingsModel>(
        future: _fetchSettings(),
        builder: (BuildContext context, AsyncSnapshot<SettingsModel> snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _renderTextField(),
                      SizedBox(height: 15.0),
                      SizedBox(
                        width: double.infinity,
                        child: RaisedButton.icon(
                          color: Colors.blueGrey,
                          textColor: Colors.white,
                          label: Text('Log in'),
                          icon: Icon(Icons.exit_to_app),
                          onPressed: _save,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
