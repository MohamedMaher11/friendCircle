import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmo/Chat/ChatPage/Chats/chat.dart';
import 'package:socialmo/lang/app_local.dart';

class profilepage extends StatefulWidget {
  final String userId;
  Map<String, dynamic> userData;

  profilepage({
    required this.userId,
    required this.userData,
  });

  @override
  _profilepageState createState() => _profilepageState();
}

class _profilepageState extends State<profilepage> {
  bool _isImageSelected = false;

  File? _imageFile;
  final picker = ImagePicker();
  bool isEditingLocation = false;
  bool isEditingAboutMe = false;
  String newLocation = '';
  String newAboutMe = '';
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  bool isCurrentUser = false;
  final currentuserid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    isCurrentUser = widget.userData['myid'] == widget.userId;
    getUserData();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    // Get the current user's ID
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        isCurrentUser = currentUser.uid == widget.userId;
      });
      getUserData();
    }
  }

  @override
  void dispose() {
    aboutMeController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> getUserData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    setState(() {
      widget.userData = userSnapshot.data() as Map<String, dynamic>;
      aboutMeController.text = widget.userData['about_me'] ?? '';
      locationController.text = widget.userData['location'] ?? '';
    });
  }

  Future<void> updateLocation(String newLocation) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'location': newLocation});

    setState(() {
      widget.userData['location'] = newLocation;
      isEditingLocation = false;
    });
  }

  Future<void> updateAboutMe(String newAboutMe) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'about_me': newAboutMe});

    setState(() {
      widget.userData['about_me'] = newAboutMe;
      isEditingAboutMe = false;
    });
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _isImageSelected = true;
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final storage = FirebaseStorage.instance;
    final String fileName = widget.userId;
    final Reference reference = storage.ref().child('profile_images/$fileName');

    await reference.putFile(_imageFile!);
    final String imageUrl = await reference.getDownloadURL();

    // Update the user's profile image URL in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'profile_image': imageUrl});

    // Show a snackbar to indicate success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocal.loc.profileupdatesuccess)),
    );

    // Update the displayed image immediately
    setState(() {
      widget.userData['profile_image'] = imageUrl;
      _isImageSelected = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      await updateBirthday(picked);
    }
  }

  Future<void> updateBirthday(DateTime newBirthday) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'birthday': newBirthday.toString()});

    setState(() {
      widget.userData['birthday'] = newBirthday.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;
    final DateTime? birthday = userData['birthday'] != null
        ? DateTime.parse(userData['birthday'])
        : null;

    return Scaffold(
      body: Stack(
        children: [
          if (userData.containsKey('profile_image'))
            _buildBackground(context, userData['profile_image']),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 10),
                _buildTitle(context),
                SizedBox(height: 20),
                if (userData.containsKey('profile_image'))
                  CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(userData['profile_image']),
                    radius: 70,
                  ),
                SizedBox(height: 20),
                if (isCurrentUser)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _getImage,
                        child: Text(
                          AppLocal.loc.changeprofilepic,
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 75, 72, 72),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ).copyWith(
                          textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _uploadImage,
                        child: Text(
                          AppLocal.loc.uploadprofilepic,
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isImageSelected
                              ? Colors.blue
                              : const Color.fromARGB(255, 75, 72, 72),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ).copyWith(
                          textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                Text(
                  userData['name'] ?? '',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          userId:
                              currentuserid, // استخدام معرّف المستخدم الحالي
                          recipientId: userData['myid'],
                          recipientName: userData['name'],
                          email: userData['email'],
                          reciptenimage: userData['profile_image'],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/messenger.png',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 5),
                      Text(
                        AppLocal.loc.message,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.white),
                  title: Text(
                    AppLocal.loc.about_me,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: isEditingAboutMe
                      ? TextField(
                          controller: aboutMeController,
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            setState(() {
                              newAboutMe = value;
                            });
                          },
                          onSubmitted: (newValue) async {
                            await updateAboutMe(newValue);
                          },
                        )
                      : Text(
                          userData['about_me'] ?? 'No information',
                          style: TextStyle(color: Colors.white),
                        ),
                  trailing: isCurrentUser
                      ? IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              isEditingAboutMe = !isEditingAboutMe;
                            });
                          },
                        )
                      : SizedBox(),
                ),
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.white),
                  title: Text(AppLocal.loc.location,
                      style: TextStyle(color: Colors.white)),
                  subtitle: isEditingLocation
                      ? TextField(
                          controller: locationController,
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            setState(() {
                              newLocation = value;
                            });
                          },
                          onSubmitted: (newValue) async {
                            await updateLocation(newValue);
                          },
                        )
                      : Text(
                          userData['location'] ?? 'No information',
                          style: TextStyle(color: Colors.white),
                        ),
                  trailing: isCurrentUser
                      ? IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              isEditingLocation = !isEditingLocation;
                            });
                          },
                        )
                      : SizedBox(),
                ),
                ListTile(
                  leading: Icon(Icons.cake, color: Colors.white),
                  title: Text(
                    AppLocal.loc.birthday,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: GestureDetector(
                    onTap: isCurrentUser ? () => _selectDate(context) : null,
                    child: Text(
                      birthday != null
                          ? DateFormat('MMMM d, yyyy').format(birthday)
                          : 'No information',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  trailing: isCurrentUser
                      ? IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _selectDate(context),
                        )
                      : SizedBox(),
                ),
                SizedBox(
                  height: 20,
                ),
                if (isCurrentUser)
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isEditingLocation) {
                          updateLocation(newLocation);
                        }
                        if (isEditingAboutMe) {
                          updateAboutMe(newAboutMe);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.purple, // Text color
                        elevation: 5, // Elevation for shadow effect
                        padding: EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15), // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded corners
                        ),
                      ),
                      child: Text(
                        AppLocal.loc.save,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _buildSocialIcon(
                              iconAsset: 'assets/linkedin.png',
                              //  url: widget.userData['linkedin_url'],
                            ),
                            _buildSocialIcon(
                              iconAsset: 'assets/instagram.png',
                              //   url: widget.userData['instagram_url'],
                            ),
                            _buildSocialIcon(
                              iconAsset: 'assets/facebook.png',
                              //   url: widget.userData['facebook_url'],
                            ),
                          ],
                        )))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon({required String iconAsset, String? url}) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ImageIcon(
          AssetImage(iconAsset),
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(width: 48.0.w), // Adjust the space if needed
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.black.withOpacity(0.5),
        ),
      ),
    );
  }
}
