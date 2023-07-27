import 'package:flutter/material.dart';

class Following extends StatefulWidget {
  const Following({
    Key? key,
  }) : super(key: key);

  static const memberIds = ['test1', 'test2', 'test3'];
  // 프로필 사진은 나중에 DB에서 가져오기 때문에 주석으로 설명만 표시합니다.
  static const memberPhotos = ['assets/images/4241.jpg', 'assets/images/4241.jpg', 'assets/images/4241.jpg'];

  @override
  State<Following> createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
            itemCount: Following.memberIds.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      backgroundImage: AssetImage(Following.memberPhotos[index % Following.memberPhotos.length]),
                      // 회원 프로필 사진 표시 (memberPhotos[index] 사용)
                    ),
                    SizedBox(height: 10),
                    Text(
                      Following.memberIds[index % Following.memberIds.length], // 회원 아이디 표시 (memberIds[index] 사용)
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
              return _buildFeedItem(); // 임시로 피드 아이템 생성하는 함수 호출
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 400, // 피드 사진의 높이를 고정으로 설정
            width: double.infinity, // 피드 사진의 너비는 화면 너비에 맞게 가변적으로 설정
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // 피드의 모서리를 둥글게 설정
              image: DecorationImage(
                image: AssetImage('assets/images/4241.jpg'), // 임시로 이미지 설정
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
