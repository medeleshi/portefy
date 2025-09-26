import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageViewerController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxList<String> imageUrls = <String>[].obs;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void initialize(List<String> urls, int initialIndex) {
    imageUrls.value = urls;
    currentIndex.value = initialIndex;
    if (pageController.hasClients) {
      pageController.jumpToPage(initialIndex);
    }
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  void goBack() {
    Get.back();
  }
}