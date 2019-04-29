import 'package:flutter/material.dart';

import 'package:password_manager/src/models/setting.model.dart';

class MasterPasswordScreen extends StatefulWidget {
  @override
  _MasterPasswordScreenState createState() => _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends State<MasterPasswordScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String _current = '';
  String _new = '';
  String _confirm = '';
  bool _accept = false;

  _save() {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Please, fill in all required fields')));
      return;
    }
    // TODO - change master password
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Master Password'),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  key: Key('current'),
                  autocorrect: false,
                  autofocus: true,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                  ),
                  initialValue: '',
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter current password';
                    }
                  },
                  onSaved: (text) {
                    _current = text;
                  },
                ),
                TextFormField(
                  key: Key('new'),
                  autocorrect: false,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                  ),
                  initialValue: '',
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter new password';
                    }
                  },
                  onSaved: (text) {
                    _new = text;
                  },
                ),
                TextFormField(
                  key: Key('confirm'),
                  autocorrect: false,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                  initialValue: '',
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please confirm password';
                    }
                  },
                  onSaved: (text) {
                    _confirm = text;
                  },
                ),
                SizedBox(height: 15.0),
                CheckboxListTile(
                  key: Key('accept'),
                  title: Text(
                      'I realize that if I forget the master password, it will be impossible to recover it.'),
                  value: _accept,
                  onChanged: (value) {
                    setState(() {
                      _accept = value;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 15.0),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text('Change password'),
                    onPressed: _accept ? _save : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
