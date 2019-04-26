import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:password_manager/src/models/card.model.dart';

class CardsDetailScreen extends StatefulWidget {
  @override
  _CardsDetailScreenState createState() => _CardsDetailScreenState();
}

class _CardsDetailScreenState extends State<CardsDetailScreen> {
  CardModel _card = CardModel();
  FocusNode _cardnumberFocusNode;
  FocusNode _cvcFocusNode;
  String _title = 'New card';
  bool _inited = false;
  bool _editMode = true;
  bool _cardnumberVisible = false;
  bool _cvcVisible = false;
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

  _toggleCardnumberVisible() {
    setState(() {
      _cardnumberVisible = !_cardnumberVisible;
    });
  }

  _toggleCvcVisible() {
    setState(() {
      _cvcVisible = !_cvcVisible;
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
    var cardProvider = CardProvider();
    var dateNow = new DateTime.now().toUtc().millisecondsSinceEpoch;
    _card.dateUpdate = dateNow;
    _card.type = 'unknown';
    if (_card.id == null) {
      _card.dateCreate = dateNow;
      await cardProvider.insert(_card);
    } else {
      await cardProvider.update(_card);
    }
    Navigator.pop(context);
  }

  _delete() async {
    var cardProvider = CardProvider();
    await cardProvider.delete(_card.id);
    Navigator.pop(context);
  }

  _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete "${_card.name}"'),
          content: Text('Are you sure you want to delete the card?'),
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

  _cancel() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _cardnumberFocusNode = FocusNode();
    _cardnumberFocusNode.addListener(() {
      setState(() {
        _cardnumberVisible = _cardnumberFocusNode.hasFocus;
      });
    });
    _cvcFocusNode = FocusNode();
    _cvcFocusNode.addListener(() {
      setState(() {
        _cvcVisible = _cvcFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _cardnumberFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    var arguments = ModalRoute.of(context).settings.arguments;
    if (!_inited && arguments != null) {
      _card = arguments;
      _title = _card.name;
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
                  onPressed: _card.id != null ? _toggleEditMode : _cancel,
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
                  labelText: 'Card name',
                ),
                initialValue: _card.name,
                onSaved: (text) {
                  _card.name = text;
                },
              ),
              SizedBox(height: 15.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      key: Key('cardnumber'),
                      autocorrect: false,
                      obscureText: !_cardnumberVisible,
                      enabled: _editMode,
                      focusNode: _cardnumberFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Card number',
                        suffixIcon: _editMode
                            ? IconButton(
                                icon: Icon(
                                  _cardnumberVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: _toggleCardnumberVisible,
                              )
                            : null,
                      ),
                      initialValue: _card.cardnumber,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter cardnumber';
                        }
                      },
                      onSaved: (text) {
                        _card.cardnumber = text;
                      },
                    ),
                  ),
                  !_editMode
                      ? IconButton(
                          icon: Icon(
                            _cardnumberVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: _toggleCardnumberVisible,
                        )
                      : Container(),
                  !_editMode
                      ? IconButton(
                          icon: Icon(
                            Icons.content_copy,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            _copyToClipboard(_card.cardnumber, 'Cardnumber');
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
                      key: Key('owner'),
                      autocorrect: false,
                      enabled: _editMode,
                      decoration: InputDecoration(
                        labelText: 'Owner',
                      ),
                      initialValue: _card.owner,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter owner';
                        }
                      },
                      onSaved: (text) {
                        _card.owner = text;
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
                            _copyToClipboard(_card.owner, 'Owner');
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
                      key: Key('exp'),
                      autocorrect: false,
                      enabled: _editMode,
                      decoration: InputDecoration(
                        labelText: 'Expire',
                      ),
                      initialValue: _card.exp,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter expire';
                        }
                      },
                      onSaved: (text) {
                        _card.exp = text;
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
                            _copyToClipboard(_card.exp, 'Expire');
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
                      key: Key('cvc'),
                      autocorrect: false,
                      obscureText: !_cvcVisible,
                      enabled: _editMode,
                      focusNode: _cvcFocusNode,
                      decoration: InputDecoration(
                        labelText: 'CVC',
                        suffixIcon: _editMode
                            ? IconButton(
                                icon: Icon(
                                  _cvcVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: _toggleCvcVisible,
                              )
                            : null,
                      ),
                      initialValue: _card.cvc,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter cvc';
                        }
                      },
                      onSaved: (text) {
                        _card.cvc = text;
                      },
                    ),
                  ),
                  !_editMode
                      ? IconButton(
                          icon: Icon(
                            _cvcVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: _toggleCvcVisible,
                        )
                      : Container(),
                  !_editMode
                      ? IconButton(
                          icon: Icon(
                            Icons.content_copy,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            _copyToClipboard(_card.cvc, 'CVC');
                          },
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _card.id != null && !_editMode
          ? FloatingActionButton(
              onPressed: _showConfirmDialog,
              tooltip: 'Delete a card',
              backgroundColor: Colors.red,
              child: Icon(Icons.delete),
            )
          : null,
    );
  }
}
