import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: wecoordiHome(),
    );
  }
}


class wecoordiHome extends StatelessWidget {
  const wecoordiHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(
          icon: Icon(CupertinoIcons.add, color: Colors.black),
          onPressed: () {},
          
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.paperplane, color: Colors.black),
            onPressed: () {},
          )],
          backgroundColor: Colors.white,
         title: Text(
    'wecoordi',
    style: TextStyle(
      fontFamily: 'assets/fonts/logo_font.ttf', // 폰트 파일의 경로를 지정
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black, 
    ),
  ),
      )
    ); 
  }
} 