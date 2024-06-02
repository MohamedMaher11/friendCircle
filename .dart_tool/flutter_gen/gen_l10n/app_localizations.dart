import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'application'**
  String get application;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'settings'**
  String get setting;

  /// No description provided for @langAR.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langAR;

  /// No description provided for @langEN.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEN;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'blue'**
  String get blue;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'green'**
  String get green;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'purple'**
  String get purple;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @createaccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createaccount;

  /// No description provided for @welcomeback.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeback;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @requireemail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get requireemail;

  /// No description provided for @requirepassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Password'**
  String get requirepassword;

  /// No description provided for @requirename.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get requirename;

  /// No description provided for @requirebirthday.
  ///
  /// In en, this message translates to:
  /// **'Please select your birthday'**
  String get requirebirthday;

  /// No description provided for @requirelocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your location'**
  String get requirelocation;

  /// No description provided for @requireaboutme.
  ///
  /// In en, this message translates to:
  /// **'Please enter your about me'**
  String get requireaboutme;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get evening;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get afternoon;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get night;

  /// No description provided for @mind.
  ///
  /// In en, this message translates to:
  /// **'Whats on your mind?'**
  String get mind;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'comment'**
  String get comment;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'copy text'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'share'**
  String get share;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get delete;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'post'**
  String get post;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'welcome'**
  String get welcome;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @lastmessege.
  ///
  /// In en, this message translates to:
  /// **'Last message'**
  String get lastmessege;

  /// No description provided for @lastactive.
  ///
  /// In en, this message translates to:
  /// **'Last Active'**
  String get lastactive;

  /// No description provided for @typemessege.
  ///
  /// In en, this message translates to:
  /// **'Type your message'**
  String get typemessege;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'send'**
  String get send;

  /// No description provided for @editimage.
  ///
  /// In en, this message translates to:
  /// **'Edit image'**
  String get editimage;

  /// No description provided for @alluser.
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get alluser;

  /// No description provided for @friendreq.
  ///
  /// In en, this message translates to:
  /// **'friend Request'**
  String get friendreq;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'friends'**
  String get friends;

  /// No description provided for @addfriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get addfriend;

  /// No description provided for @nofriendreq.
  ///
  /// In en, this message translates to:
  /// **'No friend request'**
  String get nofriendreq;

  /// No description provided for @friend.
  ///
  /// In en, this message translates to:
  /// **'friend'**
  String get friend;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'message'**
  String get message;

  /// No description provided for @about_me.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get about_me;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'search'**
  String get search;

  /// No description provided for @editpost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editpost;

  /// No description provided for @selectimage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectimage;

  /// No description provided for @savechange.
  ///
  /// In en, this message translates to:
  /// **'save Changes'**
  String get savechange;

  /// No description provided for @years_ago.
  ///
  /// In en, this message translates to:
  /// **'year(s) ago'**
  String get years_ago;

  /// No description provided for @month_age.
  ///
  /// In en, this message translates to:
  /// **'Month(s) ago'**
  String get month_age;

  /// No description provided for @weeks_ago.
  ///
  /// In en, this message translates to:
  /// **'Weeks(s) ago'**
  String get weeks_ago;

  /// No description provided for @day_ago.
  ///
  /// In en, this message translates to:
  /// **'Day(s) ago'**
  String get day_ago;

  /// No description provided for @few_sec.
  ///
  /// In en, this message translates to:
  /// **'A few seconds ago'**
  String get few_sec;

  /// No description provided for @hour_ago.
  ///
  /// In en, this message translates to:
  /// **'Hour(s) ago'**
  String get hour_ago;

  /// No description provided for @min_ago.
  ///
  /// In en, this message translates to:
  /// **'minute(s) ago'**
  String get min_ago;

  /// No description provided for @just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get just_now;

  /// No description provided for @addcomment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get addcomment;

  /// No description provided for @delete_post.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get delete_post;

  /// No description provided for @noinfo.
  ///
  /// In en, this message translates to:
  /// **'No information provided'**
  String get noinfo;

  /// No description provided for @nofriend.
  ///
  /// In en, this message translates to:
  /// **'No Friend yet'**
  String get nofriend;

  /// No description provided for @nouser.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get nouser;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @postsuccess.
  ///
  /// In en, this message translates to:
  /// **'Your post has been successfully posted.'**
  String get postsuccess;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading Image...'**
  String get uploading;

  /// No description provided for @nomessege.
  ///
  /// In en, this message translates to:
  /// **'No messege yet'**
  String get nomessege;

  /// No description provided for @profileupdatesuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated successfully'**
  String get profileupdatesuccess;

  /// No description provided for @changeprofilepic.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get changeprofilepic;

  /// No description provided for @uploadprofilepic.
  ///
  /// In en, this message translates to:
  /// **'Upload Profile Picture'**
  String get uploadprofilepic;

  /// No description provided for @copysucces.
  ///
  /// In en, this message translates to:
  /// **'Text copied to clipboard'**
  String get copysucces;

  /// No description provided for @pic.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get pic;

  /// No description provided for @deletemessege.
  ///
  /// In en, this message translates to:
  /// **'Delete Message?'**
  String get deletemessege;

  /// No description provided for @confirmdelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get confirmdelete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cannotdeletemessege.
  ///
  /// In en, this message translates to:
  /// **'Cannot Delete Message'**
  String get cannotdeletemessege;

  /// No description provided for @deleteyourmessege.
  ///
  /// In en, this message translates to:
  /// **'You can only delete messages sent by you.'**
  String get deleteyourmessege;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get save;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'select language'**
  String get select_language;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'request sent'**
  String get pending;

  /// No description provided for @deletepost.
  ///
  /// In en, this message translates to:
  /// **'are you sure you want to delete the post?'**
  String get deletepost;

  /// No description provided for @deletesure.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get deletesure;

  /// No description provided for @afterdelete.
  ///
  /// In en, this message translates to:
  /// **'you deleted the post successfully 😊'**
  String get afterdelete;

  /// No description provided for @removefriend.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removefriend;

  /// No description provided for @deleteusersure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this friend?'**
  String get deleteusersure;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
