class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String? parentCommentId; // For replies
  final List<String> likedBy;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.parentCommentId,
    this.likedBy = const [],
    this.repliesCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorAvatar: map['authorAvatar'],
      content: map['content'] ?? '',
      parentCommentId: map['parentCommentId'],
      likedBy: List<String>.from(map['likedBy'] ?? []),
      repliesCount: map['repliesCount'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      isEdited: map['isEdited'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'parentCommentId': parentCommentId,
      'likedBy': likedBy,
      'repliesCount': repliesCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isEdited': isEdited,
    };
  }

  CommentModel copyWith({
    String? content,
    List<String>? likedBy,
    int? repliesCount,
    DateTime? updatedAt,
    bool? isEdited,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      userId: userId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      content: content ?? this.content,
      parentCommentId: parentCommentId,
      likedBy: likedBy ?? this.likedBy,
      repliesCount: repliesCount ?? this.repliesCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isEdited: isEdited ?? this.isEdited,
    );
  }

  bool get isReply => parentCommentId != null;
  bool isLikedBy(String userId) => likedBy.contains(userId);
  int get likesCount => likedBy.length;
}
