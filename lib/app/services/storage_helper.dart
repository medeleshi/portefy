import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/post_model.dart';

class StorageHelper {
  static final StorageHelper _instance = StorageHelper._internal();
  factory StorageHelper() => _instance;
  StorageHelper._internal();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Cache posts to SharedPreferences
  Future<void> cachePosts(String key, List<PostModel> posts) async {
    try {
      final prefs = await _prefs;
      final postsJson = posts.map((post) => json.encode(post.toMap())).toList();
      await prefs.setStringList(key, postsJson);
    } catch (e) {
      print('Error caching posts: $e');
    }
  }

  // Get cached posts from SharedPreferences
  Future<List<PostModel>> getCachedPosts(String key) async {
    try {
      final prefs = await _prefs;
      final postsJson = prefs.getStringList(key) ?? [];
      
      return postsJson.map((jsonString) {
        try {
          final map = json.decode(jsonString) as Map<String, dynamic>;
          return PostModel.fromMap(map, map['id'] ?? '');
        } catch (e) {
          print('Error parsing cached post: $e');
          return null;
        }
      }).whereType<PostModel>().toList();
    } catch (e) {
      print('Error getting cached posts: $e');
      return [];
    }
  }

  // Store last fetch time
  Future<void> setLastFetchTime(String key, DateTime time) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(key, time.toIso8601String());
    } catch (e) {
      print('Error setting last fetch time: $e');
    }
  }

  // Get last fetch time
  Future<DateTime?> getLastFetchTime(String key) async {
    try {
      final prefs = await _prefs;
      final timeString = prefs.getString(key);
      return timeString != null ? DateTime.parse(timeString) : null;
    } catch (e) {
      print('Error getting last fetch time: $e');
      return null;
    }
  }

  // Clear cache for a specific key
  Future<void> clearCache(String key) async {
    try {
      final prefs = await _prefs;
      await prefs.remove(key);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    try {
      final prefs = await _prefs;
      await prefs.clear();
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }
}