import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmo/Auth/Authantication/Login.dart';
import 'package:socialmo/Auth/Authantication/signup.dart';
import 'package:socialmo/Posts/Page/myposts.dart';
import 'package:socialmo/l10n/l10n.dart';
import 'package:socialmo/lang/setting_provider.dart';
import 'package:socialmo/lang/shared_pref.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  final savedLanguageCode =
      prefs.getString('language_code') ?? 'en'; // استرجاع اللغة المحفوظة

  final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.blue,
  );
  final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.blue,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    Widget homeWidget;
    if (user != null && user.emailVerified) {
      if (isLoggedIn) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        homeWidget = MyPosts(
          userId: user.uid,
          name: userData['name'],
          birthday: userData['birthday'],
          email: user.email ?? '',
          ProfileImage: userData['profile_image'],
          myid: userData['myid'],
          about_me: userData['about_me'],
          location: userData['location'],
        );
      } else {
        homeWidget = LoginPage();
      }
    } else {
      homeWidget = SignupPage();
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) =>
                SettingProvider()..updateLocal(savedLanguageCode),
          ),
        ],
        child: Builder(
          builder: (context) {
            return AdaptiveTheme(
              light: lightTheme,
              dark: darkTheme,
              initial: savedThemeMode ?? AdaptiveThemeMode.light,
              builder: (theme, darkTheme) => Consumer<SettingProvider>(
                builder: (context, provider, child) {
                  return MaterialApp(
                    theme: theme,
                    darkTheme: darkTheme,
                    debugShowCheckedModeBanner: false,
                    supportedLocales: L10n.all,
                    locale: Locale(provider.local ?? savedLanguageCode),
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    title: 'Friend Cirlce',
                    home: homeWidget,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  });
}
