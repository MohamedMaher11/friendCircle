import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:socialmo/Chat/ChatPage/Chats/chat.dart';
import 'package:socialmo/lang/app_local.dart';

class ChatListPage extends StatefulWidget {
  final String userId;

  const ChatListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late final Stream<List<Map<String, dynamic>>> chatListStream;

  @override
  void initState() {
    super.initState();

    chatListStream = FirebaseFirestore.instance
        .collection('chats')
        .snapshots()
        .asyncMap((QuerySnapshot snapshot) async {
      Map<String, Map<String, dynamic>> chatMap = {};

      for (DocumentSnapshot doc in snapshot.docs) {
        String senderId = doc['senderId'];
        String recipientId = doc['recipientId'];

        if (senderId == widget.userId || recipientId == widget.userId) {
          String otherUserId =
              (recipientId == widget.userId) ? senderId : recipientId;

          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(otherUserId)
              .get();

          if (userSnapshot.exists) {
            String senderName = userSnapshot['name'];
            String senderImage = userSnapshot['profile_image'];

            String lastMessage = doc['image'] ?? doc['message'] ?? '';
            Timestamp timestamp = doc['timestamp'];

            if (!chatMap.containsKey(otherUserId) ||
                timestamp.compareTo(chatMap[otherUserId]?['lastMessageTime']) >
                    0) {
              chatMap[otherUserId] = {
                'recipientId': otherUserId,
                'recipientName': senderName,
                'lastMessage': lastMessage,
                'lastMessageTime': timestamp,
                'profile_image': senderImage,
              };
            }
          }
        }
      }

      return chatMap.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocal.loc.chat),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatListStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          List<Map<String, dynamic>> chatList = snapshot.data ?? [];
          if (chatList.isEmpty) {
            return Center(child: Text('No chats'));
          }
          return ListView.builder(
            itemCount: chatList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: _buildFriendItem(context, chatList[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFriendItem(BuildContext context, Map<String, dynamic> userData) {
    String lastMessage =
        userData['lastMessage'] ?? ''; // تحديث قيمة lastMessage

    return Card(
      elevation: 8.0, // زيادة الارتفاع لمظهر بروز وواقعي
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // تغيير شكل الزوايا
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                userId: widget.userId,
                recipientId: userData['recipientId'],
                recipientName: userData['recipientName'] ?? '',
                email: '', // Remove email as it's not used
                reciptenimage: userData['profile_image'] ?? '',
              ),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 30.r,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(userData['profile_image'] ?? ''),
        ),
        title: Text(
          userData['recipientName'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: lastMessage.isNotEmpty && lastMessage.startsWith('http')
            ? Text(AppLocal.loc.pic +
                "   "
                    '${_formatTimestamp(userData['lastMessageTime'])}')
            : Text(
                '${userData['lastMessage'] ?? ''} • ${_formatTimestamp(userData['lastMessageTime'])}',
              ),
        trailing: Icon(
            Icons.arrow_forward_ios_rounded), // تغيير الأيقونة لتناسب التصميم
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    // Check if app language is Arabic
    if (Localizations.localeOf(context).languageCode == 'ar') {
      final timeFormat = DateFormat.jm('ar');
      return timeFormat.format(dateTime);
    } else {
      // Default format if language is not Arabic
      final timeFormat = DateFormat.jm();
      return timeFormat.format(dateTime);
    }
  }
}
