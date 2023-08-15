import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController nickNameController = TextEditingController();
  TextEditingController introductionController = TextEditingController();
  TextEditingController userHeightController = TextEditingController();
  TextEditingController userWeightController = TextEditingController();

  // 프로필 사진 URL 변수를 선언하고 기본 이미지 URL을 할당합니다.
  String profileImage = '';

  //user 컬렉션 doc
  String uid = '';

  //유저정보
  late DocumentSnapshot userInfo;

  late ImagePicker _imagePicker;

  //닉네임 중복여부
  bool isNicknameDuplicate = false;

  //닉네임 중복메세지
  String nicknameDuplicateMessage = '';

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
        DocumentSnapshot fetchedUserInfo = await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.uid)
            .get();
        if (fetchedUserInfo.exists) {
          Map<String, dynamic>? data =
              fetchedUserInfo.data() as Map<String, dynamic>?;
          print("가져온 데이터: $data");
          if (data != null) {
            setState(() {
              uid = currentUser.uid;
              nickNameController.text = data['nickName'] ?? '';
              profileImage = data['profileImage'] ?? '';
              userHeightController.text = (data['userHeight'] ?? 0).toString();
              userWeightController.text = (data['userWeight'] ?? 0).toString();
              introductionController.text = data['introMsg'] ?? '';
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  //유저데이터 업데이트

  Future<void> updateProfile(
    String profileImage,
  ) async {
    User? user = _auth.currentUser;
    String downloadURL = '';
    if (user != null) {
      Reference storageReference = FirebaseStorage.instance.ref().child(
          'profileImages/${user.email}/${DateTime.now().millisecondsSinceEpoch}');
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

      if (isNicknameDuplicate) {
        setState(() {
          nicknameDuplicateMessage = '닉네임이 중복되어 프로필을 수정할 수 없습니다.';
        });
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({
          'profileImage': downloadURL,
          'introMsg': introductionController.text,
          'nickName': nickNameController.text,
          'userHeight': userHeightController.text,
          'userWeight': userWeightController.text,
        });

        // 피드 저장 성공 시 토스트 메시지를 띄움
        BotToast.showText(text: "프로필이 수정되었습니다.");

        Navigator.pop(context, true);
      } catch (error) {
        print("프로필 업데이트 중 오류가 발생했습니다: $error");
      }
    }
  }

  // 갤러리에서 이미지 선택
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          profileImage = pickedFile.path;
        });
      }
    } catch (e) {
      print("데이터 가져오기 오류: $e");
    }
  }

  //닉네임체크
  Future<void> checkNickName(nickName) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('nickName', isEqualTo: nickName)
        .get();

    setState(() {
      if (userSnapshot.size > 0) {
        isNicknameDuplicate = true;
        nickNameController = nickName;
      } else {
        isNicknameDuplicate = false;
      }
    });
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
    print("위젯 재구성");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '프로필 수정',
        ),
        actions: [
          // 앱바 우측에 배치할 위젯들을 배열로 추가합니다.
          TextButton(
            onPressed: () {
              updateProfile(profileImage);
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
                controller: nickNameController,
                onChanged: (value) {
                  checkNickName(value);
                  // 닉네임이 변경되었을 때 동작할 로직 추가
                },
                validator: (value) {
                  if (isNicknameDuplicate) {
                    return nicknameDuplicateMessage;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: '닉네임',
                  errorText:
                      isNicknameDuplicate ? nicknameDuplicateMessage : null,
                ),
              ),
            ),

            // 자기소개 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: introductionController,
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
                controller: userHeightController,
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
                controller: userWeightController,
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
