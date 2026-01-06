import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'job.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    print(databasesPath);
    String path = join(databasesPath, 'jobdatabase.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        companyName TEXT,
        jobTitle TEXT,
        jobDescription TEXT,
        minAnnualWage INTEGAR CHECK(minAnnualWage > 0),
        maxAnnualWage INTEGAR CHECK(maxAnnualWage > 0),
        location TEXT,
        jobType TEXT CHECK(jobType IN ('InPerson', 'Remote', 'Hybrid')),
        dateSinceEpoch INTEGAR CHECK(dateSinceEpoch > 0),
        status TEXT CHECK(status IN ('InProgress', 'Rejected', 'Ghosted', 'Completed')),
        interviewsCompleted INTEGAR CHECK(interviewsCompleted >= 0)
      )
    ''');
  }

  Future<int> insertJob(Job job) async {
    Database db = await instance.db;
    return await db.insert('jobs', job.toMap());
  }

  Future<List<Map<String, dynamic>>> queryAllJobs() async {
    Database db = await instance.db;
    return await db.query('jobs');
  }

  Future<int> updateJob(Job job) async {
    Database db = await instance.db;
    return await db
        .update('jobs', job.toMap(), where: 'id = ?', whereArgs: [job.id]);
  }

  Future<int> deleteJob(int id) async {
    Database db = await instance.db;
    return await db.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }
}
