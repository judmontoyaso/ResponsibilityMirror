import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  final Box _settingsBox = Hive.box('settings');
  
  bool _darkMode = true;
  bool _cameraMode = false;
  String _userName = '';
  
  bool get darkMode => _darkMode;
  bool get cameraMode => _cameraMode;
  String get userName => _userName;

  SettingsProvider() {
    loadSettings();
  }

  void loadSettings() {
    _darkMode = _settingsBox.get('darkMode', defaultValue: true);
    _cameraMode = _settingsBox.get('cameraMode', defaultValue: false);
    _userName = _settingsBox.get('userName', defaultValue: '');
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _settingsBox.put('darkMode', value);
    notifyListeners();
  }

  Future<void> setCameraMode(bool value) async {
    _cameraMode = value;
    await _settingsBox.put('cameraMode', value);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _settingsBox.put('userName', name);
    notifyListeners();
  }
}
