import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_bar/wecoordiappbar.dart';
import 'bottom_bar/bottom_bar.dart';
import 'wecoordi_main/following.dart';
import 'wecoordi_main/recommend.dart';
import 'wecoordi_provider/wecoordi_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WecoordiProvider()),

        // 다른 프로바이더가 있다면 여기에 추가로 등록합니다.
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: wecoordiHome(),
    );
  }
}

class wecoordiHome extends StatefulWidget {
  wecoordiHome({Key? key}) : super(key: key);

  @override
  _wecoordiHomeState createState() => _wecoordiHomeState();
}

class _wecoordiHomeState extends State<wecoordiHome> {
  int _currentIndex = 0; //팔로우, 추천 탭이동 인덱스
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
      body: Column(
        children: [
          Container(
            color: Colors.white,
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (context, index) {
                return TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    index == 0 ? '팔로잉' : '추천',
                    style: TextStyle(color: Colors.black),
                  ),
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
        bottomNavIndex: _bottomNavIndex,
        onItemTapped: (index) => _onItemTapped(context, index),
        context: context,
      ),
    );
  }
}
