import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wecoordi/my_page/my_profile.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 프로필 사진 URL 변수를 선언하고 기본 이미지 URL을 할당합니다.
  String profileImage = '';
  // 선택된 키와 몸무게의 초기값을 설정합니다.
  double userHeight = 0.0;
  double userWeight = 0.0;

  // 입력받을 닉네임과 자기소개의 초기값을 설정합니다.
  String nickName = '';
  String introduction = '';

  //user 컬렉션 doc
  String uid = '';

  //유저정보
  late DocumentSnapshot userInfo;

  late ImagePicker _imagePicker;
  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker(); // _imagePicker 초기화

    fetchUserDataAndFeeds();
  }

  //유저 데이터 가져오기.
  Future<void> fetchUserDataAndFeeds() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        userInfo = await FirebaseFirestore.instance.collection('user').doc(currentUser.uid).get();
        if (userInfo.exists) {
          setState(() {
            uid = currentUser.uid;
            nickName = userInfo.get('nickName');
            profileImage = userInfo.get('profileImage');
            userHeight = userInfo.get('userHeight');
            userWeight = userInfo.get('userWeight');
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }
  //유저데이터 업데이트

  Future<void> updateProfile(
    String profileImage,
    String nickName,
    String introduction,
    double userHeight,
    double userWeight,
  ) async {
    User? user = _auth.currentUser;
    String downloadURL = '';
    if (user != null) {
      Reference storageReference = FirebaseStorage.instance.ref().child('profileImages/${user.email}/${DateTime.now().millisecondsSinceEpoch}');
      try {
        if (profileImage.startsWith('http')) {
          downloadURL = profileImage;
        } else if (profileImage.isNotEmpty) {
          File imageFile = File(profileImage);
          await storageReference.putFile(imageFile);
          downloadURL = await storageReference.getDownloadURL();
        }
      } catch (e) {
        print("프로필 사진 업로드 오류: $e");
      }

      if (nickName == '') {
        nickName = this.nickName;
      }
      try {
        await FirebaseFirestore.instance.collection('user').doc(user.uid).update({
          'profileImage': downloadURL,
          'introMsg': introduction,
          'nickName': nickName,
          'userHeight': userHeight,
          'userWeight': userWeight,
        });

        // 피드 저장 성공 시 토스트 메시지를 띄움
        BotToast.showText(text: "프로필이 수정되었습니다.");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyProfilePage()),
        );
      } catch (error) {
        print("프로필 업데이트 중 오류가 발생했습니다: $error");
      }
    }
  }

  // 갤러리에서 이미지 선택
  // 갤러리에서 이미지 선택
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          profileImage = pickedFile.path;
        });
      }
    } catch (e) {
      print("데이터 가져오기 오류: $e");
    }
  }

  ImageProvider<Object>? _getImageProvider() {
    if (profileImage.startsWith('http')) {
      return NetworkImage(profileImage);
    } else if (profileImage.isNotEmpty) {
      return FileImage(File(profileImage));
    } else {
      return AssetImage('assets/images/blank_profile.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '프로필 수정',
        ),
        actions: [
          // 앱바 우측에 배치할 위젯들을 배열로 추가합니다.
          TextButton(
            onPressed: () {
              updateProfile(profileImage, nickName, introduction, userHeight, userWeight);
            },
            child: Text(
              '완료',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // 프로필 사진 보여주기 (동그랗게 자르기)
            GestureDetector(
              onTap: () => _pickImageFromGallery(),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: _getImageProvider(),
              ),
            ),
            SizedBox(height: 20),
            // 닉네임 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                initialValue: nickName,
                onChanged: (value) {
                  // 닉네임이 변경되었을 때 동작할 로직 추가
                  setState(() {
                    nickName = value;
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
                initialValue: userHeight.toString(),
                onChanged: (value) {
                  // 입력값이 숫자인지 확인
                  double? parsedValue = double.tryParse(value);
                  if (parsedValue != null) {
                    // 키가 변경되었을 때 동작할 로직 추가
                    setState(() {
                      userHeight = double.parse(value);
                    });
                  }
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
                initialValue: userWeight.toString(),
                onChanged: (value) {
                  // 입력값이 숫자인지 확인
                  double? parsedValue = double.tryParse(value);
                  if (parsedValue != null) {
                    // 숫자인 경우에만 몸무게 변경
                    setState(() {
                      userWeight = parsedValue;
                    });
                  } else {
                    // 숫자가 아닌 경우 또는 빈 문자열인 경우 이전 값으로 유지
                  }
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '몸무게',
                  suffix: Text('kg'),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
