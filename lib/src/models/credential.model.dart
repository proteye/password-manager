import 'dart:convert';

import 'package:password_manager/src/utils/db.util.dart';

DbHelper dbHelper = new DbHelper();

final String tableName = 'Credential';
final String columnId = '_id';
final int defaultLimit = 100;

class CredentialModel {
  int id;
  String name;
  String url;
  String username;
  String password;
  String comment;
  String color;
  String abbr;
  int dateCreate;
  int dateUpdate;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'url': url,
      'username': username,
      'password': password,
      'comment': comment,
      'color': color,
      'abbr': abbr,
      'dateCreate': dateCreate,
      'dateUpdate': dateUpdate,
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  CredentialModel();

  CredentialModel.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map['name'];
    url = map['url'];
    username = map['username'];
    password = map['password'];
    comment = map['comment'];
    color = map['color'];
    abbr = map['abbr'];
    dateCreate = map['dateCreate'];
    dateUpdate = map['dateUpdate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'username': username,
      'password': password,
      'comment': comment,
      'color': color,
      'abbr': abbr,
      'dateCreate': dateCreate,
      'dateUpdate': dateUpdate,
    };
  }

  @override
  String toString() {
    return json.encode(this);
  }
}

class CredentialProvider {
  Future<List<CredentialModel>> getList({int limit, int offset}) async {
    final db = await dbHelper.database;
    var res = await db.query(
      tableName,
      limit: limit ?? defaultLimit,
      offset: offset ?? 0,
    );
    return res.isNotEmpty
        ? res.map((item) => CredentialModel.fromMap(item)).toList()
        : [];
  }

  Future<CredentialModel> getOne(int id) async {
    final db = await dbHelper.database;
    var res = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return res.isNotEmpty ? CredentialModel.fromMap(res.first) : Null;
  }

  Future<CredentialModel> insert(CredentialModel credential) async {
    final db = await dbHelper.database;
    credential.id = await db.insert(tableName, credential.toMap());
    return credential;
  }

  Future<int> update(CredentialModel credential) async {
    final db = await dbHelper.database;
    return await db.update(
      tableName,
      credential.toMap(),
      where: '$columnId = ?',
      whereArgs: [credential.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
