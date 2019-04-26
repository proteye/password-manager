import 'dart:convert';

import 'package:password_manager/src/utils/db.util.dart';

DbHelper dbHelper = new DbHelper();

final String tableName = 'Note';
final String columnId = '_id';
final int defaultLimit = 100;

class NoteModel {
  int id;
  String name;
  String text;
  String color;
  String abbr;
  int dateCreate;
  int dateUpdate;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'text': text,
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

  NoteModel();

  NoteModel.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map['name'];
    text = map['text'];
    color = map['color'];
    abbr = map['abbr'];
    dateCreate = map['dateCreate'];
    dateUpdate = map['dateUpdate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'text': text,
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

class NoteProvider {
  Future<List<NoteModel>> getList({int limit, int offset}) async {
    final db = await dbHelper.database;
    var res = await db.query(
      tableName,
      limit: limit ?? defaultLimit,
      offset: offset ?? 0,
    );
    return res.isNotEmpty
        ? res.map((item) => NoteModel.fromMap(item)).toList()
        : [];
  }

  Future<NoteModel> getOne(int id) async {
    final db = await dbHelper.database;
    var res = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return res.isNotEmpty ? NoteModel.fromMap(res.first) : Null;
  }

  Future<NoteModel> insert(NoteModel note) async {
    final db = await dbHelper.database;
    note.id = await db.insert(tableName, note.toMap());
    return note;
  }

  Future<int> update(NoteModel note) async {
    final db = await dbHelper.database;
    return await db.update(
      tableName,
      note.toMap(),
      where: '$columnId = ?',
      whereArgs: [note.id],
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
