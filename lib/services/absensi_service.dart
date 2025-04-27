import 'package:absensi_app/models/absensi_model.dart';
import 'package:absensi_app/services/db_service.dart';
import 'package:intl/intl.dart';

class AbsensiService {
  /// Simpan data absensi saat check-in
  static Future<int> checkIn(AbsensiModel data) async {
    return await DBService.insertAbsensi(data);
  }

  /// Update jam check-out berdasarkan ID absensi
  static Future<void> checkOut(int id, String jamCheckOut) async {
    await DBService.updateCheckOut(id, jamCheckOut);
  }

  /// Ambil semua absensi milik user (berdasarkan UID)
  static Future<List<AbsensiModel>> getAbsensiUser(String uid) async {
    return await DBService.getAbsensiByUID(uid);
  }

  /// Ambil absensi hari ini berdasarkan UID dan tanggal
  static Future<AbsensiModel?> getTodayAbsensi(String uid) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await DBService.getTodayAbsensiByUID(uid, today);
  }

  /// Menghapus absensi berdasarkan ID
  static Future<void> deleteAbsensi(int id) async {
    await DBService.deleteAbsensiByUId(id);
  }
}
