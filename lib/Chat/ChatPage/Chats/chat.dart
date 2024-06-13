import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socialmo/Chat/ChatPage/Widget/showmesseges.dart';
import 'package:socialmo/lang/app_local.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String recipientId;
  final String recipientName;
  final String email;
  final String reciptenimage;

  const ChatPage({
    required this.userId,
    required this.recipientId,
    required this.recipientName,
    required this.email,
    required this.reciptenimage,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late final Stream<List<Map<String, dynamic>>> messagesStream;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> userActivityStream;
  File? _selectedImage;
  String? _selectedImageUrl;

  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  var _audioFilePath;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    messagesStream = _createMessagesStream();
    userActivityStream = _createUserActivityStream();
  }

  @override
  void dispose() {
    _audioRecorder?.closeRecorder();
    super.dispose();
  }

  Future<void> _stopRecording() async {
    await _audioRecorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    // Hide the recording dialog when recording stops
    Navigator.of(context).pop();
    _uploadAudio();
  }

  void _initializeRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
    _audioRecorder!.setSubscriptionDuration(Duration(milliseconds: 10));
  }

  void _showRecordingDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mic, color: Colors.green, size: 30), // Icon for recording
            SizedBox(width: 10), // Spacer
            Text(AppLocal.loc.recording), // Title text
          ],
        ),
        content: Text(AppLocal.loc.recordpro),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Change button color to green
            ),
            child: Text(
              AppLocal.loc.send,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _stopRecording();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Change button color to red
            ),
            child: Text(
              AppLocal.loc.cancel,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _audioRecorder?.stopRecorder();
              setState(() {
                _isRecording = false;
              });
              Navigator.of(context).pop(); // Close the dialog without sending
            },
          ),
        ],
      );
    },
  );
}


  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle the case when permission is not granted
      return;
    }
    try {
      // Define a valid local file path
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.aac';
      _audioFilePath = '${(await getTemporaryDirectory()).path}/$fileName';

      // Start recording to the local file
      await _audioRecorder!.startRecorder(toFile: _audioFilePath);
      setState(() {
        _isRecording = true;
      });
      // Show a dialog indicating recording has started
      _showRecordingDialog();
    } catch (e) {
      print('Error starting recorder: $e');
    }
  }

  Future<void> _uploadAudio() async {
    if (_audioFilePath != null) {
      File audioFile = File(_audioFilePath!);
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_audios')
          .child('${DateTime.now().millisecondsSinceEpoch}.aac');

      try {
        UploadTask uploadTask = storageRef.putFile(audioFile);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppLocal.loc.sending),
                ],
              ),
            );
          },
        );

        String audioUrl = await (await uploadTask).ref.getDownloadURL();
        setState(() {
          _audioFilePath = null;
        });

        Navigator.of(context).pop();
        _sendMessage(null, audioUrl);
      } catch (error) {
        print('Error uploading audio: $error');
        // Handle error
      }
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
      _showSelectedImage(_selectedImage!);

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      try {
        UploadTask uploadTask = storageRef.putFile(imageFile);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppLocal.loc.uploading),
                ],
              ),
            );
          },
        );

        String imageUrl = await (await uploadTask).ref.getDownloadURL();
        setState(() {
          _selectedImageUrl = imageUrl;
        });

        Navigator.of(context).pop();
      } catch (error) {
        print('Error uploading image: $error');
        // Handle error
      }
    }
  }

  void _sendMessage(String? messageText, [String? audioUrl]) async {
    if ((messageText != null && messageText.isNotEmpty) ||
        audioUrl != null ||
        _selectedImageUrl != null) {
      FirebaseFirestore.instance.collection('chats').add({
        'senderId': widget.userId,
        'recipientId': widget.recipientId,
        'message': messageText,
        'email': widget.email,
        'profile_image': widget.reciptenimage,
        'recipientName': widget.recipientName,
        'timestamp': Timestamp.now(),
        'image': _selectedImageUrl,
        'audio': audioUrl,
      });

      _messageController.clear();
      setState(() {
        _selectedImageUrl = null;
      });
    }
  }

  void _showSelectedImage(File selectedImage) {
    TextEditingController _messageTextController = TextEditingController();
    bool _shouldSendMessage = false;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: EdgeInsets.all(16),
                ),
                Image.file(
                  selectedImage,
                  width: double.infinity,
                  height: 300.h,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    maxLines: null,
                    controller: _messageTextController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: AppLocal.loc.typemessege,
                      hintStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _pickImage();
              },
              child: Text(AppLocal.loc.editimage,
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              onPressed: () {
                _shouldSendMessage = true;
                Navigator.pop(context);
              },
              child: Text(AppLocal.loc.send,
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (!_shouldSendMessage) {
        setState(() {
          _selectedImage = null;
        });
      }
      if (_shouldSendMessage) {
        _sendMessage(_messageTextController.text);
      }
    });
  }

  Stream<List<Map<String, dynamic>>> _createMessagesStream() {
    return Rx.combineLatest2(
      FirebaseFirestore.instance
          .collection('chats')
          .where('senderId', isEqualTo: widget.userId)
          .where('recipientId', isEqualTo: widget.recipientId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      FirebaseFirestore.instance
          .collection('chats')
          .where('senderId', isEqualTo: widget.recipientId)
          .where('recipientId', isEqualTo: widget.userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      (QuerySnapshot sentMessages, QuerySnapshot receivedMessages) {
        List<Map<String, dynamic>> allMessages = [];
        allMessages.addAll(sentMessages.docs.map((message) => {
              'messageId': message.id,
              'message': message['message'],
              'image': message['image'],
              'audio': message['audio'],
              'isSender': true,
              'timestamp': message['timestamp'],
            }));
        allMessages.addAll(receivedMessages.docs.map((message) => {
              'messageId': message.id,
              'message': message['message'],
              'image': message['image'],
              'audio': message['audio'],
              'isSender': false,
              'timestamp': message['timestamp'],
            }));
        allMessages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        return allMessages;
      },
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _createUserActivityStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.recipientId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0d2645),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundImage: CachedNetworkImageProvider(widget.reciptenimage),
            ),
            SizedBox(width: 8),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: userActivityStream,
                builder: (context, snapshot) {
                  String userName = widget.recipientName;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      userName,
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Text(
                      userName,
                      style: TextStyle(color: Color(0xFFf3dcde)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  }
                  var lastActiveTimestamp =
                      snapshot.data!.data()?['lastSeenTimestamp'];
                  var lastActiveTime = lastActiveTimestamp != null
                      ? DateFormat.yMd()
                          .add_jm()
                          .format(lastActiveTimestamp.toDate())
                      : 'Unknown';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(color: Colors.white, fontSize: 15.sp),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '${AppLocal.loc.lastactive} $lastActiveTime',
                        style: TextStyle(fontSize: 15.sp, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: ImageIcon(
              AssetImage('assets/video.png'),
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: ImageIcon(
              AssetImage('assets/telephone.png'),
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(widget.reciptenimage),
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: messagesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        final List<Map<String, dynamic>> allMessages =
                            snapshot.data ?? [];
                        if (allMessages.isEmpty) {
                          return Center(
                            child: Text(
                              AppLocal.loc.nomessege,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return ListView.builder(
                          reverse: true,
                          itemCount: allMessages.length,
                          itemBuilder: (context, index) {
                            var message = allMessages[index];
                            return GestureDetector(
                              onLongPress: () {
                                _showDeleteConfirmationDialog(
                                    message['messageId']);
                              },
                              child: MessageWidget(
                                message: message['message'],
                                isSender: message['isSender'],
                                timestamp: message['timestamp'],
                                image: message['image'],
                                audio: message['audio'],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            maxLines: null,
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: AppLocal.loc.typemessege,
                              hintStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.image,
                            color: Colors.blue,
                          ),
                          onPressed: _pickImage,
                        ),
                        IconButton(
                          icon: Icon(
                            _isRecording ? Icons.mic_off : Icons.mic,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            if (_isRecording) {
                              _stopRecording();
                            } else {
                              _startRecording();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            _sendMessage(_messageController.text);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocal.loc.deletemessege),
          content: Text(AppLocal.loc.confirmdelete),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocal.loc.cancel),
            ),
            TextButton(
              onPressed: () {
                _deleteMessage(messageId);
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocal.loc.deletemessege,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(String messageId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(messageId)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        var messageData = snapshot.data();
        if (messageData != null) {
          String senderId = messageData['senderId'];
          if (senderId == widget.userId) {
            FirebaseFirestore.instance
                .collection('chats')
                .doc(messageId)
                .delete();
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(AppLocal.loc.cannotdeletemessege),
                  content: Text(AppLocal.loc.deleteyourmessege),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocal.loc.ok),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    });
  }
}
