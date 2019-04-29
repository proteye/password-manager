import 'dart:convert';

import 'package:password_manager/src/utils/db.util.dart';

DbHelper dbHelper = new DbHelper();

final String tableName = 'Setting';
final int defaultLimit = 100;

class SettingModel {
  String name;
  String value;
  int dateCreate;
  int dateUpdate;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'value': value,
      'dateCreate': dateCreate,
      'dateUpdate': dateUpdate,
    };

    return map;
  }

  SettingModel();

  SettingModel.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    value = map['value'];
    dateCreate = map['dateCreate'];
    dateUpdate = map['dateUpdate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'dateCreate': dateCreate,
      'dateUpdate': dateUpdate,
    };
  }

  @override
  String toString() {
    return json.encode(this);
  }
}

class SettingProvider {
  Future<List<SettingModel>> getList({int limit, int offset}) async {
    final db = await dbHelper.database;
    var res = await db.query(
      tableName,
      limit: limit ?? defaultLimit,
      offset: offset ?? 0,
    );
    return res.isNotEmpty
        ? res.map((item) => SettingModel.fromMap(item)).toList()
        : [];
  }

  Future<SettingModel> getOne(String name) async {
    final db = await dbHelper.database;
    var res = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
    );
    return res.isNotEmpty ? SettingModel.fromMap(res.first) : Null;
  }

  Future<SettingModel> insert(SettingModel setting) async {
    final db = await dbHelper.database;
    try {
      await db.insert(tableName, setting.toMap());
    } catch (e) {
      await this.update(setting);
    }
    return setting;
  }

  Future<int> update(SettingModel setting) async {
    final db = await dbHelper.database;
    return await db.update(
      tableName,
      setting.toMap(),
      where: 'name = ?',
      whereArgs: [setting.name],
    );
  }

  Future updateAll(List<SettingModel> settings, {callback}) async {
    settings.forEach((setting) async {
      await this.insert(setting);
      if (settings.last.name == setting.name && callback != null) {
        callback();
      }
    });
  }

  Future<int> delete(String name) async {
    final db = await dbHelper.database;
    return await db.delete(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
    );
  }
}
