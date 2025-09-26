// Enum لأسباب الإبلاغ
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportReason {
  spam,
  hateSpeech,
  violence,
  nudity,
  falseInformation,
  harassment,
  other,
}

class PostReportModel {
  final String id;
  final String postId;
  final String reporterId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostReportModel({
    required this.id,
    required this.postId,
    required this.reporterId,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostReportModel.fromMap(Map<String, dynamic> map) {
    return PostReportModel(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reason: _parseReason(map['reason']),
      description: map['description'],
      status: _parseStatus(map['status']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  static ReportReason _parseReason(String reason) {
    switch (reason) {
      case 'spam': return ReportReason.spam;
      case 'hateSpeech': return ReportReason.hateSpeech;
      case 'violence': return ReportReason.violence;
      case 'nudity': return ReportReason.nudity;
      case 'falseInformation': return ReportReason.falseInformation;
      case 'harassment': return ReportReason.harassment;
      case 'other': return ReportReason.other;
      default: return ReportReason.other;
    }
  }

  static ReportStatus _parseStatus(String status) {
    switch (status) {
      case 'pending': return ReportStatus.pending;
      case 'reviewed': return ReportStatus.reviewed;
      case 'resolved': return ReportStatus.resolved;
      default: return ReportStatus.pending;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason.toString().split('.').last,
      'description': description,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

enum ReportStatus {
  pending,
  reviewed,
  resolved,
}