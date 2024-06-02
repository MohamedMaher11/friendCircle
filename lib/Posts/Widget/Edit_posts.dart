import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:socialmo/lang/app_local.dart';

class EditPostPage extends StatefulWidget {
  final String currentTitle;
  final String currentImageUrl;

  EditPostPage({required this.currentTitle, required this.currentImageUrl});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late String newTitle;
  String? newImageUrl;
  bool hasImage = false;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    newTitle = widget.currentTitle;
    _titleController = TextEditingController(text: widget.currentTitle);
    if (widget.currentImageUrl.isNotEmpty) {
      newImageUrl = widget.currentImageUrl;
      hasImage = true;
    }
  }

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      hasImage = true;
      _uploadImageToFirebase(pickedFile.path);
    });
  }

  Future<void> _uploadImageToFirebase(String imagePath) async {
    File imageFile = File(imagePath);
    var imageName = basename(imageFile.path);
    var refStorage = FirebaseStorage.instance.ref().child(imageName);
    var uploadTask = refStorage.putFile(imageFile);
    var snapshot = await uploadTask.whenComplete(() {});
    var downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      newImageUrl = downloadUrl;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocal.loc.edit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              maxLines: null, // السماح للنص بالتمدد عمودياً
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'New Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  newTitle = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: getImage,
              child: Text(AppLocal.loc.selectimage),
            ),
            if (hasImage && newImageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.network(
                  newImageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(
                    context, {'title': newTitle, 'imageUrl': newImageUrl});
              },
              child: Text(AppLocal.loc.savechange),
            ),
          ],
        ),
      ),
    );
  }
}
