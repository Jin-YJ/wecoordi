import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wecoordi/wecoordi_main/recommend.dart';
import 'app_bar/wecoordiappbar.dart';
import 'bottom_bar/bottom_bar.dart';
import 'wecoordi_main/following.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: wecoordiHome(),
    );
  }
}

class wecoordiHome extends StatefulWidget {
  const wecoordiHome({super.key});

  @override
  _wecoordiHomeState createState() => _wecoordiHomeState();
}

class _wecoordiHomeState extends State<wecoordiHome> {
  int _currentIndex = 0;
  int _selectedIndex = 0;

   void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wecoordiAppbar(),
      body: Column(
        children: [
          Container(
            color: Colors.white, // 버튼 배경색을 바탕색과 동일하게 설정
            height: 48, // 버튼 높이
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // 가로로 스크롤
              itemCount: 2, // 버튼 개수
              itemBuilder: (context, index) {
                return TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white, // 버튼 배경색을 바탕색과 동일하게 설정
                    primary: Colors.black, // 텍스트 색상
                    padding: EdgeInsets.symmetric(horizontal: 16), // 버튼 좌우 padding
                  ),
                  child: Text(index == 0 ? '팔로잉' : '추천', style: GoogleFonts.blackHanSans(textStyle: TextStyle(color: Colors.black))), // 버튼 텍스트
                );
              },
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                // 팔로잉 내용
                Following(),
                // 추천 내용
                recommend(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
