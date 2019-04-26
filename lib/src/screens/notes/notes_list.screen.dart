import 'package:flutter/material.dart';

import 'package:password_manager/src/drawer.dart';
import 'package:password_manager/src/models/note.model.dart';

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final TextEditingController _filter = new TextEditingController();
  final _noteProvider = NoteProvider();
  Widget _appBarTitle = Text('Notes');
  Icon _searchIcon = Icon(Icons.search);
  String _searchText = '';
  List<NoteModel> _itemsList = [];
  List<NoteModel> _filteredList = [];

  _NotesListScreenState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = '';
          _filteredList = _itemsList;
        });
      } else {
        setState(() {
          _searchText = _filter.text.toLowerCase();
          _filteredList = _itemsList
              .where((c) => c.name.toLowerCase().contains(_searchText))
              .toList();
        });
      }
    });
  }

  Future<List<NoteModel>> _fetchList() async {
    _itemsList = await _noteProvider.getList();
    if (_searchText.isEmpty) {
      _filteredList = _itemsList;
    }
    return _itemsList;
  }

  _search() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = Icon(Icons.close);
        _appBarTitle = TextField(
            controller: _filter,
            autocorrect: false,
            autofocus: true,
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration.collapsed(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white70),
            ));
      } else {
        _searchIcon = Icon(Icons.search);
        _appBarTitle = Text('Notes');
        _filter.clear();
      }
    });
  }

  _create() {
    Navigator.pushNamed(context, '/notesDetail');
  }

  _showDetails(note) {
    Navigator.pushNamed(
      context,
      '/notesDetail',
      arguments: note,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: _search,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<List<NoteModel>>(
        future: _fetchList(),
        builder:
            (BuildContext context, AsyncSnapshot<List<NoteModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: _filteredList.length,
              itemBuilder: (BuildContext context, int index) {
                NoteModel item = _filteredList[index];
                return ListTile(
                  title: Text(item.name,
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('secure note'),
                  leading: Container(
                    alignment: Alignment.center,
                    width: 50.0,
                    height: 50.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(int.parse(item.color)),
                    ),
                    child: Text(item.abbr,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    _showDetails(item);
                  },
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        tooltip: 'Create a note',
        child: Icon(Icons.add),
      ),
    );
  }
}
