import 'package:flutter/material.dart';

import 'package:password_manager/src/drawer.dart';
import 'package:password_manager/src/models/setting.model.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _settingProvider = SettingProvider();
  List<SettingModel> _settings = [];
  bool _editMode = false;

  _toggleEditMode({isReset = true}) {
    setState(() {
      _editMode = !_editMode;
      if (!_editMode && isReset) {
        _formKey.currentState.reset();
      }
    });
  }

  _changeField(name, value) {
    var dateNow = new DateTime.now().toUtc().millisecondsSinceEpoch;
    var field =
        _settings.firstWhere((item) => item.name == name, orElse: () => null);
    if (field == null) {
      field = SettingModel();
      field.name = name;
      field.dateCreate = dateNow;
      _settings.add(field);
    }
    field.value = value;
    field.dateUpdate = dateNow;
  }

  _getValueByName(name) {
    var field =
        _settings.firstWhere((item) => item.name == name, orElse: () => null);
    return field != null ? field.value : '';
  }

  _save() {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Please, fill in all required fields')));
      return;
    }
    _settingProvider.updateAll(_settings,
        callback: () => _toggleEditMode(isReset: false));
  }

  _changeMasterPassword() {
    Navigator.pushNamed(context, '/masterPassword');
  }

  Future<List<SettingModel>> _fetchSettings() async {
    _settings = await _settingProvider.getList();
    return _settings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Settings'),
        actions: _editMode
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _save,
                ),
              ]
            : null,
        leading: _editMode
            ? IconButton(
                icon: Icon(Icons.cancel),
                onPressed: _toggleEditMode,
              )
            : null,
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<List<SettingModel>>(
        future: _fetchSettings(),
        builder:
            (BuildContext context, AsyncSnapshot<List<SettingModel>> snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
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
                      TextFormField(
                        key: Key('name'),
                        autocorrect: false,
                        enabled: _editMode,
                        decoration: InputDecoration(
                          labelText: 'Your name',
                        ),
                        initialValue: _getValueByName('name'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter name';
                          }
                        },
                        onSaved: (text) {
                          _changeField('name', text);
                        },
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
      floatingActionButton: !_editMode
          ? FloatingActionButton(
              onPressed: _toggleEditMode,
              tooltip: 'Change to edit mode',
              child: Icon(Icons.edit),
            )
          : null,
    );
  }
}
