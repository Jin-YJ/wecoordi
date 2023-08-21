import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecoordi/wecoordiMain.dart';

import 'wecoordi_provider/wecoordi_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WecoordiProvider()),

        // 다른 프로바이더가 있다면 여기에 추가로 등록합니다.
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      home: wecoordiHome(),
    );
  }
}

class wecoordiHome extends StatefulWidget {
  wecoordiHome({Key? key}) : super(key: key);

  @override
  _wecoordiHomeState createState() => _wecoordiHomeState();
}

class _wecoordiHomeState extends State<wecoordiHome> {
  String? _userId = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // 사용자의 이메일을 가져와 _userId에 저장

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser != null) {
        _userId = _auth.currentUser!.email;
        Provider.of<WecoordiProvider>(context, listen: false).userId = _userId!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WecoordiMain();
  }
}
