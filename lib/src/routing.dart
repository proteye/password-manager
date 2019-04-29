import 'package:flutter/material.dart';

import 'package:password_manager/src/screens/credentials/credentials_list.screen.dart';
import 'package:password_manager/src/screens/credentials/credentials_detail.screen.dart';
import 'package:password_manager/src/screens/cards/cards_list.screen.dart';
import 'package:password_manager/src/screens/cards/cards_detail.screen.dart';
import 'package:password_manager/src/screens/notes/notes_list.screen.dart';
import 'package:password_manager/src/screens/notes/notes_detail.screen.dart';
import 'package:password_manager/src/screens/password_generator/password_generator.screen.dart';
import 'package:password_manager/src/screens/settings/settings.screen.dart';
import 'package:password_manager/src/screens/settings/master_password.screen.dart';

class Routing {
  static routes() {
    return {
      '/': (context) => new CredentialsListScreen(),
      '/credentialsDetail': (context) => new CredentialsDetailScreen(),
      '/cards': (context) => new CardsListScreen(),
      '/cardsDetail': (context) => new CardsDetailScreen(),
      '/notes': (context) => new NotesListScreen(),
      '/notesDetail': (context) => new NotesDetailScreen(),
      '/passwordGenerator': (context) => new PasswordGeneratorScreen(),
      '/settings': (context) => new SettingsScreen(),
      '/masterPassword': (context) => new MasterPasswordScreen(),
    };
  }

  static List<Map<String, dynamic>> menuMap() {
    return [
      {
        'title': 'Credentials',
        'path': '/',
        'icon': Icons.vpn_key,
      },
      {
        'title': 'Credit cards',
        'path': '/cards',
        'icon': Icons.credit_card,
      },
      {
        'title': 'Notes',
        'path': '/notes',
        'icon': Icons.comment,
      },
      {
        'title': 'Password generator',
        'path': '/passwordGenerator',
        'icon': Icons.refresh,
      },
      {
        'title': 'Settings',
        'path': '/settings',
        'icon': Icons.settings,
      },
    ];
  }
}
