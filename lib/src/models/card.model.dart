import 'dart:convert';

import 'package:password_manager/src/utils/db.util.dart';

DbHelper dbHelper = new DbHelper();

final String tableName = 'Card';
final String columnId = '_id';
final int defaultLimit = 100;

class CardModel {
  int id;
  String name;
  String cardnumber;
  String owner;
  String exp;
  int expMonth;
  int expYear;
  String cvc;
  String type;
  int dateCreate;
  int dateUpdate;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'cardnumber': cardnumber,
      'owner': owner,
      'exp': exp,
      'expMonth': expMonth,
      'expYear': expYear,
      'cvc': cvc,
      'type': type,
      'dateCreate': dateCreate,
      'dateUpdate': dateUpdate,
    };

    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  CardModel();

  CardModel.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map['name'];
    cardnumber = map['cardnumber'];
    owner = map['owner'];
    exp = map['exp'];
    expMonth = map['expMonth'];
    expYear = map['expYear'];
    cvc = map['cvc'];
    type = map['type'];
    dateCreate = map['dateCreate'];
    dateUpdate = map['dateUpdate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cardnumber': cardnumber,
      'owner': owner,
      'exp': exp,
      'expMonth': expMonth,
      'expYear': expYear,
      'cvc': cvc,
      'type': type,
      'dateCreate': dateCreate,
      'dateUpdate': dateUpdate,
    };
  }

  @override
  String toString() {
    return json.encode(this);
  }
}

class CardProvider {
  Future<List<CardModel>> getList({int limit, int offset}) async {
    final db = await dbHelper.database;
    var res = await db.query(
      tableName,
      limit: limit ?? defaultLimit,
      offset: offset ?? 0,
    );
    return res.isNotEmpty
        ? res.map((item) => CardModel.fromMap(item)).toList()
        : [];
  }

  Future<CardModel> getOne(int id) async {
    final db = await dbHelper.database;
    var res = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return res.isNotEmpty ? CardModel.fromMap(res.first) : Null;
  }

  Future<CardModel> insert(CardModel card) async {
    final db = await dbHelper.database;
    card.id = await db.insert(tableName, card.toMap());
    return card;
  }

  Future<int> update(CardModel card) async {
    final db = await dbHelper.database;
    return await db.update(
      tableName,
      card.toMap(),
      where: '$columnId = ?',
      whereArgs: [card.id],
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
