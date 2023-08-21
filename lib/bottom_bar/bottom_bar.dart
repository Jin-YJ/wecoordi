import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wecoordi/my_page/my_page_home_login.dart';
import 'package:wecoordi/my_page/my_page_home_logout.dart';

import '../wecoordiMain.dart';
import '../wecoordi_provider/wecoordi_provider.dart';

class BottomBar extends StatelessWidget {
  final int Function(BuildContext) bottomNavIndex;
  final Function(int) onItemTapped;
  final BuildContext context;

  //유저아이디
  late final String? userId;

  void _getUserData(context) async {
    // Firebase 사용자 정보 가져오기
    userId = Provider.of<WecoordiProvider>(context, listen: false).userId;

    // Firestore에서 userId를 사용하여 데이터 조회
    QuerySnapshot userData = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: userId)
        .get();
    if (!userData.docs.isNotEmpty) {
      // 회원이 아닐경우
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyProfilePageLogout()), // 프로필 페이지로 이동
      );
      // 예를 들어, 버튼 추가 등
    } else {
      //회원일 경우
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyPageHomeLogin()),
      );
    }
  }

  BottomBar(
      {required this.bottomNavIndex,
      required this.onItemTapped,
      required this.context});

  @override
  Widget build(BuildContext context) {
    int currentIndex =
        bottomNavIndex(context); // bottomNavInex 함수를 호출하여 인덱스 값을 가져옴

    return CupertinoTabBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          // label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.heart),
          // label: 'Heart',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          // label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        // 바텀바의 아이템을 클릭했을 때 처리하는 로직
        // 예를 들어, 클릭한 인덱스에 따라 화면 전환 등의 작업 수행
        if (index == 2) {
          _getUserData(context);
        } else if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WecoordiMain()), // 메인 페이지로 이동
          );
        } else {
          // 다른 인덱스의 아이템을 클릭한 경우, 메인 클래스에서 처리
        }
        onItemTapped(index);
      },
      activeColor: Colors.blue,
      inactiveColor: Colors.grey,
      backgroundColor: Colors.white,
    );
  }
}
