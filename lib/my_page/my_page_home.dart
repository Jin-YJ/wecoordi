import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_bar/wecoordiappbar.dart';
import '../bottom_bar/bottom_bar.dart';
import '../wecoordi_provider/wecoordi_provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _bottomNavIndex(BuildContext context) { //바텀네비게이션바 인덱스
    return Provider.of<WecoordiProvider>(context).bottomNavIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    print(index);
    // 프로바이더를 통해 선택된 인덱스를 업데이트합니다.
    Provider.of<WecoordiProvider>(context, listen: false).bottomNavIndex = index;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: wecoordiAppbar(),
      body: Center(
        child: Text('내 정보 화면'), // 여기에 "내 정보" 페이지의 내용을 추가해주세요.
      ),
      bottomNavigationBar: BottomBar(
        bottomNavIndex: _bottomNavIndex, // 바텀네비게이션바 인덱스를 프로바이더에서 직접 가져옵니다.
        onItemTapped: (index) => _onItemTapped(context, index),
        context: context,
      ),
    );
  }
}
