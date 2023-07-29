import 'package:flutter/material.dart';

class feedMain extends StatelessWidget {
  const feedMain({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 400, // 피드 사진의 높이를 고정으로 설정
            width: double.infinity, // 피드 사진의 너비는 화면 너비에 맞게 가변적으로 설정
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/4241.jpg'), // 임시로 이미지 설정, db랑 연동
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10),
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
                icon: Icon(Icons.bookmark_border),
                onPressed: () {},
              )
            ],
          ),
          SizedBox(height: 8),
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
