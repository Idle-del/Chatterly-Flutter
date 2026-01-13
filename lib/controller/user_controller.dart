import 'package:get/get.dart';

class UserController extends GetxController {
  String? profileImageUrl;

  void setProfileImageUrl(String? url) {
    if (url == null || url == profileImageUrl) return;
    profileImageUrl = url;
    update();
  }
}
