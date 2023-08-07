import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_bar/wecoordiappbar.dart';
import '../bottom_bar/bottom_bar.dart';
import '../wecoordi_provider/wecoordi_provider.dart';

// 피드를 상세보기 할 수 있는 화면
class FeedDetail extends StatelessWidget {
  final DocumentSnapshot? doc; // doc 코드를 저장할 변수

  FeedDetail({
    required this.doc,
  });

  int _bottomNavIndex(BuildContext context) {
    //바텀네비게이션바 인덱스
    return Provider.of<WecoordiProvider>(context).bottomNavIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    // 프로바이더를 통해 선택된 인덱스를 업데이트합니다.
    Provider.of<WecoordiProvider>(context, listen: false).bottomNavIndex =
        index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: wecoordiAppbar(),
        body: Center(),
        bottomNavigationBar: BottomBar(
          bottomNavIndex: _bottomNavIndex,
          onItemTapped: (index) => _onItemTapped(context, index),
          context: context,
        ));
  }
}
