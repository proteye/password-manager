import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:password_manager/src/models/credential.model.dart';
import 'package:password_manager/src/utils/color.util.dart';

class CredentialsDetailScreen extends StatefulWidget {
  @override
  _CredentialsDetailScreenState createState() =>
      _CredentialsDetailScreenState();
}

class _CredentialsDetailScreenState extends State<CredentialsDetailScreen> {
  CredentialModel _credential = CredentialModel();
  String _title = 'New credential';
  bool _inited = false;
  bool _editMode = true;
  bool _passwordVisible = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
      if (!_editMode) {
        _formKey.currentState.reset();
      }
    });
  }

  _togglePasswordVisible() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  _save() async {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Please, fill in all required fields')));
      return;
    }
    var credentialProvider = CredentialProvider();
    var dateNow = new DateTime.now().toUtc().millisecondsSinceEpoch;
    _credential.dateUpdate = dateNow;
    _credential.abbr = _credential.name.length > 1
        ? ('${_credential.name[0]}${_credential.name[1]}').toUpperCase()
        : ('${_credential.url[0]}${_credential.url[1]}').toUpperCase();
    if (_credential.id == null) {
      _credential.color = ColorHelper.generateColor();
      _credential.dateCreate = dateNow;
      await credentialProvider.insert(_credential);
    } else {
      await credentialProvider.update(_credential);
    }
    Navigator.pop(context);
  }

  _delete() async {
    var credentialProvider = CredentialProvider();
    await credentialProvider.delete(_credential.id);
    Navigator.pop(context);
  }

  _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete "${_credential.name}"'),
          content: Text('Are you sure you want to delete the credential?'),
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
                Navigator.of(context).pop();
                _delete();
              },
            ),
          ],
        );
      },
    );
  }

  _copyToClipboard(value, field) {
    Clipboard.setData(ClipboardData(text: value));
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text('$field copied to clipboard')));
  }

  _launchUrl(url) async {
    var _url = Uri.encodeFull(url);
    if (await canLaunch(_url)) {
      await launch(_url);
    } else {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Could not launch $_url')));
    }
  }

  _cancel() {
    Navigator.pop(context);
  }

  @override
  void didChangeDependencies() {
    var arguments = ModalRoute.of(context).settings.arguments;
    if (!_inited && arguments != null) {
      _credential = arguments;
      _title = _credential.name;
      _editMode = false;
    }
    _inited = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          FlatButton(
            child: Text(_editMode ? 'Save' : 'Edit',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: _editMode ? _save : _toggleEditMode,
          ),
        ],
        leading: _editMode
            ? OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: 90.0,
                child: FlatButton(
                  child: Text('Cancel',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: _credential.id != null ? _toggleEditMode : _cancel,
                ),
              )
            : null,
      ),
      body: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                key: Key('name'),
                autocorrect: false,
                autofocus: _editMode,
                enabled: _editMode,
                decoration: InputDecoration(
                  labelText: 'Service name',
                ),
                initialValue: _credential.name,
                validator: (value) {
                  if (value.isEmpty && _credential.url.isEmpty) {
                    return 'Please enter name';
                  }
                },
                onSaved: (text) {
                  _credential.name = text;
                },
              ),
              SizedBox(height: 15.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      key: Key('url'),
                      autocorrect: false,
                      enabled: _editMode,
                      decoration: InputDecoration(
                        labelText: 'Service URL',
                      ),
                      initialValue: _credential.url,
                      validator: (value) {
                        if (value.isEmpty && _credential.name.isEmpty) {
                          return 'Please enter url';
                        }
                      },
                      onSaved: (text) {
                        _credential.url = text;
                      },
                    ),
                  ),
                  !_editMode
                      ? IconButton(
                          icon: Icon(
                            Icons.open_in_browser,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            _launchUrl(_credential.url);
                          },
                        )
                      : Container(),
                ],
              ),
              SizedBox(height: 15.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      key: Key('username'),
                      autocorrect: false,
                      enabled: _editMode,
                      decoration: InputDecoration(
                        labelText: 'Username',
                      ),
                      initialValue: _credential.username,
                      onSaved: (text) {
                        _credential.username = text;
                      },
                    ),
                  ),
                  !_editMode
                      ? IconButton(
                          icon: Icon(
                            Icons.content_copy,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            _copyToClipboard(_credential.username, 'Username');
                          },
                        )
                      : Container(),
                ],
              ),
              SizedBox(height: 15.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      key: Key('password'),
                      autocorrect: false,
                      obscureText: !_passwordVisible,
                      enabled: _editMode,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: _editMode
                            ? IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: _togglePasswordVisible,
                              )
                            : null,
                      ),
                      initialValue: _credential.password,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter password';
                        }
                      },
                      onSaved: (text) {
                        _credential.password = text;
                      },
                    ),
                  ),
                  !_editMode
                      ? IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: _togglePasswordVisible,
                        )
                      : Container(),
                  !_editMode
                      ? IconButton(
                          icon: Icon(
                            Icons.content_copy,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            _copyToClipboard(_credential.password, 'Password');
                          },
                        )
                      : Container(),
                ],
              ),
              SizedBox(height: 15.0),
              TextFormField(
                key: Key('comment'),
                autocorrect: false,
                enabled: _editMode,
                decoration: InputDecoration(
                  labelText: 'Comment',
                ),
                initialValue: _credential.comment,
                onSaved: (text) {
                  _credential.comment = text;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _credential.id != null && !_editMode
          ? FloatingActionButton(
              onPressed: _showConfirmDialog,
              tooltip: 'Delete a credential',
              backgroundColor: Colors.red,
              child: Icon(Icons.delete),
            )
          : null,
    );
  }
}
