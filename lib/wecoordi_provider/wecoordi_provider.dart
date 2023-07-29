import 'package:flutter/material.dart';

class WecoordiProvider extends ChangeNotifier {
  int _bottomNavIndex = 0;

  int get bottomNavIndex => _bottomNavIndex;

  set bottomNavIndex(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }
}
