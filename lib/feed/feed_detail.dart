import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        });
      }

      QuerySnapshot userInfo = await FirebaseFirestore.instance
          .collection('user')
          .where('userId', isEqualTo: userId)
          .get();
      // if (!userInfo.isNull) {
      //   setState(() {
      //     uid = widget.doc!.id;
      //     nickName = userInfo.docs.['nickName'];
      //     profileImage = userInfo.docs.('profileImage');
      //     introduction = userInfo.docs.('introMsg');
      //     userId = userInfo.docs.('email');
      //   });
      // }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed 상세 정보'),
      ),
      body: SingleChildScrollView(
        // 스크롤 가능한 뷰를 만들기 위해 SingleChildScrollView를 사용합니다.
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feed 정보를 표시하는 부분
              // (여기에 UI를 추가해주세요)
              // 예시:

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
    );
  }
}
