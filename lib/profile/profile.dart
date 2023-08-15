import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wecoordi/feed/feed_upload.dart';
import 'package:wecoordi/my_page/my_page_home_logout.dart';
import 'package:wecoordi/my_page/my_profile_edit.dart';

class ProfilePage extends StatefulWidget {

  final String userId; // doc 코드를 저장할 변수

  ProfilePage({
    required this.userId,
  });
  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? nickName = '';
  List<String?> feedPhotos = [];
  String uid = '';
  String profileImage = '';
  String introduction = '';
  late DocumentSnapshot userInfo;
  @override
  void initState() {
    super.initState();
    fetchUserDataAndFeeds();
  }

  Future<void> fetchUserDataAndFeeds() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        userInfo = await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.uid)
            .get();
        if (userInfo.exists) {
          setState(() {
            uid = currentUser.uid;
            nickName = userInfo.get('nickName');
            profileImage = userInfo.get('profileImage');
            introduction = userInfo.get('introMsg');
          });
        }

        QuerySnapshot userFeeds = await FirebaseFirestore.instance
            .collection('feeds')
            .where('userId', isEqualTo: currentUser.email)
            .where('openYn', isEqualTo: 'Y')
            .get();

        if (userFeeds.docs.isNotEmpty) {
          List<String?> allImageUrls = [];
          for (var doc in userFeeds.docs) {
            List<dynamic> imageUrls = doc.get('imageUrls') as List<dynamic>;
            // allImageUrls.addAll(imageUrls.map((url) => url as String?));
            allImageUrls.add(imageUrls[0]);
          }
          setState(() {
            feedPhotos = allImageUrls;
          });
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyProfilePageLogout()),
        );
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            Center(child: Text('내 정보', style: TextStyle(color: Colors.black))),
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
      body: SingleChildScrollView(
        // 스크롤 가능한 뷰를 만들기 위해 SingleChildScrollView를 사용합니다.
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 사진과 닉네임
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: profileImage != ''
                        ? NetworkImage(profileImage)
                        : AssetImage('assets/images/blank_profile.png')
                            as ImageProvider, // 프로필 이미지 URL
                  ),
                  SizedBox(width: 10),
                  Text(
                    nickName ?? '',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // 자기소개글
              SizedBox(
                height: 60,
                child: Text(
                  introduction,
                  style: TextStyle(fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 20),
              // 팔로우, 팔로워, 알림
              Row(
                children: [
                  Expanded(child: Text('팔로워', textAlign: TextAlign.center)),
                  Expanded(child: Text('팔로우', textAlign: TextAlign.center)),
                  Expanded(child: Text('알림', textAlign: TextAlign.center)),
                ],
              ),
              SizedBox(height: 10),
              Row(children: [
                Expanded(child: Text('1000', textAlign: TextAlign.center)),
                Expanded(child: Text('500', textAlign: TextAlign.center)),
                Expanded(child: Text('3', textAlign: TextAlign.center)),
              ]),
              SizedBox(height: 10),
              // 프로필 수정 버튼
              SizedBox(
                height: screenHeight * 0.04,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // 프로필 수정 버튼을 눌렀을 때 동작할 로직 추가
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfileEditPage()), // 프로필 수정 페이지로 이동
                    );

                    if (result != null && result == true) {
                      // 프로필 수정 화면에서 변경이 있었음을 알리는 값을 받았을 경우 상태 갱신
                      setState(() {
                        fetchUserDataAndFeeds();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white.withOpacity(0.9),
                  ),
                  child: Text('프로필 수정', style: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(height: 20),
              // 바둑판 모양으로 사진 띄우기
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: feedPhotos.length,
                itemBuilder: (context, index) {
                  final imageUrl = feedPhotos[index];
                  if (imageUrl == null) {
                    return Container();
                  }
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 플로팅 버튼을 눌렀을 때 동작할 로직 추가
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FeedUploadPage()),
          );

          if (result != null && result == true) {
            // 프로필 수정 화면에서 변경이 있었음을 알리는 값을 받았을 경우 상태 갱신
            setState(() {
              fetchUserDataAndFeeds();
            });
          }
        },
        mini: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
