// lib/app/modules/portfolio/widgets/timeline_widgets.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portefy/app/services/auth_service.dart';
import '../../../models/portfolio_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/base_portfolio_controller.dart';

// Timeline Item Class
class TimelineItemData {
  final String title;
  final String subtitle;
  final String? period;
  final String? description;
  final IconData icon;
  final Color color;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool isExpired;
  final bool isExpiringSoon;
  final List<String>? tags;
  final double? progress;
  final bool isOwner;

  TimelineItemData({
    required this.title,
    required this.subtitle,
    this.period,
    this.description,
    required this.icon,
    required this.color,
    required this.onDelete,
    required this.onEdit,
    this.isExpired = false,
    this.isExpiringSoon = false,
    this.tags,
    this.progress,
    this.isOwner = false,
  });
}

// Main Timeline Builder Function
Widget buildTimelineTab<T extends PortfolioItem>({
  required BasePortfolioController<T> controller,
  required TimelineItemData Function(T, int) itemBuilder,
  bool showSearchBar = true,
  bool showFilters = true,
}) {
  return Obx(() {
    if (controller.isLoading.value && controller.filteredItems.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.filteredItems.isEmpty && !controller.isLoading.value) {
      return _buildEmptyState(controller.getItemType());
    }

    return RefreshIndicator(
      onRefresh: controller.refreshItems,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            controller.loadMoreItems();
          }
          return true;
        },
        child: Column(
          children: [
            // if (showSearchBar) _buildSearchAndFilterBar(controller, showFilters),
            Expanded(
              child: TimelineView(
                items: controller.filteredItems.asMap().entries.map((entry) {
                  return itemBuilder(entry.value, entry.key);
                }).toList(),
                isLoadingMore: controller.isLoadingMore.value,
              ),
            ),
          ],
        ),
      ),
    );
  });
}

// Timeline View Widget
class TimelineView extends StatelessWidget {
  final List<TimelineItemData> items;
  final bool isLoadingMore;

  const TimelineView({
    Key? key,
    required this.items,
    this.isLoadingMore = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = items[index];
        return TimelineElement(
          item: item,
          isFirst: index == 0,
          isLast: index == items.length - 1,
        );
      },
    );
  }
}

// Timeline Element Widget
class TimelineElement extends StatelessWidget {
  final TimelineItemData item;
  final bool isFirst;
  final bool isLast;

  TimelineElement({
    super.key,
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and marker
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: item.color.withOpacity(0.5),
                    ),
                  )
                else
                  SizedBox(height: 20),

                // Circle marker
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.color,
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(item.icon, size: 12, color: Colors.white),
                ),

                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: item.color.withOpacity(0.5),
                    ),
                  )
                else
                  SizedBox(height: 20),
              ],
            ),
          ),

          SizedBox(width: 16),

          // Content
          Expanded(
            child: Card(
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: item.isExpired
                        ? Colors.red.withOpacity(0.5)
                        : item.isExpiringSoon
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and menu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                            _buildItemMenu(item),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Subtitle
                      Text(
                        item.subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),

                      // Description
                      if (item.description != null) ...[
                        SizedBox(height: 8),
                        Text(
                          item.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Progress bar (for skills/hobbies)
                      if (item.progress != null) ...[
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: item.progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(item.color),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${(item.progress! * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],

                      // Tags
                      if (item.tags != null && item.tags!.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: item.tags!
                              .map(
                                (tag) => Chip(
                                  label: Text(
                                    tag,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: item.color.withOpacity(0.1),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  labelPadding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      // Period and status
                      if (item.period != null && item.period!.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.period!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: item.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (item.isExpired || item.isExpiringSoon) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: item.isExpired
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.isExpired
                                      ? 'منتهية الصلاحية'
                                      : 'تنتهي قريباً',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: item.isExpired
                                        ? Colors.red
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemMenu(TimelineItemData item) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, size: 20),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('تعديل'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18),
              SizedBox(width: 8),
              Text('حذف'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          item.onEdit();
        } else if (value == 'delete') {
          item.onDelete();
        }
      },
    );
  }
}

// Empty State Widget
Widget _buildEmptyState(String itemType) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'لا توجد بيانات في $itemType',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'أضف عناصر جديدة لتبدأ في بناء ملفك الشخصي',
          style: TextStyle(color: Colors.grey, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        // SizedBox(height: 20),
        // ElevatedButton(
        //   onPressed: () => Get.toNamed(
        //     AppRoutes.ADD_PORTFOLIO_ITEM,
        //     arguments: {'type': itemType},
        //   ),
        //   child: Text('إضافة الآن'),
        //   style: ElevatedButton.styleFrom(
        //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //   ),
        // ),
      ],
    ),
  );
}

// Item Builder Helper Class
class TimelineItemBuilder {
  static TimelineItemData buildEducationItem(
    EducationModel education,
    int index,
    BasePortfolioController controller,
    AuthService authService,
  ) {
    return TimelineItemData(
      title: '${education.degree} في ${education.fieldOfStudy}',
      subtitle: education.institution,
      period:
          '${education.startDate.year} - ${education.isCurrent ? 'الآن' : education.endDate?.year ?? ''}',
      description: education.description,
      icon: Icons.school,
      color: Colors.blue,
      onDelete: () => controller.deleteItem(education.id, index),
      onEdit: () => _editItem('education', education, index),
      tags: education.achievements,
      isOwner: controller.viewedUserId == authService.currentUserId,
    );
  }

  static TimelineItemData buildExperienceItem(
    ExperienceModel experience,
    int index,
    BasePortfolioController controller,
    AuthService authService,
  ) {
    return TimelineItemData(
      title: experience.position,
      subtitle: experience.company,
      period:
          '${experience.startDate.year} - ${experience.isCurrent ? 'الآن' : experience.endDate?.year ?? ''}',
      description: experience.description,
      icon: Icons.work,
      color: Colors.green,
      onDelete: () => controller.deleteItem(experience.id, index),
      onEdit: () => _editItem('experience', experience, index),
      tags: experience.responsibilities,
      isOwner: controller.viewedUserId == authService.currentUserId,
    );
  }

  static TimelineItemData buildProjectItem(
    ProjectModel project,
    int index,
    BasePortfolioController controller,
    AuthService authService,
  ) {
    return TimelineItemData(
      title: project.title,
      subtitle: project.description,
      period: project.isCompleted ? 'مكتمل' : 'قيد التنفيذ',
      description: project.description,
      icon: Icons.lightbulb,
      color: Colors.orange,
      onDelete: () => controller.deleteItem(project.id, index),
      onEdit: () => _editItem('projects', project, index),
      tags: project.technologies,
      isOwner: controller.viewedUserId == authService.currentUserId,
    );
  }

  static TimelineItemData buildSkillItem(
    SkillModel skill,
    int index,
    BasePortfolioController controller,
    AuthService authService,
  ) {
    return TimelineItemData(
      title: skill.name,
      subtitle: skill.category,
      description: skill.description,
      icon: Icons.star,
      color: Colors.purple,
      progress: skill.level / 5.0,
      onDelete: () => controller.deleteItem(skill.id, index),
      onEdit: () => _editItem('skills', skill, index),
      tags: skill.certifications,
      isOwner: controller.viewedUserId == authService.currentUserId,
    );
  }

  static TimelineItemData buildCertificateItem(
    CertificateModel certificate,
    int index,
    BasePortfolioController controller,
    AuthService authService,
  ) {
    return TimelineItemData(
      title: certificate.name,
      subtitle: certificate.issuer,
      period:
          'صادرة في: ${certificate.issueDate.year}-${certificate.issueDate.month}-${certificate.issueDate.day}',
      description: certificate.description,
      icon: Icons.card_membership,
      color: Colors.teal,
      isExpired: certificate.isExpired,
      isExpiringSoon: certificate.isExpiringSoon,
      onDelete: () => controller.deleteItem(certificate.id, index),
      onEdit: () => _editItem('certificates', certificate, index),
      tags: certificate.skills,
      isOwner: controller.viewedUserId == authService.currentUserId,
    );
  }

  static TimelineItemData buildActivityItem(
    ActivityModel activity,
    int index,
    BasePortfolioController controller,
    AuthService authService,
  ) {
    return TimelineItemData(
      title: activity.title,
      subtitle: activity.organization,
      period:
          '${activity.startDate.year} - ${activity.isCurrent ? 'الآن' : activity.endDate?.year ?? ''}',
      description: activity.description,
      icon: Icons.group_work,
      color: Colors.indigo,
      onDelete: () => controller.deleteItem(activity.id, index),
      onEdit: () => _editItem('activities', activity, index),
      tags: activity.skills,
      isOwner: controller.viewedUserId == authService.currentUserId,
    );
  }

  static TimelineItemData buildHobbyItem(
    HobbyModel hobby,
    int index,
    BasePortfolioController controller,
    AuthService authService,
  ) {
    return TimelineItemData(
      title: hobby.name,
      subtitle: hobby.category,
      description: hobby.description,
      icon: Icons.music_note,
      color: Colors.pink,
      progress: hobby.proficiency / 5.0,
      onDelete: () => controller.deleteItem(hobby.id, index),
      onEdit: () => _editItem('hobbies', hobby, index),
      isOwner: controller.viewedUserId == authService.currentUserId,
    );
  }

  static TimelineItemData buildLanguageItem(
    LanguageModel language,
    int index,
    BasePortfolioController controller,
    AuthService authService,
  ) {
    return TimelineItemData(
      title: language.name,
      subtitle: language.proficiency,
      icon: Icons.language,
      color: Colors.purple,
      // progress: language.proficiency / 5.0,
      onDelete: () => controller.deleteItem(language.id, index),
      onEdit: () => _editItem('languages', language, index),
      isOwner: controller.viewedUserId == authService.currentUserId,
    );
  }

  static void _editItem(String type, dynamic item, int index) {
    Get.toNamed(
      AppRoutes.EDIT_PORTFOLIO_ITEM,
      arguments: {'type': type, 'item': item, 'index': index},
    );
  }

  // Search and Filter Bar
  Widget _buildSearchAndFilterBar<T extends PortfolioItem>(
    BasePortfolioController<T> controller,
    bool showFilters,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'بحث في ${controller.getItemType()}...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),

          // Filter chips
          if (showFilters && controller.getFilterOptions().isNotEmpty) ...[
            SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.getFilterOptions().length,
                itemBuilder: (context, index) {
                  String filter = controller.getFilterOptions()[index];
                  return Obx(
                    () => Container(
                      margin: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            color: controller.selectedFilter.value == filter
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                        selected: controller.selectedFilter.value == filter,
                        onSelected: (selected) {
                          controller.selectedFilter.value = selected
                              ? filter
                              : '';
                        },
                        selectedColor: Colors.blue,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
