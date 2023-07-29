import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../main.dart';
import '../my_page/my_page_home_logout.dart';

class BottomBar extends StatelessWidget {
  final int Function(BuildContext) bottomNavIndex;
  final Function(int) onItemTapped;
  final BuildContext context;

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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()), // 프로필 페이지로 이동
          );
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
