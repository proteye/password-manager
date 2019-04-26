import 'dart:async';
import 'package:synchronized/synchronized.dart';
import 'package:sqflite/sqflite.dart';
import "package:path/path.dart" show join;

import 'package:password_manager/src/config.dart';

const VERSION = 1;
const TABLES_CREATE_QUERIES = [
  'CREATE TABLE Credential (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, url TEXT, username TEXT, password TEXT, comment TEXT, color TEXT, abbr TEXT, dateCreate INTEGER, dateUpdate INTEGER);',
  'CREATE TABLE Card (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, cardnumber TEXT, owner TEXT, exp TEXT, expMonth INTEGER, expYear INTEGER, cvc TEXT, type TEXT, dateCreate INTEGER, dateUpdate INTEGER);',
  'CREATE TABLE Note (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, text TEXT, color TEXT, abbr TEXT, dateCreate INTEGER, dateUpdate INTEGER);',
  'CREATE TABLE Setting (name TEXT PRIMARY KEY, value TEXT, dateCreate INTEGER, dateUpdate INTEGER);',
];

class DbHelper {
  Database _dbase;
  final _lock = new Lock();
  static final DbHelper _db = new DbHelper._internal();
  String _dbName = Config.DEFAULT_DBNAME;

  factory DbHelper() {
    return _db;
  }

  DbHelper._internal();

  Future _onConfigure(Database db) async {
    // Add support for cascade delete
    await db.execute("PRAGMA foreign_keys = ON");
  }

  Future _onCreate(Database db, int version) async {
    for (var query in TABLES_CREATE_QUERIES) {
      await db.execute(query);
    }
  }

  Future _onOpen(Database db) async {
    // Database is open, print its version
    print('db version: ${await db.getVersion()}, db name: ${this._dbName}');
  }

  String get dbName {
    return this._dbName;
  }

  set dbName(name) {
    if (name != null && name != '') {
      this._dbName = name;
    }
  }

  Future<String> get dbPath async {
    String dirPath = await getDatabasesPath();
    return join(dirPath, _dbName + '.db');
  }

  Future<Database> get database async {
    if (_dbase == null) {
      await _lock.synchronized(() async {
        // Check again once entering the synchronized block
        if (_dbase == null) {
          String dbPath = await this.dbPath;
          _dbase = await openDatabase(dbPath,
              version: VERSION,
              onConfigure: _onConfigure,
              onCreate: _onCreate,
              onOpen: _onOpen);
        }
      });
    }
    return _dbase;
  }

  Future<dynamic> close() {
    if (_dbase == null) {
      return null;
    }
    return _dbase.close();
  }

  Future<bool> deleteDb() async {
    try {
      await this.close();
      String dbPath = await this.dbPath;
      await deleteDatabase(dbPath);
    } catch (e) {
      print('Database deleting error: $e');
      return false;
    }
    return true;
  }
}
