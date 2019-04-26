import 'package:flutter/material.dart';

import 'package:password_manager/src/routing.dart';

class AppDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> _items = Routing.menuMap();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return DrawerHeader(
              child: Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 10.0),
                      width: 50.0,
                      height: 50.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent,
                      ),
                      child: Icon(
                        Icons.vpn_key,
                        color: Colors.white,
                        size: 18.0,
                      ),
                    ),
                    Text(
                      'Password ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manager',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(color: Colors.black87),
            );
          }

          var item = _items[index - 1];
          return ListTile(
            title: Text(item['title']),
            trailing: Icon(Icons.arrow_right),
            leading: Icon(item['icon']),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, item['path'], (route) => false);
            },
          );
        },
      ),
    );
  }
}
