import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:socialmo/Chat/ChatPage/Widget/showfullscreen.dart';

class MessageWidget extends StatelessWidget {
  final String? message;
  final bool isSender;
  final String? image;
  final Timestamp timestamp;

  const MessageWidget({
    required this.isSender,
    required this.timestamp,
    required this.image,
    required this.message,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSender
                ? Color.fromRGBO(2, 94, 84, 1) // Purple
                : Color.fromRGBO(
                    78, 40, 100, 1), // ألوان جديدة للمرسل والمستقبل
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image != null)
                GestureDetector(
                  onTap: () {
                    showFullScreenImage(context, image!);
                  },
                  child: Image.network(
                    image!,
                    width: 150.w,
                    height: 150.h,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error),
                  ),
                ),
              if (message != null)
                Padding(
                  padding: EdgeInsets.only(top: image != null ? 6 : 0),
                  child: Text(
                    message!,
                    style: TextStyle(
                      color: isSender ? Colors.white : Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  formatTimestamp(context),
                  style: TextStyle(
                    color: isSender ? Colors.white : Colors.white,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatTimestamp(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMd(locale.languageCode);
    final timeFormat = DateFormat.jm(locale.languageCode);
    final date = dateFormat.format(timestamp.toDate());
    final time = timeFormat.format(timestamp.toDate());
    return '$date $time';
  }
}
