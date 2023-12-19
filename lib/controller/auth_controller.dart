import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final RxString username = "No username set".obs;
  final RxString email = "No email set".obs;
  final RxString uid = "No uid".obs;

  Future<void> saveUserLocal(String username, String email, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
    await prefs.setString("email", email);
    await prefs.setString("uid", uid);
    this.username.value = username;
    this.email.value = email;
    this.uid.value = uid;
  }

  Future<void> fetchUserLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString("username") ?? "";
    final email = prefs.getString("email") ?? "";
    final uid = prefs.getString("uid") ?? "";
    this.username.value = username;
    this.email.value = email;
    this.uid.value = uid;
  }
}