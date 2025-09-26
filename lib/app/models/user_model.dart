class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? university;
  final String? major;
  final String? level;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? city;
  final String? country;
  final List<String>? interests;
  final int? points;
  final List? fcmTokens;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isProfileComplete;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.firstName,
    this.lastName,
    this.phone,
    this.university,
    this.major,
    this.level,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.country,
    this.interests,
    this.points = 0,
    this.fcmTokens,
    required this.createdAt,
    required this.updatedAt,
    this.isProfileComplete = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      university: map['university'],
      major: map['major'],
      level: map['level'],
      bio: map['bio'],
      dateOfBirth: map['dateOfBirth']?.toDate(),
      gender: map['gender'],
      city: map['city'],
      country: map['country'],
      interests: List<String>.from(map['interests'] ?? []),
      points: map['points'] ?? 0,
      fcmTokens: map['fcmTokens'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      isProfileComplete: map['isProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'university': university,
      'major': major,
      'level': level,
      'bio': bio,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'city': city,
      'country': country,
      'interests': interests,
      'points': points,
      'fcmTokens': fcmTokens,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isProfileComplete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoURL,
    String? firstName,
    String? lastName,
    String? phone,
    String? university,
    String? major,
    String? level,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? city,
    String? country,
    List<String>? interests,
    int? points,
    List? fcmTokens,
    DateTime? updatedAt,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      university: university ?? this.university,
      major: major ?? this.major,
      level: level ?? this.level,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      country: country ?? this.country,
      interests: interests ?? this.interests,
      points: points ?? this.points,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? email.split('@').first;
 
 }
}