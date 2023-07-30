
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_bar/wecoordiappbar.dart';
import '../bottom_bar/bottom_bar.dart';
import '../wecoordi_provider/wecoordi_provider.dart';

// 피드를 상세보기 할 수 있는 화면
class FeedDetail extends StatelessWidget {
  final String profilePhotoUrl;
  final String memberId;
  final double height;
  final double weight;

  FeedDetail({
    required this.profilePhotoUrl,
    required this.memberId,
    required this.height,
    required this.weight,
  });

  int _bottomNavIndex(BuildContext context) {
    //바텀네비게이션바 인덱스
    return Provider.of<WecoordiProvider>(context).bottomNavIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    // 프로바이더를 통해 선택된 인덱스를 업데이트합니다.
    Provider.of<WecoordiProvider>(context, listen: false).bottomNavIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wecoordiAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(profilePhotoUrl),
            ),
            SizedBox(height: 10),
            Text(
              memberId,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '키: $height cm, 몸무게: $weight kg',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        bottomNavIndex: _bottomNavIndex,
        onItemTapped: (index) => _onItemTapped(context, index),
        context: context,
      )
    );
  }
}
