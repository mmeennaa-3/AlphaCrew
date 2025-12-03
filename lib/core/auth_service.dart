import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxService {
  final RxString _userName = "Guest User".obs;
  final RxString _userEmail = "".obs;
  final RxString _userAvatar = "".obs;

  late Box profileBox;
  String? currentUserId;

  Future<void> initUser(String userId, {String? email}) async {
    currentUserId = userId;
    profileBox = await Hive.openBox('profileBox_$currentUserId');

    _userName.value = profileBox.get('name', defaultValue: "Guest User");
    _userEmail.value = profileBox.get('email', defaultValue: email ?? "Guest User");
    _userAvatar.value = profileBox.get('avatar', defaultValue: "assets/profile.jpg");
  }

  String get userName => _userName.value;
  String get userEmail => _userEmail.value;
  String get userAvatar => _userAvatar.value;

  Future<void> updateProfile({String? name, String? email, String? avatar}) async {
    if (currentUserId == null) return;
    if (name != null) {
      profileBox.put('name', name);
      _userName.value = name;
    }
    if (email != null) {
      profileBox.put('email', email);
      _userEmail.value = email;
    }
    if (avatar != null) {
      profileBox.put('avatar', avatar);
      _userAvatar.value = avatar;
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signUp(email: email, password: password);
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await initUser(userId, email: email);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await initUser(userId, email: email);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _userName.value = "Guest User";
    _userEmail.value = "";
    _userAvatar.value = "assets/profile.jpg";
    currentUserId = null;
  }
}
