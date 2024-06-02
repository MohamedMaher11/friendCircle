import 'dart:ui';

import 'package:flutter/material.dart';

void showFullScreenImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(0),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Stack(
            children: [
              // Blur background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // Fullscreen image
              Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.network(imageUrl),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
