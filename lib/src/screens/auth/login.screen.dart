import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'package:password_manager/src/models/setting.model.dart';
import 'package:password_manager/src/utils/db.util.dart';
import 'package:password_manager/src/widgets/logo.widget.dart';

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
  DbHelper _dbHelper = DbHelper();
  String _pin = '';
  String _password = '';
  bool _isFirstStart = false;
  bool _error = false;
  bool _inProgress = false;

  init() async {
    await _dbHelper.close();
    bool exists = await _dbHelper.existsDb();
    // First app run
    if (!exists) {
      setState(() {
        _isFirstStart = true;
      });
      return;
    }
    // Next app run
    await initFingerprint();
  }

  initFingerprint() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      return;
    }

    List<BiometricType> availableBiometrics =
        await _localAuth.getAvailableBiometrics();
    bool isFingerprintEnabled =
        availableBiometrics.contains(BiometricType.fingerprint);

    if (isFingerprintEnabled && _settings.fingerprint) {
      setState(() {
        _inProgress = true;
      });
      bool didAuthenticate = await _localAuth.authenticateWithBiometrics(
          localizedReason: 'Please fingerprint in to enter');
      if (didAuthenticate) {
        _loginWithFingerprint();
        return;
      }
      setState(() {
        _inProgress = false;
      });
    }
  }

  _create() async {
    setState(() {
      _inProgress = true;
    });
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Please, fill in all required fields')));
      _inProgress = false;
      return;
    }
    // Create and encrypt database
    await _dbHelper.database;
    await _dbHelper.encryptDb(_password);
    // Run app
    await _success();
    _inProgress = false;
  }

  _login() async {
    setState(() {
      _inProgress = true;
      _error = false;
    });
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Please, fill in all required fields')));
      _inProgress = false;
      return;
    }
    // Check pin code
    if (_settings.pin.isNotEmpty && _pin != _settings.pin) {
      setState(() {
        _error = true;
      });
      _formKey.currentState.validate();
      _inProgress = false;
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
      _inProgress = false;
      return;
    }
    // Pin or password is valid
    await _success();
    _inProgress = false;
  }

  _loginWithFingerprint() async {
    var password = _settings.masterPassword;
    bool isValid = await _dbHelper.decryptDb(password);
    if (!isValid) {
      setState(() {
        _inProgress = false;
        _error = true;
      });
      _formKey.currentState.validate();
      return;
    }
    await _success();
    _inProgress = false;
  }

  _success() async {
    if (_settings.masterPassword.isEmpty) {
      _settings.masterPassword = _password;
      await _settingsProvider.setSettings(_settings);
    }
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
        autofocus: false,
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
      autofocus: false,
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

  _renderFirstStart() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(50.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LogoWidget(
                  textColor1: Colors.black87,
                  textColor2: Colors.black54,
                ),
                SizedBox(height: 30.0),
                Text(
                  'Please set master password',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 15.0),
                TextFormField(
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
                ),
                TextFormField(
                  key: Key('confirm'),
                  autocorrect: false,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (value != _password) {
                      return 'Confirm password do not match';
                    }
                  },
                ),
                SizedBox(height: 15.0),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton.icon(
                    color: Colors.blue,
                    textColor: Colors.white,
                    label: Text('Create database'),
                    icon: Icon(Icons.data_usage),
                    onPressed: !_inProgress ? _create : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder<SettingsModel>(
        future: _fetchSettings(),
        builder: (BuildContext context, AsyncSnapshot<SettingsModel> snapshot) {
          if (snapshot.hasData) {
            if (_isFirstStart) {
              return _renderFirstStart();
            }
            return Center(
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      LogoWidget(
                        textColor1: Colors.black87,
                        textColor2: Colors.black54,
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        _settings.pin.isEmpty
                            ? 'Please login with your master password'
                            : 'Please login with your PIN code',
                        style: TextStyle(color: Colors.grey),
                      ),
                      _renderTextField(),
                      SizedBox(height: 15.0),
                      SizedBox(
                        width: double.infinity,
                        child: RaisedButton.icon(
                          color: Colors.blue,
                          textColor: Colors.white,
                          label: Text('Log in'),
                          icon: Icon(Icons.exit_to_app),
                          onPressed: !_inProgress ? _login : null,
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
