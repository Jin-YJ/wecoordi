import 'package:flutter/material.dart';

import 'feed_detail.dart';

class FeedMain extends StatelessWidget {
  final String profilePhotoUrl;
  final String memberId;
  final double height;
  final double weight;
  final String feedImageUrl;

  FeedMain({
    Key? key,
    required this.profilePhotoUrl,
    required this.memberId,
    required this.height,
    required this.weight,
    required this.feedImageUrl,
  }) : super(key: key);

  // FeedMain 클래스 안에 추가
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
                backgroundImage: NetworkImage(profilePhotoUrl),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeedDetail(
                          profilePhotoUrl: profilePhotoUrl,
                          memberId: memberId,
                          height: height,
                          weight: weight,
                          ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memberId,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '키: ${height}cm, 몸무게: ${weight}kg',
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(feedImageUrl),
                fit: BoxFit.cover,
              ),
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
            "2 likes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text("카페에서.."),
          SizedBox(height: 4),
          Text(
            "FEBURARY 6",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}