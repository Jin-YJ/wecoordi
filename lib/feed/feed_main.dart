import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../profile/profile.dart';

class FeedMain extends StatefulWidget {
  final String userId;
  final DocumentSnapshot? doc; // doc 코드를 저장할 변수

  FeedMain({
    Key? key,
    required this.userId,
    required this.doc,
  }) : super(key: key);

  @override
  State<FeedMain> createState() => _FeedMainState();
}

class _FeedMainState extends State<FeedMain> {
  int _currentIndex = 0;
  Map<String, dynamic> userData = Map();
  //해당 피드의 좋아요 여부.
  bool likeState = false;
  List<dynamic> likes = [];
  String content = '';
  Timestamp createdDate = Timestamp(0, 0);
  List<dynamic> feedImageUrl = [];
  List<dynamic> reply = [];

  // TextEditingController를 생성합니다.
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    getFeedData();
    getUserData();

    super.initState();
  }

  void getFeedData() {
    FirebaseFirestore.instance
        .collection('feeds')
        .doc(widget.doc?.id) // 가져올 문서의 doc 코드를 전달
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // 문서가 존재하는 경우
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          likes = data['likes'];
          content = data['content'];
          createdDate = data['createdAt'];
          feedImageUrl = data['imageUrls'];
          reply = data['reply'];
        });
        // 필드 데이터를 가져옵니다.
        // 예: String content = data['content'];
        // 예: List<dynamic> feedImageUrl = data['feedImageUrl'];
        // ...
        print('Document data: $data');
      } else {
        // 문서가 존재하지 않는 경우
        print('Document does not exist on the database');
      }
    }).catchError((error) {
      // 에러 처리
      print('Error getting document: $error');
    });
  }

  void getUserData() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: widget.userId)
        .get();
    if (userSnapshot.size > 0) {
      userData = userSnapshot.docs[0].data() as Map<String, dynamic>;
      setState(() {
        for (int i = 0; i < likes.length; i++) {
          if (likes[i] == userData['email']) {
            // 좋아요 배열에 유저의 아이디가 있으면 likeState를 바꾼다.
            likeState = true;
          } else {
            likeState = false;
          }
        }
      }); // userData를 가져왔으므로 화면을 업데이트합니다.
    }
  }

  void heartClick() {
    if (likeState) {
      // 검색한 문서와 currentUserId를 사용하여 해당 유저의 유저 아이디를 likes 배열에서 삭제합니다.
      FirebaseFirestore.instance
          .collection('feeds')
          .doc(widget.doc?.id) // 검색한 문서의 아이디를 사용합니다.
          .update({
        'likes': FieldValue.arrayRemove([userData['email']]),
      }).catchError((error) {
        print('좋아요 삭제 오류: $error');
      });
    } else {
      // 검색한 문서와 currentUserId를 사용하여 해당 유저의 유저 아이디를 likes 배열에서 삭제합니다.
      FirebaseFirestore.instance
          .collection('feeds')
          .doc(widget.doc?.id) // 검색한 문서의 아이디를 사용합니다.
          .update({
        'likes': FieldValue.arrayUnion([userData['email']]),
      }).catchError((error) {
        print('좋아요 삭제 오류: $error');
      });
    }
    setState(() {
      likeState = !likeState;
      if (likeState) {
        likes.add(userData['email']); // 좋아요가 추가된 경우 현재 사용자의 아이디를 likes 배열에 추가
      } else {
        likes.remove(
            userData['email']); // 좋아요가 삭제된 경우 현재 사용자의 아이디를 likes 배열에서 제거
      }
    });
  }

  //댓글을 저장
  Map<String, dynamic> saveReply(String replyText) {
    DocumentReference feedRef =
        FirebaseFirestore.instance.collection('feeds').doc(widget.doc?.id);

    // reply 배열에 추가할 데이터를 생성합니다.
    Map<String, dynamic> replyData = {
      'userId': userData['email'],
      'replyText': replyText,
      'createdDate': Timestamp.now(),
    };

    feedRef.update({
      'reply': FieldValue.arrayUnion([replyData])
    });
    // 댓글 등록 후 텍스트필드 초기화
    _replyController.clear();
    return replyData;
  }

  ImageProvider<Object>? _getImageProvider() {
    try {
      if (userData['profileImage'].startsWith('http')) {
        return NetworkImage(userData['profileImage']);
      } else {
        return AssetImage('assets/images/blank_profile.png');
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  String formatTimeAgo(Timestamp timestamp) {
    final utcNow = DateTime.now().toUtc(); // 현재 UTC 시간
    final kstNow = utcNow.add(Duration(hours: 9)); // UTC+9 (한국 시간)
    final dateTime = timestamp.toDate().add(Duration(hours: 9));
    final difference = kstNow.difference(dateTime);

    if (difference.inSeconds < 60) {
      return "방금 전";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}분 전";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}시간 전";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}일 전";
    } else {
      return dateTime.toLocal().toString();
    }
  }

  void _shareFeed(BuildContext context) {
    // 공유할 피드 정보를 설정합니다.
    // String feedContent = "${userData['nickName']} 님의 피드: ${widget.content}";
    // String feedLink =
    //     "https://example.com/feed/${widget.doc?.id}"; // 피드에 대한 고유한 링크 설정

    // String shareContent = "$feedContent\n\n$feedLink"; // 공유할 내용에 피드 내용과 링크 추가

    // // 공유 기능을 실행합니다.
    // Share.share(shareContent);
  }
  Future<String> getReplyProfileImage(String? commenter) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: commenter)
        .get();

    return userSnapshot.docs[0]['profileImage'];
  }

  //댓글 닉네임 가져오는 부분
  Future<Map<String, String>> getNickNamesForEmails(List emails) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final int batchSize = 10; // Firestore의 제한값
    final Map<String, String> nickNames = {};

    emails.removeWhere((email) => email == null);

    for (int i = 0; i < emails.length; i += batchSize) {
      final endRange =
          (i + batchSize > emails.length) ? emails.length : i + batchSize;
      final currentBatch = emails.sublist(i, endRange);

      QuerySnapshot usersSnapshot = await firestore
          .collection('user')
          .where('email', whereIn: currentBatch)
          .get();

      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        nickNames[data['email'] ?? ""] = data['nickName'] ?? doc.id;
      }
    }

    return nickNames;
  }

  Future<void> _showReplyModal(Map<String, String> nicknames) async {
    // 댓글이 없을 경우 빈 댓글 목록을 생성합니다.
    if (reply.isEmpty ||
        reply[0]['replyText'] == null ||
        reply[0]['replyText'] == '') {
      reply = [];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(// 여기서 StatefulBuilder를 추가합니다.
            builder: (BuildContext context, StateSetter setStateModal) {
          // StateSetter를 사용하여 상태를 설정합니다.
          return DraggableScrollableSheet(
            initialChildSize: 0.95,
            minChildSize: 0.2,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            // 댓글 목록을 추가합니다.
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: reply.length,
                              itemBuilder: (context, index) {
                                String comment = reply[index]['replyText'];
                                String userEmail = reply[index]['userId'];
                                String? commenter = nicknames[userEmail];

                                return FutureBuilder<String>(
                                  future: getReplyProfileImage(userEmail),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // 프로필 이미지 가져오는 중
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: AssetImage(
                                              'assets/images/all_profiles.png'),
                                        ),
                                        title: Text(commenter!),
                                        subtitle: Text(comment),
                                      );
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      // 에러 처리 또는 데이터가 없는 경우
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: AssetImage(
                                              'assets/images/all_profiles.png'),
                                        ),
                                        title: Text(commenter!),
                                        subtitle: Text(comment),
                                      );
                                    } else {
                                      // 프로필 이미지 가져오기 성공
                                      String profileImageUrl = snapshot.data!;
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(profileImageUrl),
                                        ),
                                        title: Text(commenter!),
                                        subtitle: Text(comment),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                            // 댓글 입력 폼을 추가합니다.
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _replyController,
                                      decoration: InputDecoration(
                                        hintText: '댓글을 입력하세요...',
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                      // 댓글을 입력받는 로직을 추가합니다.
                                      // onSaved 등의 적절한 핸들러를 사용하여 댓글을 저장하거나 처리합니다.
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    print(_replyController.text);
                                    // ignore: unnecessary_null_comparison
                                    if (_replyController.text == null ||
                                        _replyController.text.trim() == '') {
                                      // `ScaffoldMessenger`를 사용하여 `SnackBar` 표시
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('댓글을 입력하세요.'),
                                        ),
                                      );
                                    } else {
                                      Map<String, dynamic>? savedReply =
                                          await saveReply(
                                              _replyController.text);

                                      if (savedReply != null) {
                                        setStateModal(() {
                                          reply.add(savedReply);
                                        });
                                      } else {
                                        // 에러 처리 로직 (예: 사용자에게 알림 표시)
                                      }
                                    }
                                  },
                                  child: Text('입력'),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: _getImageProvider(),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          userId: userData['email'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData['nickName'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '키: ${userData['userHeight'] ?? 0}cm, 몸무게: ${userData['userWeight'] ?? 0}kg',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 80,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.flag),
                              title: Text('신고하기'),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Icon(Icons.more_vert),
              ),
            ],
          ),
          Container(
            height: 400,
            width: double.infinity,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: feedImageUrl.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(feedImageUrl[index]),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      feedImageUrl.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? Colors.black
                              : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(likeState ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  heartClick();
                },
              ),
              IconButton(
                icon: Icon(Icons.chat_bubble_outline),
                onPressed: () async {
                  // 댓글의 모든 작성자 이메일을 가져옵니다.
                  List userEmails = reply.map((r) => r['userId']).toList();

                  // 이메일로 닉네임을 가져옵니다.
                  Map<String, String> nicknames =
                      await getNickNamesForEmails(userEmails);

                  // 댓글 모달을 호출하고, 닉네임 정보를 전달합니다.
                  _showReplyModal(nicknames);
                },
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  _shareFeed(context);
                },
              ),
            ],
          ),
          Text(
            "${likes.length.toString()} Likes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(content),
          SizedBox(height: 4),
          Text(
            formatTimeAgo(createdDate),
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
