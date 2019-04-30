import 'package:flutter/material.dart';

import 'package:password_manager/src/routing.dart';
import 'package:password_manager/src/widgets/logo.widget.dart';

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
              decoration: BoxDecoration(color: Colors.black87),
              child: LogoWidget(),
            );
          }

          var item = _items[index - 1];
          var isLast = index == _items.length;
          return ListTile(
            title: Text(
              item['title'],
              style: TextStyle(color: isLast ? Colors.red : null),
            ),
            trailing: !isLast ? Icon(Icons.arrow_right) : null,
            leading: Icon(item['icon'], color: isLast ? Colors.red : null),
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
