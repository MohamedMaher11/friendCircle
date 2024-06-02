import 'package:share/share.dart';

void sharePost(String postId, String postTitle, String postImageUrl) {
  String text = postTitle;
  if (postImageUrl.isNotEmpty) {
    text += '\n$postImageUrl';
  }
  Share.share(text);
}
