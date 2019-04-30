import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final String prefKey = 'settings';

class SettingsModel {
  String pin = '';
  bool fingerprint = false;
  int dateCreate;
  int dateUpdate;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'pin': pin,
      'fingerprint': fingerprint,
      'dateCreate': dateCreate,
      'dateUpdate': dateUpdate,
    };

    return map;
  }

  SettingsModel();

  SettingsModel.fromMap(Map<String, dynamic> map) {
    pin = map['pin'];
    fingerprint = map['fingerprint'];
    dateCreate = map['dateCreate'];
    dateUpdate = map['dateUpdate'];
  }

  SettingsModel.fromJson(String jsonString) {
    var map = json.decode(jsonString);
    pin = map['pin'] ?? '';
    fingerprint = map['fingerprint'] ? true : false;
    dateCreate = map['dateCreate'];
    dateUpdate = map['dateUpdate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'pin': pin,
      'fingerprint': fingerprint,
      'dateCreate': dateCreate,
      'dateUpdate': dateUpdate,
    };
  }

  @override
  String toString() {
    return json.encode(this);
  }
}

class SettingsProvider {
  Future<SettingsModel> getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SettingsModel settings = SettingsModel();
    String settingsJson = prefs.getString(prefKey) ?? null;
    if (settingsJson != null) {
      settings = SettingsModel.fromJson(settingsJson);
    }
    return settings;
  }

  Future<bool> setSettings(SettingsModel settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dateNow = new DateTime.now().toUtc().millisecondsSinceEpoch;
    if (settings.dateCreate == null) {
      settings.dateCreate = dateNow;
    }
    settings.dateUpdate = dateNow;
    return await prefs.setString(prefKey, settings.toString());
  }
}
