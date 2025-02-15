import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/receipt.dart';
import '../models/receipt_item.dart';
import '../repository/receipt_repository.dart';
import '../services/blockchain_service.dart';

class AddReceiptScreen extends StatefulWidget {
  const AddReceiptScreen({Key? key}) : super(key: key);

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vendorController = TextEditingController();
  final _amountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _storeLocationController = TextEditingController();
  final _notesController = TextEditingController();
  final _categories = ["Groceries", "Electronics", "Clothing", "Entertainment"];
  String _selectedCategory = "Groceries";

  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  bool _isSubmitting = false;

  final _blockchainService = BlockchainService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery); // or camera
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitReceipt() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Create a random ID for the receipt
    final randomId = "BR-${Random().nextInt(999999)}";

    final vendor = _vendorController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final paymentMethod = _paymentMethodController.text.trim();
    final storeLocation = _storeLocationController.text.trim();
    final notes = _notesController.text.trim();

    // For demonstration, let's add a single item that matches the total amount
    final items = <ReceiptItem>[
      ReceiptItem(name: "Total Purchase", price: amount),
    ];

    // Construct the new receipt
    final newReceipt = Receipt(
      id: randomId,
      vendorName: vendor,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      paymentMethod: paymentMethod.isEmpty ? "Visa **** 4032" : paymentMethod,
      storeLocation: storeLocation.isEmpty ? "123 Market St" : storeLocation,
      notes: notes,
      imageFile: _selectedImage,
      items: items,
    );

    // Prepare a string to log on the blockchain
    final receiptData = "ReceiptID: $randomId\n"
        "Vendor: $vendor\n"
        "Amount: \$${amount.toStringAsFixed(2)}\n"
        "Date: ${DateFormat.yMd().format(_selectedDate)}\n"
        "Category: $_selectedCategory\n"
        "PaymentMethod: ${newReceipt.paymentMethod}\n"
        "StoreLocation: ${newReceipt.storeLocation}\n"
        "Notes: $notes\n";

    try {
      final txHash =
          await _blockchainService.logReceiptOnBlockchain(receiptData);
      newReceipt.blockchainHash = txHash;
    } catch (e) {
      newReceipt.blockchainHash = "ERROR: $e";
    }

    // Save to the DB via the repository
    await ReceiptRepository.instance.addReceipt(newReceipt);

    setState(() {
      _isSubmitting = false;
    });

    // Return true to indicate a new receipt was added
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _amountController.dispose();
    _paymentMethodController.dispose();
    _storeLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat.yMd().format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Receipt"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Vendor Name
                      TextFormField(
                        controller: _vendorController,
                        decoration: const InputDecoration(
                          labelText: "Vendor Name",
                          hintText: "Enter vendor name (e.g., Whole Foods)",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a vendor name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: "Amount",
                          hintText: "\$0.00",
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter an amount";
                          }
                          if (double.tryParse(value) == null) {
                            return "Enter a valid number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Transaction Date
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Transaction Date",
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateFormatted),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Category",
                        ),
                        value: _selectedCategory,
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Payment Method
                      TextFormField(
                        controller: _paymentMethodController,
                        decoration: const InputDecoration(
                          labelText: "Payment Method",
                          hintText: "Visa **** 4032",
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Store Location
                      TextFormField(
                        controller: _storeLocationController,
                        decoration: const InputDecoration(
                          labelText: "Store Location",
                          hintText: "123 Market St",
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: "Notes (Optional)",
                          hintText: "Add any additional details",
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      // Receipt Image
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.camera_alt, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text("Tap to add receipt photo"),
                                  ],
                                )
                              : Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitReceipt,
                          child: const Text("Submit Receipt"),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
