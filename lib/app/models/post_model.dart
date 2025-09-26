import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatar;
  final String? authorUniversity;
  final String? authorMajor;
  final String? authorLevel;
  final String content;
  final List<String> imageUrls;
  final List<String> tags;
  final List<String> likedBy;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;

  // Enhanced fields for better functionality
  final int viewsCount;
  final int reportsCount;

  // CRITICAL: DocumentSnapshot for proper pagination
  final DocumentSnapshot? documentSnapshot;

  // Audience targeting fields
  final String? audience;

  // Status field for soft delete and moderation
  final String status; // active, deleted, hidden, pending

  PostModel({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatar,
    this.authorUniversity,
    this.authorMajor,
    this.authorLevel,
    required this.content,
    this.imageUrls = const [],
    this.tags = const [],
    this.likedBy = const [],
    this.commentsCount = 0,
    this.sharesCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
    this.viewsCount = 0,
    this.reportsCount = 0,
    this.documentSnapshot, // Store for pagination
    this.audience,
    this.status = 'active',
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      userId: map['userId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorAvatar: map['authorAvatar'],
      authorUniversity: map['authorUniversity'],
      authorMajor: map['authorMajor'],
      authorLevel: map['authorLevel'],
      content: map['content'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      likedBy: List<String>.from(map['likedBy'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
      sharesCount: map['sharesCount'] ?? 0,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
      isEdited: map['isEdited'] ?? false,
      viewsCount: map['viewsCount'] ?? 0,
      reportsCount: map['reportsCount'] ?? 0,
      audience: map['audience'],
      status: map['status'] ?? 'active',
      // Note: documentSnapshot will be set separately after creation
    );
  }

  // Helper method to parse Firestore timestamps safely
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'authorUniversity': authorUniversity,
      'authorMajor': authorMajor,
      'authorLevel': authorLevel,
      'content': content,
      'imageUrls': imageUrls,
      'tags': tags,
      'likedBy': likedBy,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isEdited': isEdited,
      'viewsCount': viewsCount,
      'reportsCount': reportsCount,
      'audience': audience,
      'status': status,
      // Note: documentSnapshot is not serialized
    };
  }

  PostModel copyWith({
    String? content,
    List<String>? imageUrls,
    List<String>? tags,
    List<String>? likedBy,
    int? commentsCount,
    int? sharesCount,
    DateTime? updatedAt,
    bool? isEdited,
    int? viewsCount,
    int? reportsCount,
    DocumentSnapshot? documentSnapshot,
    String? audience,
    String? audienceUniversity,
    String? audienceMajor,
    String? audienceLevel,
    String? status,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorUniversity: authorUniversity,
      authorMajor: authorMajor,
      authorLevel: authorLevel,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      likedBy: likedBy ?? this.likedBy,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isEdited: isEdited ?? this.isEdited,
      viewsCount: viewsCount ?? this.viewsCount,
      reportsCount: reportsCount ?? this.reportsCount,
      documentSnapshot: documentSnapshot ?? this.documentSnapshot,
      audience: audience ?? this.audience,
      status: status ?? this.status,
    );
  }

  // Getter methods
  bool get isActive => status == 'active';
  bool get isDeleted => status == 'deleted';
  int get likesCount => likedBy.length;

  // Check if the current user liked this post
  bool isLikedByUser(String? currentUserId) {
    if (currentUserId == null) return false;
    return likedBy.contains(currentUserId);
  }

  // Get engagement score (for trending/ranking)
  int get engagementScore =>
      likesCount + commentsCount + sharesCount + (viewsCount ~/ 10);

  // Check if post has any media
  bool get hasImages => imageUrls.isNotEmpty;

  // Check if post has tags
  bool get hasTags => tags.isNotEmpty;

  // Get formatted creation time
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  // Helper method to check if post is visible to a specific user

  // Check if user can edit this post
  bool canBeEditedBy(String? currentUserId) {
    if (currentUserId == null || !isActive) return false;
    return userId == currentUserId;
  }

  // Check if user can delete this post
  bool canBeDeletedBy(String? currentUserId) {
    if (currentUserId == null || !isActive) return false;
    return userId == currentUserId;
  }

  // Check if post can be reported by user
  bool canBeReportedBy(String? currentUserId) {
    if (currentUserId == null || !isActive) return false;
    return userId != currentUserId; // Users can't report their own posts
  }

  // Get post summary for notifications
  String get contentSummary {
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  // Check if post is recent (less than 24 hours old)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  // Check if post is trending (high engagement in recent time)
  bool get isTrending {
    return isRecent && engagementScore > 10; // Configurable threshold
  }

  // Get author display name with level if available
  String get authorDisplayName {
    if (authorLevel != null && authorLevel!.isNotEmpty) {
      return authorName;
    }
    return authorName;
  }

  // Get author info text
  String get authorInfoText {
    if (audience == 'university' && authorUniversity!.isNotEmpty) {
      return authorUniversity!;
    }

    if (audience == 'major' && authorMajor!.isNotEmpty) {
      return authorMajor!;
    }

    if (audience == 'level' && authorLevel!.isNotEmpty) {
      return authorLevel!;
    }

    return 'Public';
  }

  // Convert to JSON string for debugging
  @override
  String toString() {
    return 'PostModel{id: $id, authorName: $authorName, status: $status, content: ${content.substring(0, content.length > 30 ? 30 : content.length)}..., likesCount: $likesCount, commentsCount: $commentsCount}';
  }

  // Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel && other.id == id;
  }

  // Hash code
  @override
  int get hashCode => id.hashCode;
}
