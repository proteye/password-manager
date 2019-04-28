import 'package:flutter/material.dart';

import 'package:password_manager/src/models/note.model.dart';
import 'package:password_manager/src/utils/color.util.dart';

class NotesDetailScreen extends StatefulWidget {
  @override
  _NotesDetailScreenState createState() => _NotesDetailScreenState();
}

class _NotesDetailScreenState extends State<NotesDetailScreen> {
  NoteModel _note = NoteModel();
  String _title = 'New note';
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _textFocusNode = FocusNode();
  bool _inited = false;
  bool _editMode = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
      if (_editMode) {
        _nameFocusNode.requestFocus();
      } else {
        _formKey.currentState.reset();
      }
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
    var noteProvider = NoteProvider();
    var dateNow = new DateTime.now().toUtc().millisecondsSinceEpoch;
    _note.dateUpdate = dateNow;
    _note.abbr = _note.name.length > 1
        ? ('${_note.name[0]}${_note.name[1]}').toUpperCase()
        : 'SN';
    if (_note.id == null) {
      _note.color = ColorHelper.generateColor();
      _note.dateCreate = dateNow;
      await noteProvider.insert(_note);
    } else {
      await noteProvider.update(_note);
    }
    Navigator.pop(context);
  }

  _delete() async {
    var noteProvider = NoteProvider();
    await noteProvider.delete(_note.id);
    Navigator.pop(context);
  }

  _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete "${_note.name}"'),
          content: Text('Are you sure you want to delete the note?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Delete'),
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

  _cancel() {
    Navigator.pop(context);
  }

  @override
  void didChangeDependencies() {
    var arguments = ModalRoute.of(context).settings.arguments;
    if (!_inited && arguments != null) {
      _note = arguments;
      _title = _note.name;
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
                onPressed: _note.id != null ? _toggleEditMode : _cancel,
              )
            : null,
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
                  key: Key('name'),
                  autocorrect: false,
                  autofocus: _editMode,
                  enabled: _editMode,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Note name',
                  ),
                  initialValue: _note.name,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter name';
                    }
                  },
                  onFieldSubmitted: (text) {
                    _nameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_textFocusNode);
                  },
                  onSaved: (text) {
                    _note.name = text;
                  },
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  key: Key('text'),
                  autocorrect: true,
                  enabled: _editMode,
                  focusNode: _textFocusNode,
                  maxLines: 15,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Text',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _note.text,
                  onSaved: (text) {
                    _note.text = text;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _note.id != null && _editMode
          ? FloatingActionButton(
              onPressed: _showConfirmDialog,
              tooltip: 'Delete a credential',
              backgroundColor: Colors.red,
              child: Icon(Icons.delete),
            )
          : (_note.id != null && !_editMode
              ? FloatingActionButton(
                  onPressed: _toggleEditMode,
                  tooltip: 'Edit a credential',
                  child: Icon(Icons.edit),
                )
              : null),
    );
  }
}
