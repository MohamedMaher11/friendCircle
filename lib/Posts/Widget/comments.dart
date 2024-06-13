import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socialmo/lang/app_local.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String userId;
  final String userName;
  final String userProfileImage;

  CommentsPage({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
  });

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocal.loc.comment),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildCommentsList(widget.postId),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black),
                      hintText: AppLocal.loc.addcomment,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _addComment(widget.postId);
                    _commentController.clear();
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(String postId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final comments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index].data() as Map<String, dynamic>?;
              final text = comment?['text'] as String?;
              final timestamp = comment?['timestamp'] as Timestamp?;
              final timeAgo = formatTimestamp(timestamp);
              final commentId = comments[index].id;
              final commentUserId = comment?['userId'] as String?;

              final bool isCurrentUserComment = commentUserId == widget.userId;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(commentUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData == null) return SizedBox.shrink();

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            userData['profile_image'] ?? ''),
                      ),
                      title: Text(
                        userData['name'] ?? 'No text',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(text ?? 'Anonymous',
                          style: TextStyle(
                            color: Colors.black,
                          )),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeAgo,
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                          if (isCurrentUserComment)
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _deleteComment(postId, commentId);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  void _addComment(String postId) async {
    if (_commentController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'text': _commentController.text.trim(),
      'userId': widget.userId,
      'timestamp': Timestamp.now(),
    }).then((value) {
      print('Comment added successfully!');
    }).catchError((error) {
      print('Error adding comment: $error');
    });
  }

  void _deleteComment(String postId, String commentId) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    final timeAgo = DateTime.now().difference(dateTime);

    if (timeAgo.inDays > 365) {
      return '${(timeAgo.inDays / 365).floor()} ${AppLocal.loc.years_ago}';
    } else if (timeAgo.inDays > 30) {
      return '${(timeAgo.inDays / 30).floor()} ${AppLocal.loc.month_age}';
    } else if (timeAgo.inDays > 7) {
      return '${(timeAgo.inDays / 7).floor()} ${AppLocal.loc.weeks_ago}';
    } else if (timeAgo.inDays > 0) {
      return '${timeAgo.inDays} ${AppLocal.loc.day_ago}';
    } else if (timeAgo.inHours > 0) {
      return '${timeAgo.inHours} ${AppLocal.loc.hour_ago}';
    } else if (timeAgo.inMinutes > 0) {
      return '${timeAgo.inMinutes} ${AppLocal.loc.min_ago}';
    } else {
      return '${AppLocal.loc.just_now}';
    }
  }
}
