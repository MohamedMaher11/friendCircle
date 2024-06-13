import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmo/Auth/Authantication/Login.dart';
import 'package:socialmo/Friends/ProfilePage/profilePage.dart';
import 'package:socialmo/l10n/l10n.dart';
import 'package:socialmo/lang/app_local.dart';
import 'package:socialmo/lang/setting_provider.dart';
import 'package:socialmo/lang/shared_pref.dart';

String formatTimestamp(Timestamp? timestamp) {
  final now = DateTime.now();
  final createdAt = timestamp?.toDate() ?? now;
  final difference = now.difference(createdAt);

  if (difference.inSeconds < 5) {
    return AppLocal.loc.just_now;
  } else if (difference.inMinutes < 1) {
    return AppLocal.loc.few_sec;
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes} ${AppLocal.loc.min_ago}';
  } else if (difference.inDays < 1) {
    return '${difference.inHours} ${AppLocal.loc.hour_ago}';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} ${AppLocal.loc.day_ago}';
  } else {
    return DateFormat('dd MMM yyyy').format(createdAt);
  }
}

String greetingMessage() {
  final hour = DateTime.now().hour;
  if (hour >= 0 && hour < 12) {
    return AppLocal.loc.morning;
  } else if (hour >= 12 && hour < 18) {
    return AppLocal.loc.afternoon;
  } else {
    return AppLocal.loc.evening;
  }
}

Future Successwidget(context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text(AppLocal.loc.success),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Text(AppLocal.loc.postsuccess),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocal.loc.ok),
          ),
        ],
      );
    },
  );
}

void logout(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? languageCode =
      preferences.getString('language_code'); // احتفظ باللغة المحفوظة

  preferences.remove('id');
  preferences.remove('name');
  preferences.remove('email');
  preferences.remove('ProfileImage');
  preferences.remove('birthday');
  preferences.remove('location');
  preferences.remove('about_me');
  preferences.remove('friends');
  preferences.remove('chattingWith');
  preferences.remove('ChatRoomId');
  preferences.clear();
  if (languageCode != null) {
    preferences.setString(
        'language_code', languageCode); // إعادة تخزين اللغة المحفوظة
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LoginPage(),
    ),
  );
}

Drawer buildDrawer(
  BuildContext context,
  String name,
  String email,
  String profileImage,
  String userId,
  String birthday,
  String location,
  String about_me,
) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  return Drawer(
    elevation: 8,
    child: Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/drawer.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(profileImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ))),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${AppLocal.loc.welcome} $name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: theme.iconTheme.color),
            title: Text(
              AppLocal.loc.profile,
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color, fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => profilepage(
                    userId: userId,
                    userData: {
                      'name': name,
                      'email': email,
                      'profile_image': profileImage,
                      'myid': userId,
                      'birthday': birthday,
                      'location': location,
                      'about_me': about_me,
                      // Add other user data if available
                    },
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.iconTheme.color),
            title: Text(
              AppLocal.loc.setting,
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color, fontSize: 18),
            ),
            onTap: () {
              // Add navigation to settings page
            },
          ),
          Divider(color: theme.dividerColor),
          ListTile(
            leading: Icon(Icons.help, color: theme.iconTheme.color),
            title: Text(
              AppLocal.loc.help,
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color, fontSize: 18),
            ),
            onTap: () {
              // Add navigation to help & support page
            },
          ),
          Divider(color: theme.dividerColor),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            leading: Icon(Icons.dark_mode, color: theme.iconTheme.color),
            title: Text(
              AppLocal.loc.theme,
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color, fontSize: 18),
            ),
            trailing: GestureDetector(
              onTap: () {
                if (isDarkMode) {
                  AdaptiveTheme.of(context).setLight();
                } else {
                  AdaptiveTheme.of(context).setDark();
                }
              },
              child: Container(
                width: 48.0,
                height: 28.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[400],
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: isDarkMode ? 18.0 : 0.0,
                      right: isDarkMode ? 0.0 : 18.0,
                      child: Container(
                        width: 28.0,
                        height: 28.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          isDarkMode
                              ? Icons.nightlight_round
                              : Icons.wb_sunny_rounded,
                          size: 18.0,
                          color: isDarkMode ? Colors.yellow : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.language, color: theme.iconTheme.color),
            title: Text(
              AppLocal.loc.select_language,
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color, fontSize: 18),
            ),
            trailing: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final SettingProvider prov =
                    Provider.of<SettingProvider>(context, listen: false);
                return PopupMenuButton<String>(
                  icon: Icon(Icons.arrow_drop_down),
                  onSelected: (String? value) {
                    if (value != null) {
                      setState(() {
                        SharedPref.addLang(value);
                        prov.updateLocal(value);
                        print(SharedPref.lang);
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return List.generate(
                      L10n.all.length,
                      (index) => PopupMenuItem<String>(
                        value: L10n.all[index].languageCode,
                        child: Row(
                          children: [
                            Image(
                              image: AssetImage(
                                L10n.all[index].languageCode == 'en'
                                    ? 'assets/br.png'
                                    : 'assets/eg.png',
                              ),
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              L10n.all[index].languageCode == 'en'
                                  ? AppLocal.loc.langEN
                                  : AppLocal.loc.langAR,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
