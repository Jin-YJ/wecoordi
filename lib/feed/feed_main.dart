import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'feed_detail.dart';

class FeedMain extends StatefulWidget {
  final List<dynamic> feedImageUrl;
  final String userId;
  final List<dynamic> likes;
  final String content;
  final Timestamp createdDate;

  FeedMain({
    Key? key,
    required this.feedImageUrl,
    required this.userId,
    required this.likes,
    required this.content,
    required this.createdDate,
  }) : super(key: key);

  @override
  State<FeedMain> createState() => _FeedMainState();
}

class _FeedMainState extends State<FeedMain> {
  int _currentIndex = 0;
  Map<String, dynamic> userData = Map();

  @override
  void initState() {
    getUserData();

    super.initState();
  }

  void getUserData() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: widget.userId)
        .get();
    if (userSnapshot.size > 0) {
      userData = userSnapshot.docs[0].data() as Map<String, dynamic>;
      setState(() {}); // userData를 가져왔으므로 화면을 업데이트합니다.
    }
  }

  ImageProvider<Object>? _getImageProvider() {
    try {
      if (userData['profileImage'].startsWith('http')) {
        return NetworkImage(userData['profileImage']);
      } else {
        return AssetImage('assets/images/blank_profile.png');
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  String formatTimeAgo(Timestamp timestamp) {
    final utcNow = DateTime.now().toUtc(); // 현재 UTC 시간
    final kstNow = utcNow.add(Duration(hours: 9)); // UTC+9 (한국 시간)
    final dateTime = timestamp.toDate().add(Duration(hours: 9));
    final difference = kstNow.difference(dateTime);

    if (difference.inSeconds < 60) {
      return "방금 전";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}분 전";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}시간 전";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}일 전";
    } else {
      return dateTime.toLocal().toString();
    }
  }

  void _shareFeed(BuildContext context) {
    // TODO: 공유 기능 실행 로직 작성
    // 여기서는 단순히 예시로 'Share Feed'라는 메시지를 출력하는 로직을 추가합니다.
    // 실제로는 여기에 공유할 내용을 설정하고, 앱에서 지원하는 공유 기능을 활용하면 됩니다.
    // Share.share('Share Feed');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: _getImageProvider(),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeedDetail(
                          profilePhotoUrl: userData['profileImage'] != null
                              ? userData['profileImage']
                              : 'assets/images/default_profile.png',
                          memberId: userData['nickName'] ?? '',
                          height: userData['userHeight'] ?? 0,
                          weight: userData['userWeight'] ?? 0,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData['nickName'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '키: ${userData['userHeight'] ?? 0}cm, 몸무게: ${userData['userWeight'] ?? 0}kg',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 80,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.flag),
                              title: Text('신고하기'),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Icon(Icons.more_vert),
              ),
            ],
          ),
          Container(
            height: 400,
            width: double.infinity,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: widget.feedImageUrl.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.feedImageUrl[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.feedImageUrl.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? Colors.black
                              : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.chat_bubble_outline),
                onPressed: () {},
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  _shareFeed(context);
                },
              ),
            ],
          ),
          Text(
            "${widget.likes.length.toString()} Likes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(widget.content),
          SizedBox(height: 4),
          Text(
            formatTimeAgo(widget.createdDate),
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
