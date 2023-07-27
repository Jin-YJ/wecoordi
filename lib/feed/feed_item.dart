import 'package:flutter/material.dart';

class FeedItem extends StatelessWidget {
  final String profilePhotoUrl;
  final String memberId;
  final double height;
  final double weight;
  final String timestamp;

  const FeedItem({
    Key? key,
    required this.profilePhotoUrl,
    required this.memberId,
    required this.height,
    required this.weight,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(profilePhotoUrl),
          ),
          SizedBox(width: 10),
          Expanded(
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
                Text(
                  timestamp,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // 신고하기 버튼 클릭 시 동작
              // 여기에 신고하기 기능을 구현하세요.
            },
          ),
        ],
      ),
    );
  }
}
