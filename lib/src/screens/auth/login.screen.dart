import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:local_auth/local_auth.dart';

import 'package:password_manager/src/models/setting.model.dart';
import 'package:password_manager/src/utils/db.util.dart';
import 'package:password_manager/src/widgets/logo.widget.dart';

const NUM_PAD = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9],
  ['x', 0, 'c'],
];

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
  List<String> _pinList = ['x', 'x', 'x', 'x'];
  String _password = '';
  bool _isFirstStart = false;
  bool _error = false;
  bool _inProgress = false;

  init() async {
    bool exists = await _dbHelper.existsDb();
    // First app run
    if (!exists) {
      setState(() {
        _isFirstStart = true;
      });
      return;
    } else {
      await _fetchSettings();
      await _dbHelper.encryptDb(_settings.masterPassword);
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

  _changePin(code) {
    return () {
      if (code == 'x') {
        return;
      } else if (code == 'c') {
        _pin = _pin.length > 0 ? _pin.substring(0, _pin.length - 1) : _pin;
        _updatePinList();
        return;
      } else if (_pin.length == 4) {
        return;
      }
      _pin += code.toString();
      _updatePinList();
    };
  }

  _updatePinList() {
    _pinList = ['x', 'x', 'x', 'x'];
    setState(() {
      _pinList.setAll(0, _pin.split(''));
      _error = false;
    });
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

  _renderPinField() {
    var dotColor = _error ? Colors.red : Colors.blue;
    return Container(
      margin: EdgeInsets.only(top: 15.0),
      child: Column(children: <Widget>[
        SizedBox(height: 15.0),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _pinList.map((n) {
              return Container(
                padding: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: n != 'x' ? dotColor : Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  boxShadow: n != 'x'
                      ? [BoxShadow(color: dotColor, blurRadius: 6.0)]
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 30.0),
        Column(
          children: NUM_PAD.map((row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((col) {
                Widget child = Text(
                  col.toString(),
                  style: TextStyle(fontSize: 24.0),
                );
                if (col == 'x') {
                  child = Text(
                    'EXIT',
                    style: TextStyle(fontSize: 16.0),
                  );
                } else if (col == 'c') {
                  child = Icon(Icons.backspace);
                }
                return Expanded(
                  child: InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: child,
                    ),
                    onTap: _changePin(col),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ]),
    );
  }

  _renderPasswordField() {
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      LogoWidget(
                        textColor1: Colors.black87,
                        textColor2: Colors.black54,
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        _settings.pin.isEmpty
                            ? 'Please enter your master password'
                            : (!_error
                                ? 'Please enter your PIN code'
                                : 'PIN code is invalid'),
                        style: TextStyle(
                            color: _settings.pin.isNotEmpty && _error
                                ? Colors.red
                                : Colors.grey),
                      ),
                      _settings.pin.isEmpty
                          ? _renderPasswordField()
                          : _renderPinField(),
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
