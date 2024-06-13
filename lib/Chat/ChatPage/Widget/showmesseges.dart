import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:socialmo/Chat/ChatPage/Widget/showfullscreen.dart';
import 'dart:async';

import 'package:socialmo/lang/app_local.dart';

class MessageWidget extends StatefulWidget {
  final String? message;
  final bool isSender;
  final String? image;
  final String? audio;
  final Timestamp timestamp;

  const MessageWidget({
    required this.isSender,
    required this.timestamp,
    required this.image,
    required this.message,
    required this.audio,
    Key? key,
  }) : super(key: key);

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  bool _isPlaying = false;
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  static FlutterSoundPlayer? _currentlyPlayingPlayer;
  static _MessageWidgetState? _currentlyPlayingState;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _positionSubscription;
  ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _player.openPlayer().then((value) {
      print("Player opened");
    });
  }

  double _getLinearProgressIndicatorValue() {
    if (_duration.inMilliseconds == 0) {
      return 0;
    } else {
      return _position.inMilliseconds / _duration.inMilliseconds;
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _progressNotifier.dispose();
    _player.closePlayer();
    super.dispose();
  }

  void _updateProgress() {
    _positionSubscription?.cancel();
    _positionSubscription = _player.onProgress!.listen((e) {
      if (mounted) {
        setState(() {
          _position = e.position;
          _duration = e.duration;
          _progressNotifier.value =
              _position.inMilliseconds / _duration.inMilliseconds;
        });
      }
    });
  }

  Future<void> _playPauseAudio() async {
    if (_currentlyPlayingPlayer != null && _currentlyPlayingPlayer != _player) {
      await _currentlyPlayingPlayer!.stopPlayer();
      _currentlyPlayingState?._resetAudio();
      _updateProgress();
    }

    if (_player.isPaused) {
      await _player.resumePlayer();
      _startPositionUpdates();
      setState(() {
        _isPlaying = true;
      });
    } else if (_player.isPlaying) {
      await _player.pausePlayer();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_currentlyPlayingPlayer != null) {
        await _currentlyPlayingPlayer!.stopPlayer();
        _currentlyPlayingState?._resetAudio();
      }
      _currentlyPlayingPlayer = _player;
      _currentlyPlayingState = this;
      await _player.startPlayer(
        fromURI: widget.audio,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
            _currentlyPlayingPlayer = null;
            _currentlyPlayingState = null;
          });
        },
      );
      _startPositionUpdates();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _startPositionUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = _player.onProgress!.listen((e) {
      if (mounted) {
        setState(() {
          _position = e.position;
          _duration = e.duration;
          print("Position: $_position, Duration: $_duration");
        });
      }
    });
  }

  void _resetAudio() {
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 4.0, horizontal: 8.0), // تقليل التباعد هنا
      child: Align(
        alignment:
            widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 8, vertical: 8), // تقليل padding هنا
          decoration: BoxDecoration(
            color: widget.isSender
                ? Color.fromRGBO(2, 94, 84, 1)
                : Color.fromRGBO(78, 40, 100, 1),
            borderRadius:
                BorderRadius.all(Radius.circular(12)), // تقليل نصف القطر هنا
          ),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width *
                  0.65), // تقليل عرض الإطار هنا
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.image != null)
                GestureDetector(
                  onTap: () {
                    showFullScreenImage(context, widget.image!);
                  },
                  child: Image.network(
                    widget.image!,
                    width: 120.w, // تقليل العرض هنا
                    height: 120.h, // تقليل الارتفاع هنا
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
              if (widget.message != null)
                Padding(
                  padding: EdgeInsets.only(top: widget.image != null ? 6 : 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      widget.message!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp, // تقليل حجم الخط هنا
                      ),
                    ),
                  ),
                ),
              if (widget.audio != null)
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _playPauseAudio,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isPlaying
                                      ? AppLocal.loc.pause
                                      : AppLocal.loc.play,
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 10,
                                    child: LinearProgressIndicator(
                                      value: 1, // percent filled
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          _isPlaying
                                              ? Colors.green
                                              : Colors.grey),
                                      backgroundColor: Color(0xFFFFDAB8),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  formatTimestamp(context),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp, // تقليل حجم الخط هنا
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
    final date = dateFormat.format(widget.timestamp.toDate());
    final time = timeFormat.format(widget.timestamp.toDate());
    return '$date $time';
  }
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}
