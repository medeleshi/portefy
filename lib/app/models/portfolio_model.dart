import 'package:cloud_firestore/cloud_firestore.dart';

// Base Portfolio Item
abstract class PortfolioItem {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PortfolioItem({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap();
}

// Education Model
class EducationModel extends PortfolioItem {
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final double? gpa;
  final String? description;
  final List<String>? achievements;

  EducationModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.gpa,
    this.description,
    this.achievements,
  }) : super(id: id, userId: userId, createdAt: createdAt, updatedAt: updatedAt);

  factory EducationModel.fromMap(Map<String, dynamic> map, String id) {
    return EducationModel(
      id: id,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      institution: map['institution'] ?? '',
      degree: map['degree'] ?? '',
      fieldOfStudy: map['fieldOfStudy'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      isCurrent: map['isCurrent'] ?? false,
      gpa: map['gpa']?.toDouble(),
      description: map['description'],
      achievements: map['achievements'] != null ? List<String>.from(map['achievements']) : [],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'institution': institution,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isCurrent': isCurrent,
      'gpa': gpa,
      'description': description,
      'achievements': achievements,
    };
  }
}

// Experience Model
class ExperienceModel extends PortfolioItem {
  final String company;
  final String position;
  final String? location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? description;
  final List<String>? responsibilities;
  final List<String>? achievements;

  ExperienceModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.company,
    required this.position,
    this.location,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
    this.responsibilities,
    this.achievements,
  }) : super(id: id, userId: userId, createdAt: createdAt, updatedAt: updatedAt);

  factory ExperienceModel.fromMap(Map<String, dynamic> map, String id) {
    return ExperienceModel(
      id: id,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      company: map['company'] ?? '',
      position: map['position'] ?? '',
      location: map['location'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      isCurrent: map['isCurrent'] ?? false,
      description: map['description'],
      responsibilities: map['responsibilities'] != null ? List<String>.from(map['responsibilities']) : [],
      achievements: map['achievements'] != null ? List<String>.from(map['achievements']) : [],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'company': company,
      'position': position,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isCurrent': isCurrent,
      'description': description,
      'responsibilities': responsibilities,
      'achievements': achievements,
    };
  }
}

// Project Model
class ProjectModel extends PortfolioItem {
  final String title;
  final String description;
  final List<String> technologies;
  final String? githubUrl;
  final String? demoUrl;
  final List<String> imageUrls;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCompleted;
  final List<String>? features;

  ProjectModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.title,
    required this.description,
    this.technologies = const [],
    this.githubUrl,
    this.demoUrl,
    this.imageUrls = const [],
    this.startDate,
    this.endDate,
    this.isCompleted = false,
    this.features,
  }) : super(id: id, userId: userId, createdAt: createdAt, updatedAt: updatedAt);

  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectModel(
      id: id,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      technologies: map['technologies'] != null ? List<String>.from(map['technologies']) : [],
      githubUrl: map['githubUrl'],
      demoUrl: map['demoUrl'],
      imageUrls: map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : [],
      startDate: map['startDate'] != null ? (map['startDate'] as Timestamp).toDate() : null,
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      isCompleted: map['isCompleted'] ?? false,
      features: map['features'] != null ? List<String>.from(map['features']) : [],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'title': title,
      'description': description,
      'technologies': technologies,
      'githubUrl': githubUrl,
      'demoUrl': demoUrl,
      'imageUrls': imageUrls,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isCompleted': isCompleted,
      'features': features,
    };
  }
}

// Skill Model
class SkillModel extends PortfolioItem {
  final String name;
  final String category; // Technical, Soft, Language
  final int level; // 1-5
  final String? description;
  final List<String>? certifications;

  SkillModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.name,
    required this.category,
    required this.level,
    this.description,
    this.certifications,
  }) : super(id: id, userId: userId, createdAt: createdAt, updatedAt: updatedAt);

  factory SkillModel.fromMap(Map<String, dynamic> map, String id) {
    return SkillModel(
      id: id,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      name: map['name'] ?? '',
      category: map['category'] ?? 'Technical',
      level: map['level'] ?? 1,
      description: map['description'],
      certifications: map['certifications'] != null ? List<String>.from(map['certifications']) : [],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'name': name,
      'category': category,
      'level': level,
      'description': description,
      'certifications': certifications,
    };
  }
}

// Language Model
class LanguageModel extends PortfolioItem {
  final String name;
  final String proficiency; // Native, Fluent, Conversational, Basic
  final List<String>? certifications;

  LanguageModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.name,
    required this.proficiency,
    this.certifications,
  }) : super(id: id, userId: userId, createdAt: createdAt, updatedAt: updatedAt);

  factory LanguageModel.fromMap(Map<String, dynamic> map, String id) {
    return LanguageModel(
      id: id,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      name: map['name'] ?? '',
      proficiency: map['proficiency'] ?? 'Basic',
      certifications: map['certifications'] != null ? List<String>.from(map['certifications']) : [],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'name': name,
      'proficiency': proficiency,
      'certifications': certifications,
    };
  }
}

// Activity Model
class ActivityModel extends PortfolioItem {
  final String title;
  final String organization;
  final String type; // Volunteer, Club, Sports, Community Service, etc.
  final String? role;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? description;
  final List<String>? achievements;
  final List<String>? skills;

  ActivityModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.title,
    required this.organization,
    required this.type,
    this.role,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
    this.achievements,
    this.skills,
  }) : super(id: id, userId: userId, createdAt: createdAt, updatedAt: updatedAt);

  factory ActivityModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      title: map['title'] ?? '',
      organization: map['organization'] ?? '',
      type: map['type'] ?? 'Volunteer',
      role: map['role'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      isCurrent: map['isCurrent'] ?? false,
      description: map['description'],
      achievements: map['achievements'] != null ? List<String>.from(map['achievements']) : [],
      skills: map['skills'] != null ? List<String>.from(map['skills']) : [],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'title': title,
      'organization': organization,
      'type': type,
      'role': role,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isCurrent': isCurrent,
      'description': description,
      'achievements': achievements,
      'skills': skills,
    };
  }
}

// Certificate Model
class CertificateModel extends PortfolioItem {
  final String name;
  final String issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? description;
  final List<String>? skills;
  final bool isVerified;

  CertificateModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.name,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.description,
    this.skills,
    this.isVerified = false,
  }) : super(id: id, userId: userId, createdAt: createdAt, updatedAt: updatedAt);

  factory CertificateModel.fromMap(Map<String, dynamic> map, String id) {
    return CertificateModel(
      id: id,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      name: map['name'] ?? '',
      issuer: map['issuer'] ?? '',
      issueDate: (map['issueDate'] as Timestamp).toDate(),
      expiryDate: map['expiryDate'] != null ? (map['expiryDate'] as Timestamp).toDate() : null,
      credentialId: map['credentialId'],
      credentialUrl: map['credentialUrl'],
      description: map['description'],
      skills: map['skills'] != null ? List<String>.from(map['skills']) : [],
      isVerified: map['isVerified'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'name': name,
      'issuer': issuer,
      'issueDate': Timestamp.fromDate(issueDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
      'description': description,
      'skills': skills,
      'isVerified': isVerified,
    };
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(Duration(days: 30));
    return expiryDate!.isBefore(thirtyDaysFromNow) && expiryDate!.isAfter(now);
  }
}

// Hobby Model
class HobbyModel extends PortfolioItem {
  final String name;
  final String? description;
  final String category; // Sports, Arts, Music, Reading, etc.
  final int proficiency; // 1-5
  final DateTime? startedDate;

  HobbyModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.name,
    this.description,
    this.category = 'Other',
    this.proficiency = 1,
    this.startedDate,
  }) : super(id: id, userId: userId, createdAt: createdAt, updatedAt: updatedAt);

  factory HobbyModel.fromMap(Map<String, dynamic> map, String id) {
    return HobbyModel(
      id: id,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'] ?? 'Other',
      proficiency: map['proficiency'] ?? 1,
      startedDate: map['startedDate'] != null ? (map['startedDate'] as Timestamp).toDate() : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'name': name,
      'description': description,
      'category': category,
      'proficiency': proficiency,
      'startedDate': startedDate != null ? Timestamp.fromDate(startedDate!) : null,
    };
  }
}

// Portfolio Summary Model
class PortfolioSummary {
  final int educationCount;
  final int experienceCount;
  final int projectsCount;
  final int skillsCount;
  final int languagesCount;
  final int activitiesCount;
  final int certificatesCount;
  final int hobbiesCount;
  final DateTime lastUpdated;

  PortfolioSummary({
    required this.educationCount,
    required this.experienceCount,
    required this.projectsCount,
    required this.skillsCount,
    required this.languagesCount,
    required this.activitiesCount,
    required this.certificatesCount,
    required this.hobbiesCount,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'educationCount': educationCount,
      'experienceCount': experienceCount,
      'projectsCount': projectsCount,
      'skillsCount': skillsCount,
      'languagesCount': languagesCount,
      'activitiesCount': activitiesCount,
      'certificatesCount': certificatesCount,
      'hobbiesCount': hobbiesCount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory PortfolioSummary.fromMap(Map<String, dynamic> map) {
    return PortfolioSummary(
      educationCount: map['educationCount'] ?? 0,
      experienceCount: map['experienceCount'] ?? 0,
      projectsCount: map['projectsCount'] ?? 0,
      skillsCount: map['skillsCount'] ?? 0,
      languagesCount: map['languagesCount'] ?? 0,
      activitiesCount: map['activitiesCount'] ?? 0,
      certificatesCount: map['certificatesCount'] ?? 0,
      hobbiesCount: map['hobbiesCount'] ?? 0,
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }

  int get totalItems {
    return educationCount +
        experienceCount +
        projectsCount +
        skillsCount +
        languagesCount +
        activitiesCount +
        certificatesCount +
        hobbiesCount;
  }
}

// Enum for Portfolio Item Types
enum PortfolioItemType {
  education,
  experience,
  project,
  skill,
  language,
  activity,
  certificate,
  hobby
}

// Helper class for portfolio operations
class PortfolioHelper {
  static String getCollectionName(PortfolioItemType type) {
    switch (type) {
      case PortfolioItemType.education:
        return 'education';
      case PortfolioItemType.experience:
        return 'experience';
      case PortfolioItemType.project:
        return 'projects';
      case PortfolioItemType.skill:
        return 'skills';
      case PortfolioItemType.language:
        return 'languages';
      case PortfolioItemType.activity:
        return 'activities';
      case PortfolioItemType.certificate:
        return 'certificates';
      case PortfolioItemType.hobby:
        return 'hobbies';
    }
  }

  static PortfolioItemType getTypeFromString(String type) {
    switch (type) {
      case 'education':
        return PortfolioItemType.education;
      case 'experience':
        return PortfolioItemType.experience;
      case 'project':
        return PortfolioItemType.project;
      case 'skill':
        return PortfolioItemType.skill;
      case 'language':
        return PortfolioItemType.language;
      case 'activity':
        return PortfolioItemType.activity;
      case 'certificate':
        return PortfolioItemType.certificate;
      case 'hobby':
        return PortfolioItemType.hobby;
      default:
        return PortfolioItemType.education;
    }
  }

  static String getTypeDisplayName(PortfolioItemType type) {
    switch (type) {
      case PortfolioItemType.education:
        return 'التعليم';
      case PortfolioItemType.experience:
        return 'الخبرة العملية';
      case PortfolioItemType.project:
        return 'المشاريع';
      case PortfolioItemType.skill:
        return 'المهارات';
      case PortfolioItemType.language:
        return 'اللغات';
      case PortfolioItemType.activity:
        return 'الأنشطة';
      case PortfolioItemType.certificate:
        return 'الشهادات';
      case PortfolioItemType.hobby:
        return 'الهوايات';
    }
  }
}