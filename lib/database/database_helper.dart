import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'budget_bites.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cuisine TEXT NOT NULL,
        venue TEXT NOT NULL,
        estimated_price REAL NOT NULL
      )
    ''');
      },
    );
  }

  Future<int> insertMeal(Meal meal) async {
    final db = await _openDatabase();

    final id = await db.insert(
      'meals',
      meal.toMap()..remove('id'),
    );

    return id;
  }

  Future<List<Meal>> getAllMeals() async {
    final db = await _openDatabase();

    final maps = await db.query(
      'meals',
      orderBy: 'id DESC',
    );

    return maps.map((map) => Meal.fromMap(map)).toList();
  }
}