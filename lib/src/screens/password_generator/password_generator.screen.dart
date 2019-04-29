import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'package:password_manager/src/drawer.dart';
import 'package:password_manager/src/utils/password.util.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  @override
  _PasswordGeneratorScreenState createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double _length = 12.0;
  bool _lowerAlpha = true;
  bool _upperAlpha = true;
  bool _numeric = true;
  bool _specSymbols = true;
  String _password = PasswordHelper.randomString(12);

  _generatePassword() {
    int length = _length.round();
    var allSymbols = _lowerAlpha && _upperAlpha && _numeric && _specSymbols;
    var alphaNumeric = _lowerAlpha && _upperAlpha && _numeric && !_specSymbols;
    var alphaAll = _lowerAlpha && _upperAlpha && !_numeric && !_specSymbols;
    var alphaLower = _lowerAlpha && !_upperAlpha && !_numeric && !_specSymbols;
    var alphaUpper = !_lowerAlpha && _upperAlpha && !_numeric && !_specSymbols;
    var numeric = !_lowerAlpha && !_upperAlpha && _numeric && !_specSymbols;
    var specSymbols = !_lowerAlpha && !_upperAlpha && !_numeric && _specSymbols;

    setState(() {
      if (allSymbols) {
        _password = PasswordHelper.randomString(length);
      } else if (alphaNumeric) {
        _password = PasswordHelper.randomAlphaNumeric(length);
      } else if (alphaAll) {
        _password = PasswordHelper.randomAlpha(length);
      } else if (alphaLower) {
        _password = PasswordHelper.randomAlphaLower(length);
      } else if (alphaUpper) {
        _password = PasswordHelper.randomAlphaUpper(length);
      } else if (numeric) {
        _password = PasswordHelper.randomNumeric(length);
      } else if (specSymbols) {
        _password = PasswordHelper.randomSpecSymbols(length);
      } else {
        _password = PasswordHelper.randomString(length);
      }
    });
  }

  _onSliderChanged(double value) {
    var oldLength = _length;
    setState(() {
      _length = value;
    });
    if (oldLength.round() != value.round()) {
      _generatePassword();
    }
  }

  _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _password));
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text('Password copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Password generator'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Generate password',
            onPressed: _generatePassword,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                height: 50.0,
                color: Colors.black12,
                child: Text(
                  _password,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Text(
                'Length: ${_length.round()}',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
              Slider.adaptive(
                value: _length,
                min: 4.0,
                max: 32.0,
                onChanged: _onSliderChanged,
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _lowerAlpha,
                    onChanged: (value) {
                      bool isAccept = _upperAlpha || _numeric || _specSymbols;
                      if (!value && !isAccept) {
                        return;
                      }
                      setState(() {
                        _lowerAlpha = value;
                        _generatePassword();
                      });
                    },
                  ),
                  Text('Lower case (abc)'),
                ],
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _upperAlpha,
                    onChanged: (value) {
                      bool isAccept = _lowerAlpha || _numeric || _specSymbols;
                      if (!value && !isAccept) {
                        return;
                      }
                      setState(() {
                        _upperAlpha = value;
                        _generatePassword();
                      });
                    },
                  ),
                  Text('Upper case (ABC)'),
                ],
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _numeric,
                    onChanged: (value) {
                      bool isAccept =
                          _lowerAlpha || _upperAlpha || _specSymbols;
                      if (!value && !isAccept) {
                        return;
                      }
                      setState(() {
                        _numeric = value;
                        _generatePassword();
                      });
                    },
                  ),
                  Text('Numeric'),
                ],
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _specSymbols,
                    onChanged: (value) {
                      bool isAccept = _lowerAlpha || _upperAlpha || _numeric;
                      if (!value && !isAccept) {
                        return;
                      }
                      setState(() {
                        _specSymbols = value;
                        _generatePassword();
                      });
                    },
                  ),
                  Text('Special symbols'),
                ],
              ),
              SizedBox(height: 15.0),
              SizedBox(
                width: double.infinity,
                child: OutlineButton.icon(
                  padding: EdgeInsets.all(15.0),
                  label: Text('Copy to clipboard',
                      style: TextStyle(fontSize: 16.0)),
                  icon: Icon(Icons.content_copy),
                  onPressed: _copyToClipboard,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
