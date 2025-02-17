import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt.dart';
import '../repository/receipt_repository.dart';
import 'add_receipt_screen.dart';
import 'all_receipt_screen.dart';
import 'receipt_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instead of a local list, we fetch from the DB
  late List<Receipt> _futureReceipts;
  // String _selectedCategory = "All";
  // List<String> _categories = [
  //   "All",
  //   "Groceries",
  //   "Electronics",
  //   "Clothing",
  //   "Entertainment"
  // ];
  
  List<String> _categories = [];
  String _selectedCategory = "All";
  @override
  void initState() {
    super.initState();
    _loadCategories();
    _fetchReceipts();
  }

  Future<void> _loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedCategories = prefs.getStringList('categories');
    setState(() {
      _categories = storedCategories?.whereType<String>().toList() ?? [
        "All", "Groceries", "Electronics", "Clothing", "Entertainment"
      ];
    });
  }

  Future<void> _fetchReceipts() async {
    final receipts = await ReceiptRepository.instance.getAllReceipts();
    setState(() {
      _futureReceipts = receipts;
    });
  }
//   void _loadReceipts() {
//     _futureReceipts = ReceiptRepository.instance.getAllReceipts();
//   }

//   Future<void> _loadCategories() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<dynamic>? storedCategories = prefs.getStringList('categories');
  
//   setState(() {
//     _categories = storedCategories?.whereType<String>().toList() ??
//         ["All", "Groceries", "Electronics", "Clothing", "Entertainment"];
//   });
// }

  Future<void> _addNewCategory() async {
    TextEditingController categoryController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Category"),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(hintText: "Category name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (categoryController.text.isNotEmpty) {
                setState(() {
                  _categories = List.from(_categories)
                    ..add(categoryController.text);
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setStringList('categories', _categories);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BlockReceipt',
          style: TextStyle(fontSize: 35, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewCategory,
          ),
        ],
      ),
      body: FutureBuilder<List<Receipt>>(
        future: ReceiptRepository.instance.getAllReceipts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final receipts = snapshot.data ?? [];
          final filteredReceipts = _selectedCategory == "All"
              ? receipts
              : receipts.where((r) => r.category == _selectedCategory).toList();

          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome text
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Welcome back, Alex",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Manage your secure digital receipts",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Receipts Section
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Recent Receipts",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Could show all receipts on a new screen, or do nothing
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) =>
                                          const SeeAllReceiptsPage()));
                                },
                                child: const Text(
                                  "See All",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.teal),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          if (filteredReceipts.isEmpty)
                            const Text("No receipts found.",
                                textAlign: TextAlign.center),
                          
                            Column(
                              spacing: 20,
                              children: filteredReceipts.reversed
                                  .take(4)
                                  .map((r) => _buildReceiptTile(context, r))
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Receipt Statistics
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Receipt Statistics",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildStatsCard(receipts),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Categories
                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_categories.isNotEmpty ? _categories : ["All"])
                        .map((category) {
                      return _CategoryChip(
                        label: category,
                        isSelected: _selectedCategory == category,
                        onSelected: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to add receipt
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddReceiptScreen()),
          );
          // If a new receipt was added, refresh
          if (result == true) {
            setState(() {
              _fetchReceipts();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReceiptTile(BuildContext context, Receipt r) {
    final formattedDate = DateFormat.yMMMd().format(r.date);
    final double amountUsd = r.amountNaira / 1500.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          r.vendorName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text("$formattedDate • ${r.category}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "₦${r.amountNaira.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "\$${amountUsd.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReceiptDetailsScreen(receiptId: r.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(List<Receipt> receipts) {
    double totalSpent = 0;
    for (var r in receipts) {
      totalSpent += r.amountNaira;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 8),
              child: Column(
                children: [
                  Text(
                    receipts.length.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text("Total Receipts"),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
              child: Column(
                children: [
                  Text(
                    "\$${totalSpent.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text("Total Spent"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (label) {
      case "Groceries":
        return Colors.white;
      case "Entertainment":
        return Colors.purple.shade50;
      case "Electronics":
        return Colors.blue.shade50;
      case "Clothing":
        return Colors.green.shade50;
      default:
        return Colors.orange.shade100;
    }
  }

  Color _getTextColor() {
    switch (label) {
      case "Groceries":
        return Colors.deepOrange;
      case "Entertainment":
        return Colors.purple.shade500;
      case "Electronics":
        return Colors.blue.shade700;
      case "Clothing":
        return Colors.green.shade700;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : _getTextColor(),
          ),
        ),
        backgroundColor:
            isSelected ? Colors.deepOrange.shade600 : _getBackgroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
