import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wecoordi/bottom_bar/bottom_bar.dart';
import 'package:wecoordi/my_page/my_profile_edit.dart';
import 'package:wecoordi/wecoordi_provider/wecoordi_provider.dart';

class FeedDetail extends StatefulWidget {
  final DocumentSnapshot? doc; // doc 코드를 저장할 변수

  FeedDetail({
    required this.doc,
  });

  @override
  State<FeedDetail> createState() => _FeedDetailState();
}

class _FeedDetailState extends State<FeedDetail> {
  
  List<dynamic> feedPhotos = [];
  late DocumentSnapshot userFeeds;
  Map<String, dynamic> userData = Map();
  String uid = '';
  String profileImage = '';
  String introduction = '';
  String? nickName = ''; 
  String userId = '';

  @override
  void initState() {
    super.initState();
    fetchUserDataAndFeeds();
  }

  Future<void> fetchUserDataAndFeeds() async {
    try {
      userFeeds = await FirebaseFirestore.instance
          .collection('feeds')
          .doc(widget.doc!.id)
          .get();

      if (userFeeds.exists) {
        List imageUrls = userFeeds.get('imageUrls') as List<dynamic>;

        setState(() {
          feedPhotos = imageUrls;
          userId = userFeeds.get('userId');
        });
      }

      QuerySnapshot userInfo = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: userId)
          .get();
      if (!userInfo.docs.isEmpty) {
        userData = userInfo.docs[0].data() as Map<String, dynamic>;

        setState(() {
          uid = widget.doc!.id;
          nickName = userData['nickName'];
          profileImage = userData['profileImage'];
          introduction = userData['introMsg'];
          userId = userData['email'];
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }
  int _bottomNavIndex(BuildContext context) {
    return Provider.of<WecoordiProvider>(context).bottomNavIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    Provider.of<WecoordiProvider>(context, listen: false).bottomNavIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            Center(child: Text(nickName!, style: TextStyle(color: Colors.black))),
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
      bottomNavigationBar: BottomBar(
        bottomNavIndex: _bottomNavIndex,
        onItemTapped: (index) => _onItemTapped(context, index),
        context: context,
      ),
    );
  }
}
