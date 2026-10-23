import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/meal.dart';
import '../models/purchase_log.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'budget_bites.db');

    return await openDatabase(
      path,
      version: 2,
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
        await db.execute('''
  CREATE TABLE purchase_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mealId INTEGER NOT NULL,
    purchasedAt TEXT NOT NULL,
    actualPriceMinor INTEGER NOT NULL,
    FOREIGN KEY (mealId) REFERENCES meals(id)
  )
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
      CREATE TABLE purchase_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mealId INTEGER NOT NULL,
        purchasedAt TEXT NOT NULL,
        actualPriceMinor INTEGER NOT NULL,
        FOREIGN KEY (mealId) REFERENCES meals(id)
      )
    ''');
        }
      },
    );
  }

  Future<int> insertMeal(Meal meal) async {
    final db = await _openDatabase();

    final id = await db.insert('meals', meal.toMap()..remove('id'));

    return id;
  }

  Future<List<Meal>> getAllMeals() async {
    final db = await _openDatabase();

    final maps = await db.query('meals', orderBy: 'id DESC');

    return maps.map((map) => Meal.fromMap(map)).toList();
  }

  Future<int> updateMeal(Meal meal) async {
    final db = await _openDatabase();

    return await db.update(
      'meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<int> deleteMeal(int id) async {
    final db = await _openDatabase();

    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertPurchase(PurchaseLog purchase) async {
    final db = await _openDatabase();

    final id = await db.insert(
      'purchase_logs',
      purchase.toMap()..remove('id'),
    );

    return id;
  }

  Future<List<PurchaseLog>> getAllPurchases() async {
    final db = await _openDatabase();

    final maps = await db.query(
      'purchase_logs',
      orderBy: 'purchasedAt DESC, id DESC',
    );

    return maps.map((map) => PurchaseLog.fromMap(map)).toList();
  }

  Future<int> updatePurchase(PurchaseLog purchase) async {
    final db = await _openDatabase();

    return await db.update(
      'purchase_logs',
      purchase.toMap(),
      where: 'id = ?',
      whereArgs: [purchase.id],
    );
  }

  Future<int> deletePurchase(int id) async {
    final db = await _openDatabase();

    return await db.delete(
      'purchase_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
