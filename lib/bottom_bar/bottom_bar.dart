import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wecoordi/my_page/my_page_home_login.dart';

import '../main.dart';
import '../my_page/my_page_home_logout.dart';

class BottomBar extends StatelessWidget {
  final int Function(BuildContext) bottomNavIndex;
  final Function(int) onItemTapped;
  final BuildContext context;

  //파이어베이스의 인스턴스 가져옴
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //유저아이디
  late final String? userId;

  void _getUserData() async {
    // Firebase 사용자 정보 가져오기
    User? user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      // Firestore에서 userId를 사용하여 데이터 조회
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('user') // 'users' 컬렉션을 사용하거나 원하는 컬렉션으로 변경
          .doc(userId)
          .get();
      // userId에 해당하는 문서가 없을 경우, 버튼을 추가하는 등의 처리를 할 수 있음
      if (!document.exists) {
        // 회원이 아닐경우
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()), // 프로필 페이지로 이동
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
  }

  BottomBar({required this.bottomNavIndex, required this.onItemTapped, required this.context});

  @override
  Widget build(BuildContext context) {
    int currentIndex = bottomNavIndex(context); // bottomNavInex 함수를 호출하여 인덱스 값을 가져옴

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
          _getUserData();
        } else if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => wecoordiHome()), // 메인 페이지로 이동
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
