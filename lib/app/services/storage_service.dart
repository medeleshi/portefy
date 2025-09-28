import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';

class StorageService extends GetxService {
  final _httpClient = HttpClient();

    // Replace with your actual Cloudinary credentials
    final String apiKey = '691962245195932';
    final String apiSecret = 'x9d-8s1pRnz1Y0gRS1HN9Jar_PU';
    final String cloudName = 'dsgp6dibw';

  // Generate signature for Cloudinary API
  String _generateSignature(Map<String, dynamic> params) {
    final sortedParams = <String>[];
    
    params.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        sortedParams.add('$key=$value');
      }
    });
    
    sortedParams.sort();
    final paramString = sortedParams.join('&');
    final stringToSign = '$paramString$apiSecret';
    
    var bytes = utf8.encode(stringToSign);
    var digest = sha1.convert(bytes);
    return digest.toString();
  }

  // Upload post image
  Future<String> uploadPostImage(File imageFile) async {
    try {
      // Compress image before upload
      final compressedFile = await compressImage(imageFile);

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final params = {
        'folder': 'posts',
        'timestamp': timestamp.toString(),
      };
      
      final signature = _generateSignature(params);
      
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // Add parameters
      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['folder'] = 'posts';
      
      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        compressedFile.path,
      );
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['secure_url'];
      } else {
        throw 'HTTP ${response.statusCode}: $responseBody';
      }
    } catch (e) {
      throw 'فشل رفع الصورة: ${e.toString()}';
    }
  }


  // Compress image before upload
  Future<File> compressImage(File imageFile, {int quality = 80, int maxWidth = 1080}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return imageFile;

      // Resize if needed
      final resized = img.copyResize(image, width: maxWidth);

      // Encode to JPEG with quality
      final compressedBytes = img.encodeJpg(resized, quality: quality);

      // Save to temp file
      final tempDir = path.dirname(imageFile.path);
      final compressedPath = path.join(tempDir, 'compressed_${path.basename(imageFile.path)}');
      final compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return imageFile;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw 'الملف غير موجود';
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final fileName = 'profile_${userId}_$timestamp';
      final params = {
        'folder': 'profile_images',
        'public_id': fileName,
        'timestamp': timestamp.toString(),
      };
      
      final signature = _generateSignature(params);
      
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // Add parameters
      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['folder'] = 'profile_images';
      request.fields['public_id'] = fileName;
      
      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['secure_url'];
      } else {
        throw 'HTTP ${response.statusCode}: $responseBody';
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      // Re-throw with user-friendly message
      if (e.toString().contains('network') || e.toString().contains('SocketException')) {
        throw 'تحقق من اتصال الإنترنت';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        throw 'ليس لديك صلاحية لرفع الصور';
      } else {
        throw 'فشل في رفع الصورة: ${e.toString()}';
      }
    }
  }

  // Upload portfolio document/image
  Future<String> uploadPortfolioFile(File file, String userId, String category) async {
    try {
      // Determine resource type based on file extension
      final extension = path.extension(file.path).toLowerCase();
      final isImage = ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension);
      
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final params = {
        'folder': 'portfolio/$userId/$category',
        'timestamp': timestamp.toString(),
      };
      
      final signature = _generateSignature(params);
      
      // Use appropriate endpoint based on file type
      final endpoint = isImage ? 'image' : 'raw';
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$endpoint/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // Add parameters
      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['folder'] = 'portfolio/$userId/$category';
      
      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
      );
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['secure_url'];
      } else {
        throw 'HTTP ${response.statusCode}: $responseBody';
      }
    } catch (e) {
      throw 'فشل رفع ملف الملف الشخصي: ${e.toString()}';
    }
  }

  // Extract public ID from Cloudinary URL
  String _extractPublicId(String fileUrl) {
    try {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the index where the version segment starts (v1234567890)
      final versionIndex = pathSegments.indexWhere((segment) => segment.startsWith('v'));
      if (versionIndex == -1 || versionIndex >= pathSegments.length - 1) {
        throw 'تعذر استخراج publicId من الرابط';
      }
      
      // The public ID is everything after the version, joined by '/'
      final publicIdParts = pathSegments.sublist(versionIndex + 1);
      
      // Remove the file extension from the last part
      if (publicIdParts.isNotEmpty) {
        final lastPart = publicIdParts.last;
        final lastDotIndex = lastPart.lastIndexOf('.');
        if (lastDotIndex != -1) {
          publicIdParts[publicIdParts.length - 1] = lastPart.substring(0, lastDotIndex);
        }
      }
      
      return publicIdParts.join('/');
    } catch (e) {
      print('Error extracting public ID: $e');
      throw 'تعذر استخراج publicId من الرابط';
    }
  }

  // Delete file from Cloudinary using HTTP
  Future<void> deleteFile(String fileUrl) async {
    try {
      final publicId = _extractPublicId(fileUrl);
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Determine resource type
      final resourceType = fileUrl.contains('/image/upload/') ? 'image' : 'raw';
      
      final params = {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      };
      
      final signature = _generateSignature(params);
      
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/destroy');
      
      final response = await http.post(
        uri,
        body: {
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
          'public_id': publicId,
          'invalidate': 'true',
        },
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['result'] == 'ok') {
          print('تم حذف الملف بنجاح: $publicId');
        } else {
          throw 'فشل في حذف الملف: ${jsonResponse['result']}';
        }
      } else {
        throw 'HTTP ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      print('فشل حذف الملف: ${e.toString()}');
      rethrow;
    }
  }

  // Get file size from Cloudinary
  Future<int> getFileSize(String fileUrl) async {
    try {
      final request = await _httpClient.headUrl(Uri.parse(fileUrl));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final contentLength = response.headers.value(HttpHeaders.contentLengthHeader);
        return contentLength != null ? int.parse(contentLength) : 0;
      }
      
      return 0;
    } catch (e) {
      print('فشل في الحصول على حجم الملف: $e');
      return 0;
    }
  }

  // دالة مساعدة لتحميل عدة صور مرة واحدة
  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    final List<String> imageUrls = [];
    
    for (final imageFile in imageFiles) {
      try {
        final imageUrl = await uploadPostImage(imageFile);
        imageUrls.add(imageUrl);
      } catch (e) {
        print('فشل تحميل صورة: $e');
        throw 'فشل تحميل إحدى الصور: $e';
      }
    }
    
    return imageUrls;
  }

  // دالة لتحويل الصورة إلى رابط محسن
  String getOptimizedImageUrl(String originalUrl, {int width = 800, int height = 600}) {
    try {
      // إنشاء رابط مع تحويلات باستخدام بناء جملة Cloudinary
      final optimizedUrl = originalUrl.replaceFirst(
        '/image/upload/', 
        '/image/upload/w_$width,h_$height,c_fill,q_auto/'
      );
      
      return optimizedUrl;
    } catch (e) {
      // في حالة الفشل، ارجع الرابط الأصلي
      return originalUrl;
    }
  }

  @override
  void onClose() {
    _httpClient.close();
    super.onClose();
  }
}