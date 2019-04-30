import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'package:password_manager/src/drawer.dart';
import 'package:password_manager/src/models/setting.model.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _localAuth = LocalAuthentication();
  final _settingsProvider = SettingsProvider();
  SettingsModel _settings = SettingsModel();
  bool _fingerprintEnabled = false;

  bool _save() {
    if (_formKey.currentState != null) {
      _formKey.currentState.save();
      if (!_formKey.currentState.validate()) {
        _scaffoldKey.currentState.hideCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text('Please, fill in all required fields')));
        return false;
      }
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    setState(() {
      _settingsProvider.setSettings(_settings);
    });
    return true;
  }

  _changeMasterPassword() {
    Navigator.pushNamed(context, '/masterPassword');
  }

  _showPinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your PIN code'),
          content: Form(
            key: _formKey,
            child: Container(
              child: TextFormField(
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
                },
                onSaved: (text) {
                  setState(() {
                    _settings.pin = text;
                  });
                },
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Accept'),
              onPressed: () {
                if (_save()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<SettingsModel> _fetchSettings() async {
    _settings = await _settingsProvider.getSettings();
    return _settings;
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
    }
    // bool didAuthenticate = await _localAuth.authenticateWithBiometrics(
    //     localizedReason: 'Please authenticate to show account balance');
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
      appBar: AppBar(
        title: Text('Settings'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<SettingsModel>(
        future: _fetchSettings(),
        builder: (BuildContext context, AsyncSnapshot<SettingsModel> snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton.icon(
                        label: Text('Change master password'),
                        icon: Icon(Icons.security),
                        onPressed: _changeMasterPassword,
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      children: <Widget>[
                        Text('Security',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    Divider(),
                    SwitchListTile.adaptive(
                      key: Key('pin'),
                      value: _settings.pin.isNotEmpty,
                      selected: _settings.pin.isNotEmpty,
                      title: Text('PIN code'),
                      onChanged: (value) {
                        if (value == true) {
                          _showPinDialog();
                          return;
                        }
                        setState(() {
                          _settings.pin = '';
                        });
                        _save();
                      },
                    ),
                    Divider(),
                    SwitchListTile.adaptive(
                      key: Key('fingerprint'),
                      value: _settings.fingerprint,
                      selected: _settings.fingerprint,
                      title: Text('Fingerprint'),
                      subtitle: !_fingerprintEnabled
                          ? Text('not available on device')
                          : null,
                      onChanged: _fingerprintEnabled
                          ? (value) {
                              setState(() {
                                _settings.fingerprint = value;
                              });
                              _save();
                            }
                          : null,
                    ),
                  ],
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
