import 'package:absensi_app/services/shared_pref_service.dart';
import 'package:uuid/uuid.dart';
import 'db_service.dart';
import 'package:absensi_app/models/user_model.dart';

class AuthService {
  static Future<bool> registerUser(
    String name,
    String email,
    String password,
  ) async {
    // Cek apakah email sudah digunakan
    final existingUser = await DBService.getUserByEmail(email);
    if (existingUser != null) return false;

    final newUser = UserModel(
      uid: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
    );

    await DBService.insertUser(newUser);
    await SharedPrefService.saveUID(newUser.uid);
    return true;
  }

  static Future<bool> loginUser(String email, String password) async {
    final user = await DBService.getUserByEmail(email);
    if (user == null) return false;
    if (user.password != password) return false;

    await SharedPrefService.saveUID(user.uid);
    return true;
  }
}
