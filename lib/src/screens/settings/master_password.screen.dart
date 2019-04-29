import 'package:flutter/material.dart';

import 'package:password_manager/src/utils/db.util.dart';

DbHelper dbHelper = new DbHelper();

class MasterPasswordScreen extends StatefulWidget {
  @override
  _MasterPasswordScreenState createState() => _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends State<MasterPasswordScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String _currentPassword = '';
  String _newPassword = '';
  bool _currentValid = true;
  bool _accept = false;

  _save() async {
    _currentValid = true;
    // Save and validate the form
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Please, fill in all required fields')));
      return;
    }
    // Check current password
    _currentValid = await dbHelper.decryptDb(_currentPassword);
    if (!_currentValid) {
      _formKey.currentState.validate();
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Current password failed')));
      return;
    }
    // Encrypt the database with AES-256
    dbHelper.encryptDb(_newPassword);
    Navigator.pop(context);
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
                    if (!_currentValid) {
                      return 'Please enter a valid password';
                    }
                  },
                  onSaved: (text) {
                    _currentPassword = text;
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
                    _newPassword = text;
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
                    if (value != _newPassword) {
                      return 'Confirm password do not match';
                    }
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
