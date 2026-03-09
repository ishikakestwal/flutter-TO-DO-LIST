import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        dueDate TEXT,
        priority INTEGER,
        color TEXT,
        completed INTEGER,
        createdAt TEXT
      )
    ''');
  }

  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    return db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks({String sortBy = 'recent'}) async {
    final db = await instance.database;
    String orderBy;
    switch (sortBy) {
      case 'priority':
        orderBy = 'priority DESC';
        break;
      case 'dueDate':
        orderBy = 'dueDate ASC';
        break;
      case 'recent':
      default:
        orderBy = 'createdAt DESC';
        break;
    }
    final result = await db.query('tasks', orderBy: orderBy);
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateCompletion(int id, bool isCompleted) async {
    final db = await instance.database;
    return await db.update('tasks', {'completed': isCompleted ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
