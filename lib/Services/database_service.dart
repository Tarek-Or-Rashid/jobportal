import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/job_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('job_portal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('Database path: $path'); // Debug line

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Saved Jobs Table
    await db.execute('''
      CREATE TABLE saved_jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        job_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        company TEXT NOT NULL,
        location TEXT NOT NULL,
        salary TEXT NOT NULL,
        description TEXT NOT NULL,
        image TEXT,
        UNIQUE(user_email, job_id)
      )
    ''');
  }

  // ==================== USER OPERATIONS ====================
  
  Future<int> createUser(UserModel user) async {
    try {
      final db = await database;
      
      // Check if user already exists
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [user.email],
      );
      
      if (existing.isNotEmpty) {
        throw Exception('Email already exists');
      }
      
      // Insert new user (without id, it will auto-increment)
      return await db.insert('users', {
        'name': user.name,
        'email': user.email,
        'password': user.password,
      });
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      
      if (results.isNotEmpty) {
        return UserModel.fromMap(results.first);
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (results.isNotEmpty) {
        return UserModel.fromMap(results.first);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // ==================== JOB OPERATIONS ====================
  
  Future<int> saveJob(JobModel job, String userEmail) async {
    final db = await database;
    try {
      return await db.insert(
        'saved_jobs',
        job.toMap(userEmail),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving job: $e');
      return -1;
    }
  }

  Future<List<JobModel>> getSavedJobs(String userEmail) async {
    try {
      final db = await database;
      final results = await db.query(
        'saved_jobs',
        where: 'user_email = ?',
        whereArgs: [userEmail],
        orderBy: 'id DESC',
      );
      
      return results.map((map) => JobModel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting saved jobs: $e');
      return [];
    }
  }

  Future<bool> isJobSaved(int jobId, String userEmail) async {
    try {
      final db = await database;
      final results = await db.query(
        'saved_jobs',
        where: 'user_email = ? AND job_id = ?',
        whereArgs: [userEmail, jobId],
      );
      
      return results.isNotEmpty;
    } catch (e) {
      print('Error checking if job is saved: $e');
      return false;
    }
  }

  Future<int> deleteSavedJob(int jobId, String userEmail) async {
    try {
      final db = await database;
      return await db.delete(
        'saved_jobs',
        where: 'user_email = ? AND job_id = ?',
        whereArgs: [userEmail, jobId],
      );
    } catch (e) {
      print('Error deleting saved job: $e');
      return 0;
    }
  }

  Future<int> getSavedJobsCount(String userEmail) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM saved_jobs WHERE user_email = ?',
        [userEmail],
      );
      
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting saved jobs count: $e');
      return 0;
    }
  }

  // ==================== DEBUG OPERATIONS ====================
  
  Future<void> printAllUsers() async {
    try {
      final db = await database;
      final users = await db.query('users');
      print('All users in database:');
      for (var user in users) {
        print(user);
      }
    } catch (e) {
      print('Error printing users: $e');
    }
  }

  Future<void> deleteAllUsers() async {
    try {
      final db = await database;
      await db.delete('users');
      print('All users deleted');
    } catch (e) {
      print('Error deleting users: $e');
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}