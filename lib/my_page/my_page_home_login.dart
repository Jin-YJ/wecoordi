import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_bar/wecoordiappbar.dart';
import '../bottom_bar/bottom_bar.dart';
import '../wecoordi_provider/wecoordi_provider.dart';
import 'my_page_home_logout.dart';

class MyPageHomeLogin extends StatefulWidget {
  @override
  State<MyPageHomeLogin> createState() => _MyPageHomeLogin();
}

class _MyPageHomeLogin extends State<MyPageHomeLogin> {
  // Firestore instance 생성
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String? profileImage = null;
  late String? nickName = null;
  late int? amount = null;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String userId =
        Provider.of<WecoordiProvider>(context, listen: false).userId;

    QuerySnapshot userSnapshot = await _firestore
        .collection('user')
        .where('email', isEqualTo: userId)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      Map<String, dynamic> data =
          userSnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        profileImage = data['profileImage'];
        nickName = data['nickName'];
        amount = data['amount'];
      });
    }
  }

  //로그아웃
  Future<void> _signOut() async {
    try {
      Provider.of<WecoordiProvider>(context, listen: false).userId = '';
      await _auth.signOut(); // FirebaseAuth에서 로그아웃
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyProfilePageLogout()),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  int _bottomNavIndex(BuildContext context) {
    return Provider.of<WecoordiProvider>(context).bottomNavIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    Provider.of<WecoordiProvider>(context, listen: false).bottomNavIndex =
        index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wecoordiAppbar(),
      body: Padding(
        padding:
            EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0), // 좌우 패딩도 추가
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (profileImage != null && profileImage != '')
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImage!),
                      radius: 30,
                    )
                  else
                    CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/blank_profile.png'),
                      radius: 30,
                    ),
                  SizedBox(width: 15),
                  if (nickName != null) Text(nickName!),
                ],
              ),

              SizedBox(height: 20),

              // 판매 금액을 박스로 감싸기
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // 박스의 배경색을 조금 밝게 변경
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(CupertinoIcons.money_dollar_circle,
                            color: Colors.grey[600]),
                        SizedBox(width: 10),
                        if (amount != null) Text('판매 금액: $amount 원'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // 계좌 등록 로직
                          },
                          icon: Icon(Icons.add,
                              color: Colors.grey[700]), // 아이콘 색상을 중립적으로 변경
                          label: Text('계좌 등록'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.white), // 버튼의 배경색 변경
                            foregroundColor: MaterialStateProperty.all(
                                Colors.grey[700]), // 버튼의 텍스트 및 아이콘 색상 변경
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // 계좌 송금 로직
                          },
                          icon: Icon(Icons.monetization_on,
                              color: Colors.grey[700]), // 아이콘 색상을 중립적으로 변경
                          label: Text('계좌 송금'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.white), // 버튼의 배경색 변경
                            foregroundColor: MaterialStateProperty.all(
                                Colors.grey[700]), // 버튼의 텍스트 및 아이콘 색상 변경
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Text('거래내역',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // 판매 내역 텍스트를 탭했을 때의 로직
                      print("판매 내역 클릭");
                    },
                    child: Text('판매 내역'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // 구매 내역 텍스트를 탭했을 때의 로직
                      print("구매 내역 클릭");
                    },
                    child: Text('구매 내역'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // 로그아웃 텍스트를 탭했을 때의 로직
                      _signOut();
                      print("로그아웃 클릭");
                    },
                    child: Text('로그아웃'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(
        bottomNavIndex: _bottomNavIndex,
        onItemTapped: (index) => _onItemTapped(context, index),
        context: context,
      ),
    );
  }
}
