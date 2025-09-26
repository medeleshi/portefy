import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../models/post_model.dart';
import 'package:portefy/app/services/post_service.dart';

class ShareService {
  final PostService _postService = PostService();

  /// مشاركة البوست كرابط + صورة (إن وجدت)
  Future<void> sharePost(PostModel post) async {
    final String postUrl = "https://portefy.com/posts/${post.id}";

    String shareText =
        '''
${post.authorName} ✨
${post.content}

📅 ${post.timeAgo}
🔗 $postUrl
''';

    if (post.hasImages && post.imageUrls.isNotEmpty) {
      try {
        final url = post.imageUrls.first; // ناخذ أول صورة فقط
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/shared_post.jpg');
          await file.writeAsBytes(response.bodyBytes);

          await Share.shareXFiles(
            [XFile(file.path)],
            text: shareText,
            subject: 'منشور مثير للاهتمام',
          );

          await _postService.incrementSharesCount(post.id);
          return;
        }
      } catch (e) {
        print("❌ فشل تحميل الصورة: $e");
      }
    }

    // إذا ما فيهاش صورة أو فشلت التحميل → مشاركة نص فقط مع الرابط
    await Share.share(shareText, subject: 'منشور مثير للاهتمام');

    await _postService.incrementSharesCount(post.id);
  }
}
