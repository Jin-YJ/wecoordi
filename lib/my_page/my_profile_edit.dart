import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  final String uid;

  ProfileEditPage({required this.uid});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // 프로필 사진 URL 변수를 선언하고 기본 이미지 URL을 할당합니다.
  String profileImageUrl = '카카오_빈_프로필_이미지_URL';

  // 선택된 키와 몸무게의 초기값을 설정합니다.
  double selectedHeight = 170.0;
  double selectedWeight = 60.0;

  // 입력받을 닉네임과 자기소개의 초기값을 설정합니다.
  String nickname = '';
  String introduction = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // 프로필 사진 보여주기 (동그랗게 자르기)
            GestureDetector(
              onTap: () {
                // 이미지를 눌렀을 때 동작할 로직 추가
                // 예를 들면 이미지 선택 라이브러리를 사용하여 새로운 이미지를 선택하는 기능을 구현합니다.
                // 이미지를 선택하고 새로운 프로필 사진 URL로 업데이트합니다.
                // 여기에서는 간단히 새로운 URL을 '새로운_프로필_이미지_URL'로 설정하도록 하겠습니다.
                setState(() {
                  profileImageUrl = '새로운_프로필_이미지_URL';
                });
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
            ),
            SizedBox(height: 20),
            // 닉네임 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                initialValue: nickname,
                onChanged: (value) {
                  // 닉네임이 변경되었을 때 동작할 로직 추가
                  setState(() {
                    nickname = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: '닉네임',
                ),
              ),
            ),

            // 자기소개 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                initialValue: introduction,
                onChanged: (value) {
                  // 자기소개가 변경되었을 때 동작할 로직 추가
                  setState(() {
                    introduction = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: '자기소개',
                ),
              ),
            ),

            SizedBox(height: 20),
            // 키 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                initialValue: selectedHeight.toString(),
                onChanged: (value) {
                  // 키가 변경되었을 때 동작할 로직 추가
                  setState(() {
                    selectedHeight = double.parse(value);
                  });
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '키',
                  suffix: Text('cm'),
                ),
              ),
            ),

            SizedBox(height: 20),
            // 몸무게 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                initialValue: selectedWeight.toString(),
                onChanged: (value) {
                  // 몸무게가 변경되었을 때 동작할 로직 추가
                  setState(() {
                    selectedWeight = double.parse(value);
                  });
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '몸무게',
                  suffix: Text('kg'),
                ),
              ),
            ),

            SizedBox(height: 20),
            // 저장 버튼
            ElevatedButton(
              onPressed: () {
                // 변경된 프로필 정보를 저장하는 로직 추가
              },
              child: Text('저장'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
