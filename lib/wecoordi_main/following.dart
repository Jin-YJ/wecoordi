import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../feed/feed_main.dart';


class Following extends StatefulWidget {
  const Following({
    Key? key,
  }) : super(key: key);

  @override
  State<Following> createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DocumentSnapshot userInfo;
  List<DocumentSnapshot> followingData = []; // following 컬렉션 데이터를 담을 리스트
  List<String> followingUserIds = [];
  List<String> followingUserProfilePhotos = [];
  List<String> followingUserNickName = [];


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchUserDataAndFeeds();
    fetchDataAndDisplayData();
  }

  Future<void> fetchUserDataAndFeeds() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // following 서브컬렉션 가져오기
        QuerySnapshot followingSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.uid)
            .collection('following')
            .get();
            
        setState(() {
          followingData = followingSnapshot.docs; // following 컬렉션 데이터를 리스트에 저장
          followingUserIds = followingData.map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String? ?? '').toList();



        });

      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> fetchDataAndDisplayData() async {
    List<Map<String, dynamic>> userDataList = await getUserData();
    for (Map<String, dynamic> userData in userDataList) {
      followingUserProfilePhotos.add(userData['profileImage']) ;
      followingUserNickName.add(userData['nickName']);

    }
  }

  // user 컬렉션에서 해당 유저들의 데이터를 가져오는 함수
  Future<List<Map<String, dynamic>>> getUserData() async {
    List<Map<String, dynamic>> userDataList = [];
    for (String userId in followingUserIds) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('user').doc(userId).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        userDataList.add(userData);
      }
    }
    return userDataList;
  }
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // 무한 스크롤 처리를 위한 작업
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 70, // 바의 높이 설정
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: followingUserIds.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      backgroundImage: AssetImage(followingUserProfilePhotos[index % followingUserProfilePhotos.length]),
                      // 회원 프로필 사진 표시 (memberPhotos[index] 사용)
                    ),
                    SizedBox(height: 10),
                    Text(
                      followingUserIds[index % followingUserIds.length], // 회원 아이디 표시 (followingUserIds[index] 사용)
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            separatorBuilder: (context, index) => SizedBox(height: 10),
            controller: _scrollController,
            itemCount: 5, // 무한 스크롤을 위해 충분한 아이템 개수로 설정해주세요.
            itemBuilder: (context, index) {
              // 여기에 DB에서 받아온 피드 데이터를 표시하는 코드를 추가하면 됩니다.
              return FeedMain(feedImageUrl: '', height: 170, memberId: 'test', profilePhotoUrl: '', weight: 60,); // 임시로 피드 아이템 생성하는 함수 호출
            },
          ),
        ),
      ],
    );
  }
}
