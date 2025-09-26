enum NotificationType {
  newPost,
  postLike,
  postComment,
  commentLike,
  commentReply,
  follow,
  mention,
}

class NotificationModel {
  final String id;
  final String userId; // Receiver
  final String? senderId; // Sender
  final String? senderName;
  final String? senderAvatar;
  final NotificationType type;
  final String title;
  final String body;
  final String? postId;
  final String? commentId;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.type,
    required this.title,
    required this.body,
    this.postId,
    this.commentId,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      senderId: map['senderId'],
      senderName: map['senderName'],
      senderAvatar: map['senderAvatar'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => NotificationType.newPost,
      ),
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      postId: map['postId'],
      commentId: map['commentId'],
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'postId': postId,
      'commentId': commentId,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      type: type,
      title: title,
      body: body,
      postId: postId,
      commentId: commentId,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.newPost:
        return 'منشور جديد';
      case NotificationType.postLike:
        return 'إعجاب بالمنشور';
      case NotificationType.postComment:
        return 'تعليق على المنشور';
      case NotificationType.commentLike:
        return 'إعجاب بالتعليق';
      case NotificationType.commentReply:
        return 'رد على التعليق';
      case NotificationType.follow:
        return 'متابع جديد';
      case NotificationType.mention:
        return 'ذكر في المنشور';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}