import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:absensi_app/models/absensi_model.dart';
import 'package:absensi_app/models/user_model.dart';

class DBService {
  static Database? _database;

  static Future<Database> initDB() async {
    if (_database != null) return _database!;
    String path = join(await getDatabasesPath(), 'absensi.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT,
            name TEXT,
            email TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE absensi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT,
            tanggal TEXT,
            jam_check_in TEXT,
            jam_check_out TEXT,
            lokasi TEXT
          )
        ''');
      },
    );

    return _database!;
  }

  // ---------- USER ----------
  static Future<int> insertUser(UserModel user) async {
    final db = await initDB();
    return await db.insert('users', user.toMap());
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    final db = await initDB();
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  static Future<UserModel?> getUserByUID(String uid) async {
    final db = await initDB();
    final result = await db.query('users', where: 'uid = ?', whereArgs: [uid]);

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  static Future<int> updateUser(UserModel user) async {
    final db = await initDB();
    return await db.update(
      'users',
      user.toMap(),
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  // ---------- ABSENSI ----------
  static Future<int> insertAbsensi(AbsensiModel data) async {
    final db = await initDB();
    return await db.insert('absensi', data.toMap());
  }

  static Future<List<AbsensiModel>> getAbsensiByUID(String uid) async {
    final db = await initDB();
    List<Map<String, dynamic>> result = await db.query(
      'absensi',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'tanggal DESC',
    );

    return result.map((map) => AbsensiModel.fromMap(map)).toList();
  }

  static Future<AbsensiModel?> getTodayAbsensiByUID(
    String uid,
    String tanggal,
  ) async {
    final db = await initDB();
    final result = await db.query(
      'absensi',
      where: 'uid = ? AND tanggal = ?',
      whereArgs: [uid, tanggal],
    );

    if (result.isNotEmpty) {
      return AbsensiModel.fromMap(result.first);
    }
    return null;
  }

  static Future<int> updateCheckOut(int id, String checkOut) async {
    final db = await initDB();
    return await db.update(
      'absensi',
      {'jam_check_out': checkOut},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteAbsensiByUId(int id) async {
    final db = await initDB();
    return await db.delete('absensi', where: 'id = ?', whereArgs: [id]);
  }
}
