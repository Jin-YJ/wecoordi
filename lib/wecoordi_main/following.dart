import 'package:flutter/material.dart';

class Following extends StatefulWidget {
  const Following({
    super.key,
  });

  static const memberIds = ['test1', 'test2', 'test3'];
  static const memberPhotos = ['', '', ''];

  @override
  State<Following> createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Text(
                    //이미지 이미지
                    '전체',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  //아이디
                  '전체',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: Following.memberIds.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      // 회원 프로필 사진 표시 (memberPhotos[index] 사용)
                    ),
                    SizedBox(height: 10),
                    Text(
                      Following.memberIds[index], // 회원 아이디 표시 (memberIds[index] 사용)
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
