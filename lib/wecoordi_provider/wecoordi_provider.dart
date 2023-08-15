import 'package:flutter/material.dart';

class WecoordiProvider extends ChangeNotifier {
  int _bottomNavIndex = 0;
  String _userId = '';

  int get bottomNavIndex => _bottomNavIndex;
  String get userId => _userId;

  set bottomNavIndex(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }

  set userId(String userId) {
    _userId = userId;
    notifyListeners();
  }
}
