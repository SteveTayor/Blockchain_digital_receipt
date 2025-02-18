import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<String> _categories = [];
  String _selectedCategory = "Groceries";

  initState () {
    super.initState();
    _loadCategories();
  }
  Future<void> _loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedCategories = prefs.getStringList('categories');
    setState(() {
      _categories = storedCategories?.whereType<String>().toList() ?? [];
    });
  }
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
      amountNaira: amount,
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
        "PaymentMethod: ${newReceipt.decryptedPaymentMethod}\n"
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
        title: const Text("Add New Receipt",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange.shade600,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          child: _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 26, vertical: 16),
                          child: Column(
                            spacing: 24,
                            children: [
                              SizedBox(height: 18),
                              // Vendor Name
                              TextFormField(
                                controller: _vendorController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.orange.shade300,
                                        width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.orange.shade50,
                                  labelText: "Vendor Name",
                                  hintText:
                                      "Enter vendor name (e.g., Whole Foods)",
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a vendor name";
                                  }
                                  return null;
                                },
                              ),

                              // Amount
                              TextFormField(
                                controller: _amountController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.orange.shade300,
                                        width: 2),
                                  ),
                                  fillColor: Colors.orange.shade50,
                                  labelText: "Amount",
                                  hintText: "₦0.00",
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
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

                              // Transaction Date
                              InkWell(
                                onTap: _selectDate,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.orange.shade300,
                                          width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.orange.shade50,
                                    labelText: "Transaction Date",
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(dateFormatted),
                                      const Icon(Icons.calendar_today),
                                    ],
                                  ),
                                ),
                              ),

                              // Category
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.orange.shade300,
                                        width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.orange.shade50,
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

                              // Payment Method
                              TextFormField(
                                controller: _paymentMethodController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.orange.shade300,
                                        width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.orange.shade50,
                                  labelText: "Payment Method",
                                  hintText: "e.g;bank transfer, card..",
                                ),
                              ),

                              // Store Location
                              TextFormField(
                                controller: _storeLocationController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.orange.shade300,
                                        width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.orange.shade50,
                                  labelText: "Store Location",
                                  hintText: "123 Market St",
                                ),
                              ),

                              // Notes
                              TextFormField(
                                controller: _notesController,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.orange.shade300,
                                        width: 2),
                                  ),
                                  fillColor: Colors.orange.shade50,
                                  labelText: "Notes (Optional)",
                                  hintText: "Add any additional details",
                                ),
                                maxLines: 2,
                              ),

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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.camera_alt,
                                                color: Colors.grey),
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
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _submitReceipt,
                            child: const Text("Submit Receipt"),
                          ),
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
