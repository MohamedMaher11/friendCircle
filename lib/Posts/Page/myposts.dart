import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socialmo/Chat/ChatPage/Chatlistpage/chatpagelist.dart';
import 'package:socialmo/Friends/FriendPage/FriendsPage.dart';
import 'package:socialmo/Friends/ProfilePage/profilePage.dart';
import 'package:socialmo/Posts/Widget/Edit_posts.dart';
import 'package:socialmo/Posts/Widget/comments.dart';
import 'package:socialmo/Posts/Widget/sharepost.dart';

import 'package:socialmo/core/textstyle.dart';
import 'package:socialmo/core/utils.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart' as intl;
import 'package:socialmo/lang/app_local.dart';

class MyPosts extends StatefulWidget {
  final String userId,
      name,
      email,
      ProfileImage,
      about_me,
      birthday,
      location,
      myid;

  const MyPosts({
    required this.userId,
    required this.name,
    required this.email,
    required this.ProfileImage,
    required this.about_me,
    required this.birthday,
    required this.location,
    required this.myid,
    Key? key,
  }) : super(key: key);

  @override
  State<MyPosts> createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  bool _loading = true;
  late String _userId;
  bool _uploadingImage = false;
  File? file;
  String? url;
  final FocusNode _postFocusNode = FocusNode();
  late bool isRtl;
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateLastSeenTimestamp();
    _userId = widget.userId;
    _postFocusNode.addListener(_updateFocus);
  }

  void _updateFocus() {
    if (_postFocusNode.hasFocus) {
      // The cursor will show when the TextFormField gains focus
    } else {
      // The cursor will hide when the TextFormField loses focus
    }
  }

  @override
  void dispose() {
    _postFocusNode.removeListener(_updateFocus);
    _postFocusNode.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    final picker = ImagePicker();
    final imageGallery = await picker.pickImage(source: ImageSource.gallery);
    if (imageGallery == null) return;

    setState(() {
      file = File(imageGallery.path);
    });
  }

  void updateLastSeenTimestamp() async {
    // Get current timestamp
    Timestamp timestamp = Timestamp.fromDate(DateTime.now());

    // Update lastSeenTimestamp in Firebase
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'lastSeenTimestamp': timestamp});
  }

  Future<void> postToFirestore(BuildContext context) async {
    if (_postController.text.trim().isEmpty && file == null) return;
    setState(() {
      _uploadingImage = true;
    });

    if (file != null) {
      var imageName = basename(file!.path);
      var refStorage = FirebaseStorage.instance.ref(imageName);
      await refStorage.putFile(file!);
      url = await refStorage.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('posts').add({
      if (url != null) 'image_url': url,
      if (_postController.text.trim().isNotEmpty)
        'title': _postController.text.trim(),
      'userId': widget.userId,
      'timestamp': Timestamp.now(),
      'likes': [],
    });

    _postController.clear();
    setState(() {
      file = null;
      url = null;
      _uploadingImage = false;
    });

    Successwidget(context);
  }

  Future<void> deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }

  void _toggleLike(String postId) async {
    final postDoc = FirebaseFirestore.instance.collection('posts').doc(postId);
    final likes = (await postDoc.get()).data()?['likes'] ?? [];
    final bool isAlreadyLiked = likes.contains(widget.userId);

    if (isAlreadyLiked) {
      await postDoc.update({
        'likes': FieldValue.arrayRemove([widget.userId])
      });
    } else {
      await postDoc.update({
        'likes': FieldValue.arrayUnion([widget.userId])
      });
    }
  }

  Widget _buildSelectedImage() {
    return file != null
        ? Center(
            child: Stack(
              children: [
                Container(
                  width: 300.w,
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      file!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: _clearSelectedImage,
                        color: Colors.black,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        padding: EdgeInsets.all(0),
                        iconSize: 24,
                        constraints: BoxConstraints(),
                      ),
                    )),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  void _clearSelectedImage() {
    setState(() {
      file = null;
    });
  }

  Widget _buildPost(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return SizedBox.shrink();

    final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
    final DateTime dateTime = timestamp.toDate();

    final String currentLocale = Localizations.localeOf(context).languageCode;
    final bool isArabic = currentLocale == 'ar';

    final formattedDate = isArabic
        ? DateFormat.yMMMMd('ar_SA').add_jm().format(dateTime)
        : DateFormat.yMMMMd().add_jm().format(dateTime);

    final bool isCurrentUserPost = data['userId'] == widget.userId;
    final bool isLiked = data['likes']?.contains(widget.userId) ?? false;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(data['userId'])
          .get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData && _loading == true) {
          return Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 150.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.0.sp),
                    Container(
                      width: double.infinity,
                      height: 20.0.h,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      width: 150.0.w,
                      height: 20.0.h,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Container(
                          width: 50.0.w,
                          height: 50.0.h,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.0.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 10.0.h,
                                color: Colors.white,
                              ),
                              SizedBox(height: 5.0.h),
                              Container(
                                width: double.infinity,
                                height: 10.0.h,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) return SizedBox.shrink();

        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0.h),
            child: Card(
              elevation: 4,
              margin: EdgeInsets.all(10.0.w),
              child: GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => profilepage(
                                    userId: data[
                                        'userId'], // هنا تأكد من أن المفتاح صحيح
                                    userData: {
                                      'myid': widget
                                          .myid, // يجب استخدام معرف المستخدم الحالي من الـ widget
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.purple, width: 2.w),
                              ),
                              child: CircleAvatar(
                                radius: 20.r,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: userData['profile_image'] ?? '',
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    width: 40.w,
                                    height: 40.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? '',
                                style: MyTextStyles.boldTextStyle,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                formattedDate,
                                style: MyTextStyles.dateTextStyle,
                              ),
                            ],
                          ),
                          Spacer(),
                          if (isCurrentUserPost)
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text(AppLocal.loc.edit),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPostPage(
                                            currentTitle: data['title'] ?? '',
                                            currentImageUrl:
                                                data['image_url'] ?? '',
                                          ),
                                        ),
                                      );
                                      if (result != null) {
                                        Map<String, dynamic> newData = {};
                                        if (result['title'] != null) {
                                          newData['title'] = result['title'];
                                        }
                                        if (result['imageUrl'] != null) {
                                          newData['image_url'] =
                                              result['imageUrl'];
                                        }
                                        await FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(snapshot.id)
                                            .update(newData);
                                      }
                                    },
                                  ),
                                ),
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text(AppLocal.loc.delete_post),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                Text(AppLocal.loc.deletesure),
                                            content:
                                                Text(AppLocal.loc.deletepost),
                                            actions: [
                                              ElevatedButton(
                                                child:
                                                    Text(AppLocal.loc.cancel),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              ElevatedButton(
                                                child:
                                                    Text(AppLocal.loc.delete),
                                                onPressed: () {
                                                  deletePost(snapshot.id);
                                                  Navigator.of(context)
                                                      .popUntil((route) =>
                                                          route.isFirst);
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        content: Text(AppLocal
                                                            .loc.afterdelete),
                                                        actions: [
                                                          ElevatedButton(
                                                            child: Text(AppLocal
                                                                .loc.ok),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (data.containsKey('image_url'))
                      CachedNetworkImage(
                        imageUrl: data['image_url'] ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    if (data.containsKey('title'))
                      Padding(
                        padding: EdgeInsets.all(9.0.w),
                        child: Text(
                          data['title'] ?? '',
                          style: MyTextStyles.titleTextStyle,
                        ),
                      ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _toggleLike(snapshot.id);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: isRtl ? 0 : 6.w, right: isRtl ? 6.w : 0),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: isLiked ? Colors.red : Colors.grey,
                                    size: 28.sp,
                                  ),
                                  transform: Matrix4.translationValues(
                                    _uploadingImage ? 0.0 : 5.0,
                                    0.0,
                                    0.0,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  data['likes']?.length.toString() ?? '0',
                                  style: MyTextStyles.likesTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _openCommentModelSheet(context, snapshot.id);
                          },
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/chatt.png',
                                width: 20.w,
                                height: 20.h,
                                color: Colors.grey[700],
                              ),
                              SizedBox(height: 2),
                              Text(
                                AppLocal.loc.comment,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: data['title'] ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocal.loc.copysucces)),
                            );
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                color: Colors.blue,
                                size: 28,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                AppLocal.loc.copy,
                                style: MyTextStyles.copytextstyle,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            sharePost(snapshot.id, data['title'] ?? '',
                                data['image_url'] ?? '');
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: isRtl ? 10 : 0, right: isRtl ? 0 : 10),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/shaare.png',
                                  width: 20.w,
                                  height: 20.h,
                                  color: Colors.purple,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  AppLocal.loc.share,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openCommentModelSheet(BuildContext context, String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(
          postId: postId,
          userId: widget.userId,
          userName: widget.name,
          userProfileImage: widget.ProfileImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isRtl =
        intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode);

    AppLocal.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocal.loc.feed),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatListPage(
                    userId: _userId,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/messenger.png',
                width: 30.w,
                height: 30.h,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendsPage(
                    userId: _userId,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/people.png',
                width: 30.w,
                height: 30.h,
              ),
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  logout(context);
                });
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/logout.png',
                  width: 30.w,
                  height: 30.h,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: buildDrawer(
          context,
          widget.name,
          widget.email,
          widget.ProfileImage,
          widget.userId,
          widget.birthday,
          widget.location,
          widget.about_me),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildSelectedImage(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _postController,
                          maxLines: null,
                          focusNode:
                              _postFocusNode, // Assign the FocusNode to the TextFormField

                          decoration: InputDecoration(
                            hintText: AppLocal.loc.mind,
                            border: InputBorder.none,
                            hintStyle: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: getImage,
                        icon: Icon(Icons.photo_library),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Column(
            children: [
              Container(
                width: 360.w,
                child: ElevatedButton.icon(
                  onPressed: () => postToFirestore(context),
                  icon: Icon(
                    Icons.post_add,
                    color: Colors.white,
                  ),
                  label: Text(
                    AppLocal.loc.post,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.purple,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_uploadingImage)
                Center(
                  child: SizedBox(
                    height: 40.h,
                    width: 40.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index]
                        as DocumentSnapshot<Map<String, dynamic>>;
                    return _buildPost(context, doc);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${greetingMessage()}, ${widget.name} 😊❤️',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
        ],
      ),
    );
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
      return '${timeAgo.inDays}${AppLocal.loc.day_ago}';
    } else if (timeAgo.inHours > 0) {
      return '${timeAgo.inHours} ${AppLocal.loc.hour_ago}';
    } else if (timeAgo.inMinutes > 0) {
      return '${timeAgo.inMinutes} ${AppLocal.loc.min_ago}';
    } else {
      return AppLocal.loc.just_now;
    }
  }
}
