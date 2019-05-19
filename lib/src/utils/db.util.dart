import 'dart:async';
import 'dart:io';
import 'package:synchronized/synchronized.dart';
import 'package:sqflite/sqflite.dart';
import "package:path/path.dart" show join;

import 'package:password_manager/src/utils/crypt.util.dart';
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

  Future<String> get encryptDbPath async {
    String dirPath = await getDatabasesPath();
    return join(dirPath, _dbName + '.db.encrypt');
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

  Future<dynamic> close() async {
    if (_dbase == null) {
      return null;
    }
    var result = await _dbase.close();
    _dbase = null;
    return result;
  }

  Future<bool> existsDb() async {
    String encryptDbPath = await this.encryptDbPath;
    var encryptDbFile = File(encryptDbPath);
    bool exists = encryptDbFile.existsSync();
    return exists;
  }

  Future<bool> deleteDb() async {
    try {
      await this.close();
      String dbPath = await this.dbPath;
      String encryptDbPath = await this.encryptDbPath;
      var encryptDbFile = File(encryptDbPath);
      await deleteDatabase(dbPath);
      encryptDbFile.deleteSync();
    } catch (e) {
      print('Database deleting error: $e');
      return false;
    }
    return true;
  }

  Future<bool> encryptDb(password) async {
    this.close();
    String dbPath = await this.dbPath;
    String encryptDbPath = await this.encryptDbPath;
    var dbFile = File(dbPath);
    var encryptDbFile = File(encryptDbPath);
    bool exists = dbFile.existsSync();
    if (!exists) {
      return false;
    }
    var dataBytes = dbFile.readAsBytesSync();
    var encrypted;
    try {
      encrypted = CryptHelper.encryptBytes(password, dataBytes);
    } catch (e) {
      return false;
    }
    encryptDbFile.writeAsBytesSync(encrypted);
    await deleteDatabase(dbPath);
    return true;
  }

  Future<bool> decryptDb(password) async {
    this.close();
    String encryptDbPath = await this.encryptDbPath;
    String dbPath = await this.dbPath;
    var encryptDbFile = File(encryptDbPath);
    var dbFile = File(dbPath);
    bool exists = encryptDbFile.existsSync();
    if (!exists) {
      return false;
    }
    var dataBytes = encryptDbFile.readAsBytesSync();
    var decrypted;
    try {
      decrypted = CryptHelper.decryptBytes(password, dataBytes);
    } catch (e) {
      return false;
    }
    dbFile.writeAsBytesSync(decrypted);
    return true;
  }
}
