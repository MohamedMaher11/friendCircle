import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:socialmo/Auth/cubit/SignupCubit/Signupstate.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String birthday,
    required String location,
    required String aboutMe,
    required String lowercase,
    File? imageFile,
  }) async {
    emit(SignupLoading());
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;

      String imageUrl = 'https://cdn-icons-png.flaticon.com/128/149/149071.png';
      if (imageFile != null) {
        final storageRef = _storage.ref().child('profile_images/${user!.uid}');
        await storageRef.putFile(imageFile);
        imageUrl = await storageRef.getDownloadURL();
      }

      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'birthday': birthday,
        'email': email,
        'location': location,
        'about_me': aboutMe,
        'profile_image': imageUrl,
        'myid': user.uid,
        'name_lowercase': lowercase,
        'lastSeenTimestamp': Timestamp.now(),
      });

      user.sendEmailVerification();

      emit(SignupSuccess());
    } on FirebaseAuthException catch (e) {
      emit(SignupFailure(error: e.message));
    }
  }
}
