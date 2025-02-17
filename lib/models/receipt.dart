import 'dart:io';
import 'dart:convert';

import '../services/encryption_helper.dart';
import 'receipt_item.dart';

class Receipt {
  final String id;
  final String vendorName;
  final double amountNaira;
  final DateTime date;
  final String category;
  final String encryptedPaymentMethod;
  final String storeLocation;
  final String notes;
  final File? imageFile;
  final List<ReceiptItem> items;
  String? blockchainHash;

  Receipt({
    required this.id,
    required this.vendorName,
    required this.amountNaira,
    required this.date,
    required this.category,
    required String paymentMethod,
    required this.storeLocation,
    required this.notes,
    required this.imageFile,
    required this.items,
    this.blockchainHash,
  }) : encryptedPaymentMethod = EncryptionHelper.encryptText(paymentMethod);

  String get decryptedPaymentMethod => EncryptionHelper.decryptText(encryptedPaymentMethod);
  double get amountUsd => amountNaira / 1500.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorName': vendorName,
      'amountNaira': amountNaira,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'encryptedPaymentMethod': encryptedPaymentMethod,
      'storeLocation': storeLocation,
      'notes': notes,
      'imagePath': imageFile?.path ?? '',
      'blockchainHash': blockchainHash ?? '',
    };
  }

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
      amountNaira: (map['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      category: map['category'] as String,
      paymentMethod: EncryptionHelper.decryptText(map['encryptedPaymentMethod']),
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
  

