import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../app_bar/wecoordiappbar.dart';
import '../bottom_bar/bottom_bar.dart';
import '../wecoordi_provider/wecoordi_provider.dart';
import 'my_page_home_login.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _bottomNavIndex(BuildContext context) {
    return Provider.of<WecoordiProvider>(context).bottomNavIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    print(index);
    Provider.of<WecoordiProvider>(context, listen: false).bottomNavIndex = index;
  }

  // 구글 로그인 기능 추가
  Future<UserCredential?> signInWithGoogle() async {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          print('User is currently signed out!');
        } else {
          print('User is signed in!');
        }
      });
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      // 에러 처리
      print("Google 로그인 에러: $error");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: wecoordiAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButton(
              Buttons.Google,
              onPressed: () async {
                // 구글 로그인 버튼을 누를 때 signInWithGoogle() 함수 호출
                UserCredential? userCredential = await signInWithGoogle();
                if (userCredential != null) {
                  print(userCredential);
                  // userCredential.additionalUserInfo.profile
                  /*
                    "email" -> "youngjoon3202@gmail.com"
                    "name" -> "yjyj (yjyj)"
                    "given_name" -> "yjyj" */
                  // 로그인 성공한 경우
                  // 내 정보_로그인 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyPageHomeLogin()),
                  );
                } else {
                  // 로그인 실패한 경우 처리할 로직 추가
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        bottomNavIndex: _bottomNavIndex,
        onItemTapped: (index) => _onItemTapped(context, index),
        context: context,
      ),
    );
  }
}
