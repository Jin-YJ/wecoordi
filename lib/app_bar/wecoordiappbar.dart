import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wecoordi/wecoordi_provider/wecoordi_provider.dart';

import '../profile/profile.dart';

class wecoordiAppbar extends StatelessWidget implements PreferredSizeWidget {
  const wecoordiAppbar({
    super.key,
  });

// preferredSize 설정
  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
      String userId = Provider.of<WecoordiProvider>(context).userId; // 프로바이더에서 _userId 가져오기

    return AppBar(
      actions: [
        IconButton(
          icon: Icon(CupertinoIcons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(userId: userId,)), // 프로필 페이지로 이동
            );
          },
        ),
        IconButton(
          icon: Icon(CupertinoIcons.search),
          onPressed: () {},
        )
      ],
      backgroundColor: Colors.white,
      title: Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05), // 5% 패딩
        child: Row(
          children: [
            Text(
              'wecoordi',
              style: GoogleFonts.lobster(textStyle: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
      iconTheme: IconThemeData(color: Colors.black),
    );
  }
}
