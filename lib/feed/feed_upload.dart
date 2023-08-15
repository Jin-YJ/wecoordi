import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../my_page/my_page_home_logout.dart';

class FeedUploadPage extends StatefulWidget {
  @override
  _FeedUploadPageState createState() => _FeedUploadPageState();
}

class _FeedUploadPageState extends State<FeedUploadPage> {
  late ImagePicker _imagePicker;
  List<ImageProvider> _selectedImages = [];
  ImageCropper _imageCropper = ImageCropper(); // ImageCropper 인스턴스 생성
  ImageProvider _emptyImage = AssetImage('assets/images/empty_image.png');
  // 성별, 스타일, 나이, TPO를 저장하는 변수들
  String _selectedGender = '남성';
  String _selectedStyle = '미니멀';
  String _selectedAge = '10대';
  String _selectedTPO = '결혼식';
  final FocusNode _focusNode = FocusNode();

  TextEditingController _feedController =
      TextEditingController(); // 피드 내용을 입력받기 위한 컨트롤러

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _selectedImages = []; // _selectedImages 리스트 초기화
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // 포커스가 없을 때 키보드를 숨깁니다.
        FocusScope.of(context).unfocus();
      }
    });
  }

  // 갤러리에서 이미지 선택
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    CroppedFile? croppedFile;
    if (pickedFile != null) {
      try {
        croppedFile = await _imageCropper.cropImage(
            sourcePath: pickedFile.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxWidth: 150,
            maxHeight: 150,
            uiSettings: [
              AndroidUiSettings(
                  toolbarTitle: '사진 자르기',
                  toolbarColor: Colors.black,
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.original,
                  lockAspectRatio: false),
              IOSUiSettings(
                title: '사진 자르기',
              )
            ]);
      } catch (error) {
        // 에러 처리
        print("사진자르기 : $error");
        return null;
      }

      setState(() {
        if (croppedFile != null) {
          if (_selectedImages.length < 10) {
            _selectedImages.add(FileImage(File(croppedFile.path)));
          }
        }
      });
    }
  }

  // 이미지 삭제
  void _deleteImage(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('이미지 삭제'),
          content: Text('선택한 이미지를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedImages.removeAt(index);
                  Navigator.pop(context); // 다이얼로그 닫기
                });
              },
              child: Text('확인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  // 여러 이미지를 Firebase Storage에 업로드하는 함수
  Future<List<String>> _uploadImagesToFirebaseStorage(
      List<ImageProvider> imageProviders) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      List<File> imageFiles = _getImageFilesFromProviders(imageProviders);
      List<String> imageUrls = [];
      for (File imageFile in imageFiles) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        String? userId = user.email;
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('feedImages/$userId/$fileName');
        UploadTask uploadTask = storageReference.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadURL);
      }
      return imageUrls;
    } else {
      return [];
    }
  }

  // 이미지 파일 리스트로 변환하는 함수
  List<File> _getImageFilesFromProviders(List<ImageProvider> imageProviders) {
    List<File> imageFiles = [];

    for (var imageProvider in imageProviders) {
      if (imageProvider is FileImage) {
        imageFiles.add(imageProvider.file);
      }
    }

    return imageFiles;
  }

// Firestore에 데이터와 이미지 URL 저장하는 함수
  void _saveDataToFirestore(List<String> imageUrls) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user == null) {
      // 사용자가 로그인되어 있지 않으면 로그인이 필요하다는 확인 메시지를 띄우고 ProfilePage로 이동
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('로그인 필요'),
            content: Text('피드를 저장하기 위해서는 로그인이 필요합니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyProfilePageLogout(
                      )));
                },
                child: Text('로그인'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                },
                child: Text('취소'),
              ),
            ],
          );
        },
      );
      return;
    }

    String gender = _selectedGender;
    String style = _selectedStyle;
    String age = _selectedAge;
    String tpo = _selectedTPO;
    String content = _feedController.text;

    // Firestore에 데이터 추가
    FirebaseFirestore.instance.collection('feeds').add({
      'imageUrls': imageUrls,
      'gender': gender,
      'style': style,
      'age': age,
      'tpo': tpo,
      'content': content,
      'userId': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'openYn': 'Y',
      'likes': [],
      'reply': [Map()],
    }).then((_) {
      // 데이터 저장 성공 시 처리할 내용
      // 예: 저장 성공 알림 띄우기 등

      // 피드 저장 성공 시 토스트 메시지를 띄움
      BotToast.showText(text: "피드가 저장되었습니다.");

      Navigator.pop(
        context,
        true,
      );
    }).catchError((error) {
      // 에러 처리
      print('Firestore 데이터 저장 에러: $error');
    });
  }

  void _saveFeed() async {
    // 여러 이미지 업로드
    if (_selectedImages.isNotEmpty) {
      List<String> imageUrls =
          await _uploadImagesToFirebaseStorage(_selectedImages);

      // Firestore에 데이터와 이미지 URL 저장
      _saveDataToFirestore(imageUrls);
    } else {
      // 이미지가 선택되지 않았을 때의 처리
      // 예: 이미지 선택 요청 알림 띄우기 등
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 다른 곳을 탭했을 때 포커스를 제거하여 키보드를 닫습니다.
        _focusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '피드 등록하기',
          ),
          actions: [
            TextButton(
              onPressed: _saveFeed,
              child: Text(
                '저장',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          // 전체 화면 스크롤을 위해 SingleChildScrollView 사용
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // 왼쪽 정렬을 위해 crossAxisAlignment 설정
            children: [
              SizedBox(height: 5),
              Container(
                height: 300,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < _selectedImages.length; i++)
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: GestureDetector(
                            onTap: () => _deleteImage(i),
                            child: Image(
                              image: _selectedImages[i],
                              width: 150,
                              height: 150,
                            ),
                          ),
                        ),
                      if (_selectedImages.isEmpty ||
                          _selectedImages.length < 10)
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: InkWell(
                            onTap: () => _pickImageFromGallery(),
                            child: Image(
                              image: _emptyImage,
                              width: 150,
                              height: 150,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // 피드 내용 입력란
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFormField(
                  focusNode: _focusNode,
                  controller: _feedController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: '피드 내용을 입력해주세요.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // '성별' 설명과 토글버튼
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('성별',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (String gender in ['남성', '여성'])
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedGender = gender;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: _selectedGender == gender
                                      ? Colors.blue
                                      : Colors.grey,
                                  minimumSize: Size(gender.length * 20.0,
                                      0), // 버튼의 width 값을 글자수에 따라 계산
                                ),
                                child: Text(gender),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // '스타일' 설명과 토글버튼
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('스타일',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (String style in [
                            '미니멀',
                            '아메카지',
                            '스트릿',
                            '남친룩',
                            '여친룩'
                          ])
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedStyle = style;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: _selectedStyle == style
                                      ? Colors.blue
                                      : Colors.grey,
                                  minimumSize: Size(style.length * 20.0,
                                      0), // 버튼의 width 값을 글자수에 따라 계산
                                ),
                                child: Text(style),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // '나이' 설명과 토글버튼
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('나이',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (String age in ['10대', '20대', '30대', '40대'])
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedAge = age;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: _selectedAge == age
                                      ? Colors.blue
                                      : Colors.grey,
                                  minimumSize: Size(age.length * 20.0,
                                      0), // 버튼의 width 값을 글자수에 따라 계산
                                ),
                                child: Text(age),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 'TPO' 설명과 토글버튼
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TPO',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (String tpo in [
                            '결혼식',
                            '소개팅',
                            '데이트',
                            '나들이',
                            '출근룩',
                            '데일리'
                          ])
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedTPO = tpo;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: _selectedTPO == tpo
                                      ? Colors.blue
                                      : Colors.grey,
                                  minimumSize: Size(tpo.length * 20.0,
                                      0), // 버튼의 width 값을 글자수에 따라 계산
                                ),
                                child: Text(tpo),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
