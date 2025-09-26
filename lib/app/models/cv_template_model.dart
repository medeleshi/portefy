// ملف جديد: cv_template_model.dart
import 'package:flutter/material.dart';

class CVTemplateModel {
  final String id;
  final String name;
  final String description;
  final Color backgroundColor;
  final String? previewImage;
  final TemplateStyle style;
  final List<TemplateSection> sections;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final bool hasHeaderImage;
  final bool hasSkillsChart;
  final bool hasProgressBars;
  final bool isRTL;

  CVTemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundColor,
    this.previewImage,
    required this.style,
    required this.sections,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.green,
    this.textColor = Colors.black87,
    this.hasHeaderImage = false,
    this.hasSkillsChart = false,
    this.hasProgressBars = false,
    this.isRTL = true,
  });

  // إنشاء قوالب افتراضية
  static List<CVTemplateModel> get defaultTemplates {
    return [
      CVTemplateModel(
        id: 'classic',
        name: 'القالب الكلاسيكي',
        description: 'تصميم تقليدي ومنظم يناسب جميع المجالات',
        backgroundColor: Colors.blue[50]!,
        style: TemplateStyle.classic,
        sections: [
          TemplateSection.personalInfo,
          TemplateSection.education,
          TemplateSection.experience,
          TemplateSection.skills,
          TemplateSection.languages,
          TemplateSection.projects,
        ],
        primaryColor: Color(0xFF2C3E50),
        secondaryColor: Color(0xFF3498DB),
        hasProgressBars: true,
      ),
      CVTemplateModel(
        id: 'modern',
        name: 'القالب الحديث',
        description: 'تصميم عصري مع تركيز على المهارات',
        backgroundColor: Colors.green[50]!,
        style: TemplateStyle.modern,
        sections: [
          TemplateSection.personalInfo,
          TemplateSection.skills,
          TemplateSection.experience,
          TemplateSection.education,
          TemplateSection.projects,
          TemplateSection.languages,
        ],
        primaryColor: Color(0xFF27AE60),
        secondaryColor: Color(0xFF2ECC71),
        hasSkillsChart: true,
        hasHeaderImage: true,
      ),
      CVTemplateModel(
        id: 'creative',
        name: 'القالب الإبداعي',
        description: 'تصميم مبدع يناسب المجالات الإبداعية',
        backgroundColor: Colors.purple[50]!,
        style: TemplateStyle.creative,
        sections: [
          TemplateSection.personalInfo,
          TemplateSection.projects,
          TemplateSection.skills,
          TemplateSection.experience,
          TemplateSection.education,
          TemplateSection.languages,
        ],
        primaryColor: Color(0xFF8E44AD),
        secondaryColor: Color(0xFF9B59B6),
        hasHeaderImage: true,
      ),
      CVTemplateModel(
        id: 'minimalist',
        name: 'القالب البسيط',
        description: 'تصميم بسيط ومركز على المحتوى',
        backgroundColor: Colors.orange[50]!,
        style: TemplateStyle.minimalist,
        sections: [
          TemplateSection.personalInfo,
          TemplateSection.experience,
          TemplateSection.education,
          TemplateSection.skills,
        ],
        primaryColor: Color(0xFFE67E22),
        secondaryColor: Color(0xFFF39C12),
      ),
      CVTemplateModel(
        id: 'professional',
        name: 'القالب المهني',
        description: 'تصميم احترافي للمتقدمين للوظائف',
        backgroundColor: Colors.grey[100]!,
        style: TemplateStyle.professional,
        sections: [
          TemplateSection.personalInfo,
          TemplateSection.experience,
          TemplateSection.education,
          TemplateSection.skills,
          TemplateSection.languages,
          TemplateSection.certifications,
        ],
        primaryColor: Color(0xFF34495E),
        secondaryColor: Color(0xFF7F8C8D),
        hasProgressBars: true,
      ),
      CVTemplateModel(
        id: 'academic',
        name: 'القالب الأكاديمي',
        description: 'مصمم خصيصًا للأوساط الأكاديمية والبحثية',
        backgroundColor: Colors.brown[50]!,
        style: TemplateStyle.academic,
        sections: [
          TemplateSection.personalInfo,
          TemplateSection.education,
          TemplateSection.publications,
          TemplateSection.research,
          TemplateSection.skills,
          TemplateSection.languages,
        ],
        primaryColor: Color(0xFF795548),
        secondaryColor: Color(0xFFA1887F),
      ),
    ];
  }

  // الحصول على قالب بواسطة ID
  static CVTemplateModel getTemplateById(String id) {
    return defaultTemplates.firstWhere(
      (template) => template.id == id,
      orElse: () => defaultTemplates.first,
    );
  }

  // تحويل إلى Map للتخزين
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'backgroundColor': backgroundColor.value,
      'previewImage': previewImage,
      'style': style.index,
      'sections': sections.map((section) => section.index).toList(),
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'textColor': textColor.value,
      'hasHeaderImage': hasHeaderImage,
      'hasSkillsChart': hasSkillsChart,
      'hasProgressBars': hasProgressBars,
      'isRTL': isRTL,
    };
  }

  // إنشاء من Map
  factory CVTemplateModel.fromMap(Map<String, dynamic> map) {
    return CVTemplateModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      backgroundColor: Color(map['backgroundColor'] ?? Colors.blue),
      previewImage: map['previewImage'],
      style: TemplateStyle.values[map['style'] ?? 0],
      sections: List<int>.from(map['sections'] ?? [])
          .map((index) => TemplateSection.values[index])
          .toList(),
      primaryColor: Color(map['primaryColor'] ?? Colors.blue.value),
      secondaryColor: Color(map['secondaryColor'] ?? Colors.green.value),
      textColor: Color(map['textColor'] ?? Colors.black87.value),
      hasHeaderImage: map['hasHeaderImage'] ?? false,
      hasSkillsChart: map['hasSkillsChart'] ?? false,
      hasProgressBars: map['hasProgressBars'] ?? false,
      isRTL: map['isRTL'] ?? true,
    );
  }

  // نسخ القالب مع تعديلات
  CVTemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    Color? backgroundColor,
    String? previewImage,
    TemplateStyle? style,
    List<TemplateSection>? sections,
    Color? primaryColor,
    Color? secondaryColor,
    Color? textColor,
    bool? hasHeaderImage,
    bool? hasSkillsChart,
    bool? hasProgressBars,
    bool? isRTL,
  }) {
    return CVTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      previewImage: previewImage ?? this.previewImage,
      style: style ?? this.style,
      sections: sections ?? this.sections,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      textColor: textColor ?? this.textColor,
      hasHeaderImage: hasHeaderImage ?? this.hasHeaderImage,
      hasSkillsChart: hasSkillsChart ?? this.hasSkillsChart,
      hasProgressBars: hasProgressBars ?? this.hasProgressBars,
      isRTL: isRTL ?? this.isRTL,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CVTemplateModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CVTemplateModel{id: $id, name: $name}';
  }
}

// أنماط القوالب
enum TemplateStyle {
  classic,     // كلاسيكي
  modern,      // حديث
  creative,    // إبداعي
  minimalist,  // بسيط
  professional,// احترافي
  academic,    // أكاديمي
}

// أقسام القالب
enum TemplateSection {
  personalInfo,     // المعلومات الشخصية
  education,        // التعليم
  experience,       // الخبرات
  skills,           // المهارات
  languages,        // اللغات
  projects,         // المشاريع
  certifications,   // الشهادات
  publications,     // المنشورات
  research,         // البحث العلمي
  references,       // المراجع
  achievements,     // الإنجازات
  volunteer,        // العمل التطوعي
}

// نموذج لإعدادات التصدير
class CVExportSettings {
  final String fileName;
  final bool includeContactInfo;
  final bool includePhoto;
  final bool includeSocialMedia;
  final PaperSize paperSize;
  final FileFormat fileFormat;
  final int imageQuality;

  CVExportSettings({
    this.fileName = 'سيرتي_الذاتية',
    this.includeContactInfo = true,
    this.includePhoto = true,
    this.includeSocialMedia = true,
    this.paperSize = PaperSize.a4,
    this.fileFormat = FileFormat.pdf,
    this.imageQuality = 90,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'includeContactInfo': includeContactInfo,
      'includePhoto': includePhoto,
      'includeSocialMedia': includeSocialMedia,
      'paperSize': paperSize.index,
      'fileFormat': fileFormat.index,
      'imageQuality': imageQuality,
    };
  }

  factory CVExportSettings.fromMap(Map<String, dynamic> map) {
    return CVExportSettings(
      fileName: map['fileName'] ?? 'سيرتي_الذاتية',
      includeContactInfo: map['includeContactInfo'] ?? true,
      includePhoto: map['includePhoto'] ?? true,
      includeSocialMedia: map['includeSocialMedia'] ?? true,
      paperSize: PaperSize.values[map['paperSize'] ?? 0],
      fileFormat: FileFormat.values[map['fileFormat'] ?? 0],
      imageQuality: map['imageQuality'] ?? 90,
    );
  }
}

// أحجام الورق
enum PaperSize {
  a4,
  letter,
  legal,
}

// تنسيقات الملف
enum FileFormat {
  pdf,
  docx,
  html,
  image,
}

// نموذج لبيانات CV
class CVData {
  final Map<TemplateSection, dynamic> sectionData;
  final CVTemplateModel template;
  final CVExportSettings exportSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  CVData({
    required this.sectionData,
    required this.template,
    required this.exportSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'sectionData': _convertSectionData(sectionData),
      'template': template.toMap(),
      'exportSettings': exportSettings.toMap(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> _convertSectionData(Map<TemplateSection, dynamic> data) {
    final converted = <String, dynamic>{};
    data.forEach((key, value) {
      converted[key.index.toString()] = value;
    });
    return converted;
  }

  factory CVData.fromMap(Map<String, dynamic> map) {
    return CVData(
      sectionData: _parseSectionData(map['sectionData'] ?? {}),
      template: CVTemplateModel.fromMap(Map<String, dynamic>.from(map['template'] ?? {})),
      exportSettings: CVExportSettings.fromMap(Map<String, dynamic>.from(map['exportSettings'] ?? {})),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  static Map<TemplateSection, dynamic> _parseSectionData(Map<String, dynamic> data) {
    final result = <TemplateSection, dynamic>{};
    data.forEach((key, value) {
      final sectionIndex = int.tryParse(key);
      if (sectionIndex != null && sectionIndex < TemplateSection.values.length) {
        result[TemplateSection.values[sectionIndex]] = value;
      }
    });
    return result;
  }

  CVData copyWith({
    Map<TemplateSection, dynamic>? sectionData,
    CVTemplateModel? template,
    CVExportSettings? exportSettings,
    DateTime? updatedAt,
  }) {
    return CVData(
      sectionData: sectionData ?? this.sectionData,
      template: template ?? this.template,
      exportSettings: exportSettings ?? this.exportSettings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}