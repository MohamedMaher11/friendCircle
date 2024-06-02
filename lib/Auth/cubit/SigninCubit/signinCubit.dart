import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmo/Auth/cubit/SigninCubit/signinstate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Cubit الخاص بتسجيل الدخول
class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> signInWithEmailAndPassword(
      String email, String password, context) async {
    emit(LoginLoading());
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user!.emailVerified) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        Map<String, dynamic> userInfo = userDoc.data() as Map<String, dynamic>;
        emit(LoginSuccess(userCredential.user!, userInfo));
      } else {
        emit(LoginFailure(AppLocalizations.of(context)!.verifyemail));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(LoginFailure(AppLocalizations.of(context)!.usernotfound));
      } else if (e.code == 'wrong-password') {
        emit(LoginFailure(AppLocalizations.of(context)!.wrongpassword));
      }
    }
  }
}
