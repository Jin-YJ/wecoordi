import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_bar/wecoordiappbar.dart';
import '../bottom_bar/bottom_bar.dart';
import '../wecoordi_provider/wecoordi_provider.dart';

class MyPageHomeLogin extends StatefulWidget {
  @override
  State<MyPageHomeLogin> createState() => _MyPageHomeLogin();
}

class _MyPageHomeLogin extends State<MyPageHomeLogin> {
  int _bottomNavIndex(BuildContext context) {
    return Provider.of<WecoordiProvider>(context).bottomNavIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    Provider.of<WecoordiProvider>(context, listen: false).bottomNavIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wecoordiAppbar(),
      body: Text('로그인성공'),
      bottomNavigationBar: BottomBar(
        bottomNavIndex: _bottomNavIndex,
        onItemTapped: (index) => _onItemTapped(context, index),
        context: context,
      ),
    );
  }
}
