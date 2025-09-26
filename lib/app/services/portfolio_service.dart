import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio_model.dart';

class PortfolioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection paths
  String _getUserPortfolioPath(String userId) => 'users/$userId/portfolio';

  // Education methods
  Future<void> addEducation(EducationModel education) async {
    try {
      await _firestore
          .collection(_getUserPortfolioPath(education.userId))
          .doc('education')
          .collection('items')
          .add(education.toMap());
    } catch (e) {
      throw 'فشل إضافة التعليم: ${e.toString()}';
    }
  }

  Future<List<EducationModel>> getEducation(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('education')
          .collection('items')
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => EducationModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw 'فشل جلب بيانات التعليم: ${e.toString()}';
    }
  }

  Future<void> updateEducation(
    String userId,
    String educationId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('education')
          .collection('items')
          .doc(educationId)
          .update(data);
    } catch (e) {
      throw 'فشل تحديث التعليم: ${e.toString()}';
    }
  }

  Future<void> deleteEducation(String educationId) async {
    try {
      // This is a simplified approach - in a real app you'd need the userId
      await _firestore.collection('items').doc(educationId).delete();
    } catch (e) {
      throw 'فشل حذف التعليم: ${e.toString()}';
    }
  }

  // Experience methods
  Future<void> addExperience(ExperienceModel experience) async {
    try {
      await _firestore
          .collection(_getUserPortfolioPath(experience.userId))
          .doc('experience')
          .collection('items')
          .add(experience.toMap());
    } catch (e) {
      throw 'فشل إضافة الخبرة: ${e.toString()}';
    }
  }

  Future<List<ExperienceModel>> getExperience(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('experience')
          .collection('items')
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => ExperienceModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw 'فشل جلب بيانات الخبرة: ${e.toString()}';
    }
  }

  Future<void> updateExperience(
    String userId,
    String experienceId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('experience')
          .collection('items')
          .doc(experienceId)
          .update(data);
    } catch (e) {
      throw 'فشل تحديث الخبرة: ${e.toString()}';
    }
  }

  Future<void> deleteExperience(String experienceId) async {
    try {
      await _firestore.collection('items').doc(experienceId).delete();
    } catch (e) {
      throw 'فشل حذف الخبرة: ${e.toString()}';
    }
  }

  // Projects methods
  Future<void> addProject(ProjectModel project) async {
    try {
      await _firestore
          .collection(_getUserPortfolioPath(project.userId))
          .doc('projects')
          .collection('items')
          .add(project.toMap());
    } catch (e) {
      throw 'فشل إضافة المشروع: ${e.toString()}';
    }
  }

  Future<List<ProjectModel>> getProjects(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('projects')
          .collection('items')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => ProjectModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw 'فشل جلب بيانات المشاريع: ${e.toString()}';
    }
  }

  Future<void> updateProject(
    String userId,
    String projectId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('projects')
          .collection('items')
          .doc(projectId)
          .update(data);
    } catch (e) {
      throw 'فشل تحديث المشروع: ${e.toString()}';
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore.collection('items').doc(projectId).delete();
    } catch (e) {
      throw 'فشل حذف المشروع: ${e.toString()}';
    }
  }

  // Skills methods
  Future<void> addSkill(SkillModel skill) async {
    try {
      await _firestore
          .collection(_getUserPortfolioPath(skill.userId))
          .doc('skills')
          .collection('items')
          .add(skill.toMap());
    } catch (e) {
      throw 'فشل إضافة المهارة: ${e.toString()}';
    }
  }

  Future<List<SkillModel>> getSkills(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('skills')
          .collection('items')
          .orderBy('category')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                SkillModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw 'فشل جلب بيانات المهارات: ${e.toString()}';
    }
  }

  Future<void> updateSkill(
    String userId,
    String skillId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('skills')
          .collection('items')
          .doc(skillId)
          .update(data);
    } catch (e) {
      throw 'فشل تحديث المهارة: ${e.toString()}';
    }
  }

  Future<void> deleteSkill(String skillId) async {
    try {
      await _firestore.collection('items').doc(skillId).delete();
    } catch (e) {
      throw 'فشل حذف المهارة: ${e.toString()}';
    }
  }

  // Languages methods
  Future<void> addLanguage(LanguageModel language) async {
    try {
      await _firestore
          .collection(_getUserPortfolioPath(language.userId))
          .doc('languages')
          .collection('items')
          .add(language.toMap());
    } catch (e) {
      throw 'فشل إضافة اللغة: ${e.toString()}';
    }
  }

  Future<List<LanguageModel>> getLanguages(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('languages')
          .collection('items')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map(
            (doc) => LanguageModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw 'فشل جلب بيانات اللغات: ${e.toString()}';
    }
  }

  Future<void> updateLanguage(
    String userId,
    String languageId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('languages')
          .collection('items')
          .doc(languageId)
          .update(data);
    } catch (e) {
      throw 'فشل تحديث اللغة: ${e.toString()}';
    }
  }

  Future<void> deleteLanguage(String languageId) async {
    try {
      await _firestore.collection('items').doc(languageId).delete();
    } catch (e) {
      throw 'فشل حذف اللغة: ${e.toString()}';
    }
  }

  // إضافة طرق للأنشطة
  Future<void> addActivity(ActivityModel activity) async {
    try {
      await _firestore
          .collection(_getUserPortfolioPath(activity.userId))
          .doc('activities')
          .collection('items')
          .add(activity.toMap());
    } catch (e) {
      throw 'فشل إضافة النشاط: ${e.toString()}';
    }
  }

  Future<List<ActivityModel>> getActivities(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('activities')
          .collection('items')
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => ActivityModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw 'فشل جلب بيانات الأنشطة: ${e.toString()}';
    }
  }

  // إضافة طرق للشهادات
  Future<void> addCertificate(CertificateModel certificate) async {
    try {
      await _firestore
          .collection(_getUserPortfolioPath(certificate.userId))
          .doc('certificates')
          .collection('items')
          .add(certificate.toMap());
    } catch (e) {
      throw 'فشل إضافة الشهادة: ${e.toString()}';
    }
  }

  Future<List<CertificateModel>> getCertificates(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('certificates')
          .collection('items')
          .orderBy('issueDate', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => CertificateModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw 'فشل جلب بيانات الشهادات: ${e.toString()}';
    }
  }

  // Hobby methods
  Future<void> addHobby(HobbyModel hobby) async {
    try {
      await _firestore
          .collection(_getUserPortfolioPath(hobby.userId))
          .doc('hobbies')
          .collection('items')
          .add(hobby.toMap());
    } catch (e) {
      throw 'فشل إضافة الهواية: ${e.toString()}';
    }
  }

  Future<List<HobbyModel>> getHobbies(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('hobbies')
          .collection('items')
          .orderBy('startedDate', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                HobbyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw 'فشل جلب بيانات الهوايات: ${e.toString()}';
    }
  }

  // Get complete portfolio
  Future<Map<String, dynamic>> getCompletePortfolio(String userId) async {
    try {
      return {
        'education': await getEducation(userId),
        'experience': await getExperience(userId),
        'projects': await getProjects(userId),
        'skills': await getSkills(userId),
        'languages': await getLanguages(userId),
      };
    } catch (e) {
      throw 'فشل جلب الملف الشخصي الكامل: ${e.toString()}';
    }
  }

  // Portfolio statistics
  Future<Map<String, int>> getPortfolioStats(String userId) async {
    try {
      Map<String, dynamic> portfolio = await getCompletePortfolio(userId);

      return {
        'education': (portfolio['education'] as List).length,
        'experience': (portfolio['experience'] as List).length,
        'projects': (portfolio['projects'] as List).length,
        'skills': (portfolio['skills'] as List).length,
        'languages': (portfolio['languages'] as List).length,
      };
    } catch (e) {
      throw 'فشل جلب إحصائيات الملف الشخصي: ${e.toString()}';
    }
  }

  // Search portfolio items
  Future<List<dynamic>> searchPortfolio(String userId, String query) async {
    try {
      List<dynamic> results = [];

      // Search in projects
      List<ProjectModel> projects = await getProjects(userId);
      results.addAll(
        projects.where(
          (project) =>
              project.title.toLowerCase().contains(query.toLowerCase()) ||
              project.description.toLowerCase().contains(query.toLowerCase()),
        ),
      );

      // Search in skills
      List<SkillModel> skills = await getSkills(userId);
      results.addAll(
        skills.where(
          (skill) => skill.name.toLowerCase().contains(query.toLowerCase()),
        ),
      );

      // Search in experience
      List<ExperienceModel> experience = await getExperience(userId);
      results.addAll(
        experience.where(
          (exp) =>
              exp.position.toLowerCase().contains(query.toLowerCase()) ||
              exp.company.toLowerCase().contains(query.toLowerCase()),
        ),
      );

      return results;
    } catch (e) {
      throw 'فشل البحث في الملف الشخصي: ${e.toString()}';
    }
  }

  // إضافة هذه الدوال في PortfolioService

  Future<void> updateCertificate(
    String userId,
    String certificateId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('certificates')
          .collection('items')
          .doc(certificateId)
          .update(data);
    } catch (e) {
      throw 'فشل تحديث الشهادة: ${e.toString()}';
    }
  }

  Future<void> updateActivity(
    String userId,
    String activityId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('activities')
          .collection('items')
          .doc(activityId)
          .update(data);
    } catch (e) {
      throw 'فشل تحديث النشاط: ${e.toString()}';
    }
  }

  Future<void> updateHobby(
    String userId,
    String hobbyId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore
          .collection(_getUserPortfolioPath(userId))
          .doc('hobbies')
          .collection('items')
          .doc(hobbyId)
          .update(data);
    } catch (e) {
      throw 'فشل تحديث الهواية: ${e.toString()}';
    }
  }

  Future<void> deleteActivity(String id) async {}

  Future<void> deleteHobby(String id) async {}

  Future<void> deleteCertificate(String id) async {}
}
