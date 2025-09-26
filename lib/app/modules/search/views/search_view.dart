import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/post_model.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchPortefyController> {
  final TextEditingController searchController = TextEditingController();

  SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getCurrentBackgroundColor(),
      appBar: AppBar(
        title: _buildSearchField(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'ابحث عن منشورات أو مستخدمين...',
        border: InputBorder.none,
        // suffixIcon: Obx(() => controller.currentQuery.value.isNotEmpty
        //     ? IconButton(
        //         onPressed: () {
        //           searchController.clear();
        //           controller.clearSearch();
        //         },
        //         icon: Icon(Icons.clear),
        //       )
        //     : null),
      ),
      onChanged: (value) {
        if (value.length > 2) {
          controller.getSuggestions(value);
        } else {
          controller.searchSuggestions.clear();
        }
      },
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          _performSearch(value);
        }
      },
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value && !controller.isSearching) {
        return Center(child: CircularProgressIndicator());
      }

      if (!controller.isSearching) {
        return _buildInitialState();
      }

      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (!controller.hasResults) {
        return _buildNoResults();
      }

      return _buildResults();
    });
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الوسوم الشائعة
          _buildPopularTags(),
          SizedBox(height: 24),
          // المنشورات الشائعة
          _buildTrendingPosts(),
        ],
      ),
    );
  }

  Widget _buildPopularTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوسوم الشائعة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.popularTags
                  .map((tag) => FilterChip(
                        label: Text('#$tag'),
                        selected: controller.isTagSelected(tag),
                        onSelected: (_) {
                          controller.toggleTagFilter(tag);
                          if (controller.currentQuery.value.isEmpty) {
                            searchController.text = tag;
                            _performSearch(tag);
                          }
                        },
                      ))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildTrendingPosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'منشورات شائعة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                return _buildPostCard(controller.searchResults[index]);
              },
            )),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'جرب كلمات بحث مختلفة أو أضف فلاتر',
            style: TextStyle(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Obx(() {
      if (controller.searchType.value == 'posts') {
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            return _buildPostCard(controller.searchResults[index]);
          },
        );
      } else {
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.userResults.length,
          itemBuilder: (context, index) {
            return _buildUserCard(controller.userResults[index]);
          },
        );
      }
    });
  }

  Widget _buildPostCard(PostModel post) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: post.authorAvatar != null
                      ? CachedNetworkImageProvider(post.authorAvatar!)
                      : null,
                  child: post.authorAvatar == null
                      ? Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (post.authorUniversity != null ||
                          post.authorMajor != null)
                        Text(
                          [
                            post.authorMajor,
                            post.authorUniversity,
                          ].where((e) => e != null).join(' • '),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  timeago.format(post.createdAt, locale: 'ar'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Post Content
            Text(
              post.content,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),

            // Post Tags
            if (post.tags.isNotEmpty) ...[
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags
                    .map(
                      (tag) => Chip(
                        label: Text('#$tag', style: TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],

            SizedBox(height: 16),

            // Post Actions
            Row(
              children: [
                Icon(Icons.favorite, size: 20, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text('${post.likesCount}'),
                SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text('${post.commentsCount}'),
                SizedBox(width: 16),
                Icon(Icons.share, size: 20, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text('${post.sharesCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: user.photoURL != null
              ? CachedNetworkImageProvider(user.photoURL!)
              : null,
          child: user.photoURL == null
              ? Icon(Icons.person, color: AppColors.primary)
              : null,
        ),
        title: Text(
          user.fullName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.university != null || user.major != null)
              Text(
                [
                  user.university,
                  user.major,
                ].where((e) => e != null).join(' • '),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            if (user.bio != null && user.bio!.isNotEmpty)
              Text(
                user.bio!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: () {
          // الانتقال لصفحة المستخدم
          // Get.toNamed(AppRoutes.USER_PROFILE, arguments: {'userId': user.id});
        },
      ),
    );
  }

  void _performSearch(String query) {
    if (controller.searchType.value == 'posts') {
      controller.searchPosts(query);
    } else {
      controller.searchUsers(query);
    }
  }

  void _showFilterDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'فلاتر البحث',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // يمكن إضافة المزيد من خيارات التصفية هنا
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('نوع البحث:'),
                Obx(() => DropdownButton<String>(
                      value: controller.searchType.value,
                      items: [
                        DropdownMenuItem(value: 'posts', child: Text('منشورات')),
                        DropdownMenuItem(value: 'users', child: Text('مستخدمين')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.searchType.value = value;
                          if (controller.currentQuery.value.isNotEmpty) {
                            _performSearch(controller.currentQuery.value);
                          }
                        }
                      },
                    )),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      if (controller.currentQuery.value.isNotEmpty) {
                        controller.advancedSearch();
                      }
                    },
                    child: Text('تطبيق الفلاتر'),
                  ),
                ),
                SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  child: Text('مسح الكل'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}