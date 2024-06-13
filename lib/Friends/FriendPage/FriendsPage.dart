import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:socialmo/Chat/ChatPage/Chats/chat.dart';
import 'package:socialmo/Friends/ProfilePage/profilePage.dart';
import 'package:socialmo/lang/app_local.dart';

class FriendsPage extends StatefulWidget {
  final String userId;

  FriendsPage({required this.userId});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late var isDarkMode;
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _usersStream;
  late Stream<QuerySnapshot> _friendRequestsStream;
  late Stream<QuerySnapshot> _friendsStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    _friendRequestsStream = FirebaseFirestore.instance
        .collection('friend_requests')
        .where('recipientId', isEqualTo: widget.userId)
        .snapshots();
    _friendsStream = FirebaseFirestore.instance
        .collection('friends')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    isDarkMode = theme.brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.lightBlue[50],
        appBar: AppBar(
          title: Text(AppLocal.loc.friends),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        const Color.fromARGB(255, 30, 16, 56),
                        Color.fromARGB(255, 5, 17, 27)
                      ]
                    : [Colors.purple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                labelPadding: EdgeInsets.symmetric(horizontal: 16.0),
                indicatorColor: Colors.transparent,
                labelColor: Colors.purple,
                unselectedLabelColor:
                    isDarkMode ? Colors.white : Colors.grey[400],
                tabs: [
                  Tab(
                    icon: Icon(Icons.person),
                    text: AppLocal.loc.alluser,
                  ),
                  Tab(
                    icon: Icon(Icons.group),
                    text: AppLocal.loc.friendreq,
                  ),
                  Tab(
                    icon: Icon(Icons.people),
                    text: AppLocal.loc.friends,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllUsersTab(),
            _buildFriendRequestsTab(),
            _buildFriendsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return StreamBuilder(
      stream: _friendsStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              AppLocal.loc.nofriend,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          );
        }
        Set<String> displayedFriends = {};

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> friendData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String friendId = friendData['friendId'];
            if (displayedFriends.contains(friendId)) {
              return SizedBox.shrink(); // إذا كان مكرر، لا تعرضه
            }
            displayedFriends.add(friendId);

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendId)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return SizedBox
                      .shrink(); // Skip displaying the friend if data not found
                }
                Map<String, dynamic> userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                return _buildFriendItem(context, userData);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAllUsersTab() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      // إذا كان حقل البحث فارغاً، اعرض جميع المستخدمين
                      _usersStream = FirebaseFirestore.instance
                          .collection('users')
                          .snapshots();
                    } else {
                      // إذا كان هناك نص في حقل البحث، اعرض نتائج البحث
                      _usersStream = _searchUsers(value);
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: AppLocal.loc.search,
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16.0,
                ),
                cursorColor: isDarkMode ? Colors.white : Colors.blue,
                cursorWidth: 2.0,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
              ),
            )),
        Expanded(
          child: StreamBuilder(
            stream: _usersStream,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text(AppLocal.loc.nouser));
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> userData =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return _buildUserItem(context, userData);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFriendRequestsTab() {
    return StreamBuilder(
      stream: _friendRequestsStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(
            AppLocal.loc.nofriendreq,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> requestData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildFriendRequestItem(context, requestData);
          },
        );
      },
    );
  }

  Widget _buildFriendItem(BuildContext context, Map<String, dynamic> userData) {
    bool isCurrentUser = userData['myid'] == widget.userId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => profilepage(
              userId: userData['myid'],
              userData: {
                'myid': widget.userId,
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Leading avatar and name
                  Container(
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.purple,
                              width: 2.0,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                NetworkImage(userData['profile_image'] ?? ''),
                          ),
                        ),
                        SizedBox(width: 10), // Space between avatar and name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['name'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            // Add more details about the user if needed
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  if (!isCurrentUser) ...[
                    PopupMenuButton<int>(
                      icon: Icon(Icons.more_vert,
                          color: isDarkMode ? Colors.white : Colors.grey[700]),
                      onSelected: (int result) {
                        if (result == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                userId: widget.userId,
                                recipientId: userData['myid'],
                                recipientName: userData['name'],
                                email: userData['email'],
                                reciptenimage: userData['profile_image'],
                              ),
                            ),
                          );
                        } else if (result == 1) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  AppLocal.loc.deletesure,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 175, 25, 14),
                                  ),
                                ),
                                content: Text(AppLocal.loc.deleteusersure),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // لإغلاق المربع حوار
                                      _removeFriend(userData[
                                          'myid']); // للقيام بإجراء الحذف
                                    },
                                    child: Text(
                                      AppLocal.loc.ok,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 175, 25, 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // لإغلاق المربع حوار
                                    },
                                    child: Text(
                                      AppLocal.loc.cancel,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<int>>[
                        PopupMenuItem<int>(
                          value: 0,
                          child: Container(
                            width: 120,
                            child: Row(
                              children: [
                                Icon(Icons.message, color: Colors.blue),
                                SizedBox(width: 10),
                                Text(
                                  AppLocal.loc.message,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 1,
                          child: Container(
                            width: 120,
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 10),
                                Text(
                                  AppLocal.loc.removefriend,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, Map<String, dynamic> userData) {
    bool isCurrentUser = userData['myid'] == widget.userId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => profilepage(
              userId: userData['myid'],
              userData: {
                'myid': widget.userId,
              },
            ),
          ),
        );
      },
      child: SizedBox(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.purple,
                        width: 2.0.w,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 25.r,
                      backgroundImage:
                          NetworkImage(userData['profile_image'] ?? ''),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            userData['name'] ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15.sp),
                          ),
                        ),
                      ])
                ],
              ),
              trailing: isCurrentUser
                  ? null
                  : SizedBox(
                      width: 100.w,
                      child: _buildAddFriendButton(userData['myid']),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddFriendButton(String friendId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('friends')
          .where('userId', isEqualTo: widget.userId)
          .where('friendId', isEqualTo: friendId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return SizedBox(
            width: 100.w,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                AppLocal.loc.friend,
                style: TextStyle(
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  fontSize: 9.sp,
                ),
              ),
            ),
          );
        } else {
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('friend_requests')
                .where('senderId', isEqualTo: widget.userId)
                .where('recipientId', isEqualTo: friendId)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> requestSnapshot) {
              if (requestSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (requestSnapshot.hasData &&
                  requestSnapshot.data!.docs.isNotEmpty) {
                return SizedBox(
                  width: 100.w,
                  child: ElevatedButton(
                    onPressed: () {
                      // افعل شيئًا عند الضغط على الزر
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey, // لون النص داخل الزر
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // تقريب حواف الزر
                      ),
                    ),
                    child: Text(
                      AppLocal.loc.pending,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp, // يمكنك تعديل حجم الخط حسب الحاجة
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  width: 100.w,
                  child: ElevatedButton(
                    onPressed: () {
                      _sendFriendRequest(friendId);
                    },
                    child: Text(
                      AppLocal.loc.addfriend,
                      style: TextStyle(fontSize: 9.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: isDarkMode
                          ? Color.fromARGB(255, 149, 37, 168)
                          : Color.fromARGB(255, 202, 64, 184),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildFriendRequestItem(
      BuildContext context, Map<String, dynamic> requestData) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(requestData['senderId'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text(
            AppLocal.loc.nouser,
            style: TextStyle(color: Colors.black),
          );
        }
        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userData['profile_image'] ?? ''),
          ),
          title: Text(userData['name'] ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                child: Text(AppLocal.loc.acceptfriend),
                onPressed: () {
                  _acceptFriendRequest(requestData['senderId'], widget.userId);
                },
              ),
              TextButton(
                child: Text(AppLocal.loc.refusefriend),
                onPressed: () {
                  _rejectFriendRequest(requestData['senderId'], widget.userId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _searchUsers(String searchQuery) {
    String query = searchQuery.toLowerCase(); // تحويل النص إلى حروف صغيرة

    return FirebaseFirestore.instance
        .collection('users')
        .where('name_lowercase', isGreaterThanOrEqualTo: query)
        .where('name_lowercase',
            isLessThan: query + '\uf8ff') // استخدام حرف Unicode الأخير
        .snapshots();
  }

  Future<bool> _checkIfAlreadySent(String senderId, String recipientId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('senderId', isEqualTo: senderId)
        .where('recipientId', isEqualTo: recipientId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _sendFriendRequest(String recipientId) async {
    String currentUserId = widget.userId;
    bool alreadySent = await _checkIfAlreadySent(currentUserId, recipientId);

    if (!alreadySent) {
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'senderId': currentUserId,
        'recipientId': recipientId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _acceptFriendRequest(String senderId, String recipientId) async {
    await FirebaseFirestore.instance.collection('friends').add({
      'userId': senderId,
      'friendId': recipientId,
    });
    await FirebaseFirestore.instance.collection('friends').add({
      'userId': recipientId,
      'friendId': senderId,
    });

    await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('senderId', isEqualTo: senderId)
        .where('recipientId', isEqualTo: recipientId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.first.reference.delete();
    });

    await FirebaseFirestore.instance.collection('users').doc(senderId).update({
      'friends': FieldValue.arrayUnion([
        {
          'userId': recipientId,
        }
      ])
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(recipientId)
        .update({
      'friends': FieldValue.arrayUnion([
        {
          'userId': senderId,
        }
      ])
    });
  }

  void _rejectFriendRequest(String senderId, String recipientId) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('senderId', isEqualTo: senderId)
        .where('recipientId', isEqualTo: recipientId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.first.reference.delete();
    });
  }

  void _removeFriend(String friendId) async {
    // Remove friend from your friend list
    await FirebaseFirestore.instance
        .collection('friends')
        .where('userId', isEqualTo: widget.userId)
        .where('friendId', isEqualTo: friendId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
    await FirebaseFirestore.instance
        .collection('friends')
        .where('userId', isEqualTo: friendId)
        .where('friendId', isEqualTo: widget.userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'friends': FieldValue.arrayRemove([
        {'userId': friendId}
      ])
    });
    await FirebaseFirestore.instance.collection('users').doc(friendId).update({
      'friends': FieldValue.arrayRemove([
        {'userId': widget.userId}
      ])
    });
  }
}
