import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = 'blockreceipt.db';
  static const _dbVersion = 1;
  static Database? _database;

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, _dbName);

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  // Create tables
  FutureOr<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE receipts (
      id TEXT PRIMARY KEY,
      vendorName TEXT,
      amount REAL,
      amountNaira REAL,  -- Add this line
      date INTEGER,
      category TEXT,
      encryptedPaymentMethod TEXT,
      storeLocation TEXT,
      notes TEXT,
      imagePath TEXT,
      itemsJson TEXT,
      blockchainHash TEXT
    )
  ''');
}

}