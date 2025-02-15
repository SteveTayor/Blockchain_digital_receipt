import 'dart:io';
import 'dart:convert';

import 'receipt_item.dart';

class Receipt {
  final String id;
  final String vendorName;
  final double amount;
  final DateTime date;
  final String category;
  final String paymentMethod;
  final String storeLocation;
  final String notes;
  final File? imageFile;     // Local image file reference
  final List<ReceiptItem> items;

  String? blockchainHash;    // Set after blockchain logging

  Receipt({
    required this.id,
    required this.vendorName,
    required this.amount,
    required this.date,
    required this.category,
    required this.paymentMethod,
    required this.storeLocation,
    required this.notes,
    required this.imageFile,
    required this.items,
    this.blockchainHash,
  });

  /// Convert to Map for storing in DB
  /// We’ll store imageFile as a path (String), items as a JSON string, date as millisecondsSinceEpoch.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorName': vendorName,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'paymentMethod': paymentMethod,
      'storeLocation': storeLocation,
      'notes': notes,
      'imagePath': imageFile?.path ?? '',
      'itemsJson': jsonEncode(items.map((e) => e.toMap()).toList()),
      'blockchainHash': blockchainHash ?? '',
    };
  }

  /// Create a Receipt object from a DB row (Map)
  factory Receipt.fromMap(Map<String, dynamic> map) {
    // Convert itemsJson back to a list of ReceiptItem
    final itemsJsonString = map['itemsJson'] as String? ?? '[]';
    final itemsList = (jsonDecode(itemsJsonString) as List)
        .map((e) => ReceiptItem.fromMap(e))
        .toList();

    final imagePath = map['imagePath'] as String? ?? '';
    File? imageFile;
    if (imagePath.isNotEmpty) {
      imageFile = File(imagePath);
    }

    return Receipt(
      id: map['id'] as String,
      vendorName: map['vendorName'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      category: map['category'] as String,
      paymentMethod: map['paymentMethod'] as String,
      storeLocation: map['storeLocation'] as String,
      notes: map['notes'] as String,
      imageFile: imageFile,
      items: itemsList,
      blockchainHash: (map['blockchainHash'] as String).isEmpty
          ? null
          : map['blockchainHash'] as String,
    );
  }
}
