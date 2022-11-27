import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kakaotalk_clone/data/kakao_data.dart';
import 'package:kakaotalk_clone/shared/round_square.dart';
import 'package:kakaotalk_clone/shared/simple_chip.dart';

void main() {
  runApp(const KakaoTalk());
}

class KakaoTalk extends StatelessWidget {
  const KakaoTalk({super.key});

  @override
  Widget build(BuildContext context) {
    // the number of unread messages (across all chats)
    int unreadSum =
        data.fold(0, (value, element) => value + element.unreadCount);

    Widget header = Container(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('채팅', textAlign: TextAlign.left,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(Icons.search_outlined, size:30),
              SizedBox(width: 10,),
              Icon(Icons.add_comment_outlined, size:30),
              SizedBox(width: 10,),
              Icon(Icons.forum_outlined, size:30),
              SizedBox(width: 10,),
              Icon(Icons.settings_outlined, size:30),
            ]
          )
        ]),
    );

    Widget body = ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => ChatListElement(chatInfo: data[index]),
    );

    Widget footer = Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[100],
      child: Row(
        //direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.person_outline, size:30),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.chat_bubble, size:30),
              Positioned(
                left: 20,
                child: SimpleChip(content: '$unreadSum')
              )
            ]
          ),
          Icon(Icons.info_outline, size:30),
          Icon(Icons.local_mall_outlined, size:30),
          Icon(Icons.more_horiz, size:30)
        ]
      ),
    );

    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              header,
              const Divider(height: 0.0, thickness: 1),
              Expanded(child: body),
              const Divider(height: 0.0, thickness: 1),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}

class ChatListElement extends StatelessWidget {
  const ChatListElement({super.key, required this.chatInfo});

  final ChatInfo chatInfo;

  // on single image, return RoundSquareImage.
  // on multiple images, return Stack of RoundSquareImage.
  Widget _buildChatImage() {
    switch (chatInfo.images.length) {
      case 1: // 1 person (image size: 50px)
        return RoundSquareImage(size: 50, image: Image.network(chatInfo.images[0]));
      case 2: // 2 people (image size: 50px * 3 / 5)
        return Stack(
          children: [
            Positioned( top: 0, left: 0,
              child: RoundSquareImage(size: 50 * 3 / 5, image: Image.network(chatInfo.images[0]))),
            Positioned( bottom: 0, right: 0,
              child: RoundSquareImage(size: 50 * 3 / 5, image: Image.network(chatInfo.images[1]))),
          ],
        );
      case 3: // 3 people (image size: 50px * 4 / 7)
        return Stack(
          children: [
            Positioned( bottom: 0, left: 0,
              child: RoundSquareImage(size: 50 * 4 / 7, image: Image.network(chatInfo.images[0]))),
            Positioned( bottom: 0, right: 0,
              child: RoundSquareImage(size: 50 * 4 / 7, image: Image.network(chatInfo.images[1]))),
            Positioned( top: 0, left: 10,
              child: RoundSquareImage(size: 50 * 4 / 7, image: Image.network(chatInfo.images[2]))),
          ],
        );
      default: // 4 or more people in the chat (image size: 50px * 1 / 2)
        return Stack(
          children: [
            Positioned( top: 0, left: 0,
              child: RoundSquareImage(size: 50 * 1 / 2, image: Image.network(chatInfo.images[0]))),
            Positioned( bottom: 0, left: 0, 
              child: RoundSquareImage(size: 50 * 1 / 2, image: Image.network(chatInfo.images[1]))),
            Positioned( bottom: 0, right: 0,
              child: RoundSquareImage(size: 50 * 1 / 2, image: Image.network(chatInfo.images[2]))),
            Positioned( top: 0, right: 0,
              child: RoundSquareImage(size: 50 * 1 / 2, image: Image.network(chatInfo.images[3]))),
          ],
        );
    }
  }

  String _lastChatTimeFormatted() {
    DateTime now = DateTime.now();
    // Extract (year, month, day) information from 'now' and 'chatInfo.lastChatTime'.
    // This makes comparing dates easier.
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime dateToCheck = DateTime(chatInfo.lastChatTime.year,
        chatInfo.lastChatTime.month, chatInfo.lastChatTime.day);

    // Return formatted strings
    if (dateToCheck == today) {
      // today
      return DateFormat('kk:mm').format(DateTime(
        chatInfo.lastChatTime.hour, chatInfo.lastChatTime.minute
      ));
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      // yesterday
      return '어제';
    } else if (dateToCheck.year == today.year) {
      // day before yesterday & this year
      return DateFormat('MM월 dd일').format(DateTime(
        chatInfo.lastChatTime.hour, chatInfo.lastChatTime.minute
      ));
    } else {
      // last year & before
      return DateFormat('yyyy.MM.dd').format(DateTime(
        chatInfo.lastChatTime.year, chatInfo.lastChatTime.hour, chatInfo.lastChatTime.minute
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget titleAndLastChat = Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          Flexible(
            child: Text(
              chatInfo.chatName, 
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 17),)
          ),
          if (chatInfo.images.length > 1)
            ...[SizedBox(width:3), Text('${chatInfo.images.length+1}',
              style: TextStyle(fontSize: 17, color: Colors.grey))]
         ],
      ),
      SizedBox(height:3),
      Flexible(
        child: Text(
          chatInfo.lastChatContent, 
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color:Colors.grey))
      ),
    ]);

    Widget timeAndUnreadCount = Column(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(_lastChatTimeFormatted(), style: TextStyle(fontSize: 12, color:Colors.grey),),
      SimpleChip(content: '${chatInfo.unreadCount}')
    ]);

    return Container(
      padding: const EdgeInsets.all(10.0),
      height: 70,
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: _buildChatImage(),
          ),
          const SizedBox(width: 10),
          Expanded(child: titleAndLastChat),
          timeAndUnreadCount
        ],
      ),
    );
  }
}