import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmo/lang/app_local.dart';

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
