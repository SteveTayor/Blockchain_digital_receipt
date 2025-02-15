import 'package:sqflite/sqflite.dart';
import '../models/receipt.dart';
import '../services/database_helper.dart';

class ReceiptRepository {
  // Singleton pattern
  ReceiptRepository._privateConstructor();
  static final ReceiptRepository instance = ReceiptRepository._privateConstructor();

  late Database _db;

  Future<void> initializeDB() async {
    _db = await DatabaseHelper.instance.database;
  }

  // Insert a new receipt
  Future<void> addReceipt(Receipt receipt) async {
    await _db.insert(
      'receipts',
      receipt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all receipts
  Future<List<Receipt>> getAllReceipts() async {
    final List<Map<String, dynamic>> maps = await _db.query('receipts');
    return maps.map((map) => Receipt.fromMap(map)).toList();
  }

  // Fetch a single receipt by ID
  Future<Receipt?> getReceiptById(String id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Receipt.fromMap(maps.first);
    }
    return null;
  }

  // Update a receipt
  Future<void> updateReceipt(Receipt receipt) async {
    await _db.update(
      'receipts',
      receipt.toMap(),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }

  // Delete a receipt
  Future<void> deleteReceipt(String id) async {
    await _db.delete(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
