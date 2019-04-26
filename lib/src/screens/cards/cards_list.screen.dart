import 'package:flutter/material.dart';

import 'package:password_manager/src/drawer.dart';
import 'package:password_manager/src/models/card.model.dart';

class CardsListScreen extends StatefulWidget {
  @override
  _CardsListScreenState createState() => _CardsListScreenState();
}

class _CardsListScreenState extends State<CardsListScreen> {
  final TextEditingController _filter = new TextEditingController();
  final _cardProvider = CardProvider();
  Widget _appBarTitle = Text('Credit cards');
  Icon _searchIcon = Icon(Icons.search);
  String _searchText = '';
  List<CardModel> _itemsList = [];
  List<CardModel> _filteredList = [];

  _CardsListScreenState() {
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
                  c.owner.toLowerCase().contains(_searchText) ||
                  c.cardnumber.toLowerCase().contains(_searchText))
              .toList();
        });
      }
    });
  }

  Future<List<CardModel>> _fetchList() async {
    _itemsList = await _cardProvider.getList();
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
        _appBarTitle = Text('Credit cards');
        _filter.clear();
      }
    });
  }

  _create() {
    Navigator.pushNamed(context, '/cardsDetail');
  }

  _showDetails(card) {
    Navigator.pushNamed(
      context,
      '/cardsDetail',
      arguments: card,
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
      body: FutureBuilder<List<CardModel>>(
        future: _fetchList(),
        builder:
            (BuildContext context, AsyncSnapshot<List<CardModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: _filteredList.length,
              itemBuilder: (BuildContext context, int index) {
                CardModel item = _filteredList[index];
                return ListTile(
                  title: Text(item.name,
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('valid until ${item.exp}'),
                  leading: Container(
                    alignment: Alignment.center,
                    width: 50.0,
                    height: 50.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueGrey,
                    ),
                    child: Text('CC',
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
        tooltip: 'Create a card',
        child: Icon(Icons.add),
      ),
    );
  }
}
