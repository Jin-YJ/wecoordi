import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class wecoordiAppbar extends StatelessWidget implements PreferredSizeWidget {
  const wecoordiAppbar({
    super.key,
  });

// preferredSize 설정
  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
          icon: Icon(CupertinoIcons.person),
          onPressed: () {},
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
