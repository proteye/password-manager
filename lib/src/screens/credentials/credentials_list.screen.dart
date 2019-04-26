import 'package:flutter/material.dart';

import 'package:password_manager/src/drawer.dart';
import 'package:password_manager/src/models/credential.model.dart';

class CredentialsListScreen extends StatefulWidget {
  @override
  _CredentialsListScreenState createState() => _CredentialsListScreenState();
}

class _CredentialsListScreenState extends State<CredentialsListScreen> {
  final TextEditingController _filter = new TextEditingController();
  final _credentialProvider = CredentialProvider();
  Widget _appBarTitle = Text('Credentials');
  Icon _searchIcon = Icon(Icons.search);
  String _searchText = '';
  List<CredentialModel> _itemsList = [];
  List<CredentialModel> _filteredList = [];

  _CredentialsListScreenState() {
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
              .where((c) =>
                  c.name.toLowerCase().contains(_searchText) ||
                  c.url.toLowerCase().contains(_searchText))
              .toList();
        });
      }
    });
  }

  Future<List<CredentialModel>> _fetchList() async {
    _itemsList = await _credentialProvider.getList();
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
        _appBarTitle = Text('Credentials');
        _filter.clear();
      }
    });
  }

  _create() {
    Navigator.pushNamed(context, '/credentialsDetail');
  }

  _showDetails(credential) {
    Navigator.pushNamed(
      context,
      '/credentialsDetail',
      arguments: credential,
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
      body: FutureBuilder<List<CredentialModel>>(
        future: _fetchList(),
        builder: (BuildContext context,
            AsyncSnapshot<List<CredentialModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: _filteredList.length,
              itemBuilder: (BuildContext context, int index) {
                CredentialModel item = _filteredList[index];
                return ListTile(
                  title: Text(item.name,
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(item.username),
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
        tooltip: 'Create a credential',
        child: Icon(Icons.add),
      ),
    );
  }
}
