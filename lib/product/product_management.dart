import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bottom_bar/bottom_bar.dart';
import '../wecoordi_provider/wecoordi_provider.dart';

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  State<ProductManagement> createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  // botomNavIndex를 프로바이더에서 꺼내옴
  int _bottomNavIndex(BuildContext context) {
    return Provider.of<WecoordiProvider>(context).bottomNavIndex;
  }

  //탭 클릭 시 프로바이더에 탭의 인덱스를 저장
  void _onItemTapped(BuildContext context, int index) {
    Provider.of<WecoordiProvider>(context, listen: false).bottomNavIndex =
        index;
  }

  String userId = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initState() {
    super.initState();
    fetchProductData(context);
  }

  Future<void> fetchProductData(context) async {
    try {
      // 프로바이더에서 가져와도 되지만, 혹시나 모를 상황을 대비해, 현재 로그인되어있는 아이디로 가져온다.
      User? user = _auth.currentUser;
      String userId =
          Provider.of<WecoordiProvider>(context, listen: false).userId;

      if (user != null && user.email == userId) {
        //
      } else {
        // 현재로그인아이디, 앱의 프로바이더에 설정된 아이디가 아니면 전 화면으로 튕겨나감.
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 유저 아이디
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            Center(child: Text('상품관리', style: TextStyle(color: Colors.black))),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 버튼을 눌렀을 때 동작할 로직 추가
            },
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
