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
  QuerySnapshot? feedSnapshot;

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
          followingUserIds = followingData
              .map((doc) =>
                  (doc.data() as Map<String, dynamic>)['userId'] as String? ??
                  '')
              .toList();
        });
      }
      //followingUserIds의 length가 0이면 전체조회, 그렇지 않으면 전체조회 시간대로
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> fetchDataAndDisplayData() async {
    List<Map<String, dynamic>> userDataList = await getUserData();
    List<String> profilePhotos = [
      'assets/images/all_profiles.png'
    ]; // 프로필 사진 리스트 초기화
    List<String> nicknames = ['전체']; // 회원 아이디 리스트 초기화

    for (Map<String, dynamic> userData in userDataList) {
      profilePhotos.add(userData['profileImage']);
      nicknames.add(userData['nickName']);
    }

    setState(() {
      followingUserProfilePhotos = profilePhotos; // 프로필 사진 리스트 업데이트
      followingUserNickName = nicknames; // 회원 아이디 리스트 업데이트
    });

    if (userDataList.length > 0) {
      // userDataList의 길이가 0보다 크면 userId 조건을 적용하여 createdAt 기준으로 최신순으로 피드 조회
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('feeds')
          .where('userId',
              whereIn:
                  userDataList.map((userData) => userData['userId']).toList())
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        feedSnapshot = snapshot; // 여기서 feedSnapshot을 초기화해줍니다.
      });
    } else {
      // userDataList의 길이가 0이면 userId 조건 없이 createdAt 기준으로 최신순으로 피드 조회
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('feeds')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        feedSnapshot = snapshot; // 여기서 feedSnapshot을 초기화해줍니다.
      });
    }
  }

  // user 컬렉션에서 해당 유저들의 데이터를 가져오는 함수
  Future<List<Map<String, dynamic>>> getUserData() async {
    List<Map<String, dynamic>> userDataList = [];
    for (String userId in followingUserIds) {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        userDataList.add(userData);
      }
    }
    return userDataList;
  }

  ImageProvider<Object>? _getImageProvider(int index) {
    try {
      if (followingUserProfilePhotos[index].startsWith('http')) {
        return NetworkImage(followingUserProfilePhotos[index]);
      } else {
        return AssetImage('assets/images/all_profiles.png');
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
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
                      backgroundImage: _getImageProvider(index),
                      // 회원 프로필 사진 표시 (memberPhotos[index] 사용)
                    ),
                    SizedBox(height: 10),
                    Text(
                      followingUserNickName[
                          index], // 회원 아이디 표시 (followingUserIds[index] 사용)
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
            itemCount:
                feedSnapshot?.size ?? 0, // 무한 스크롤을 위해 충분한 아이템 개수로 설정해주세요.
            itemBuilder: (context, index) {
              if (feedSnapshot == null) {
                return Container(); // feedSnapshot이 null인 경우 빈 컨테이너 반환
              } else {
                return FeedMain(
                    feedImageUrl: feedSnapshot?.docs[index]['imageUrls'],
                    userId: feedSnapshot?.docs[index]['userId'],
                    likes: feedSnapshot?.docs[index]['likes'],
                    content: feedSnapshot?.docs[index]['content'],
                    createdDate: feedSnapshot?.docs[index]['createdAt']);
              }
            },
          ),
        ),
      ],
    );
  }
}
