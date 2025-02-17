import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt.dart';
import '../repository/receipt_repository.dart';
import 'add_receipt_screen.dart';
import 'receipt_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instead of a local list, we fetch from the DB
  late Future<List<Receipt>> _futureReceipts;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  void _loadReceipts() {
    _futureReceipts = ReceiptRepository.instance.getAllReceipts();
  }

  @override  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlockReceipt', style: TextStyle(fontSize: 35,color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade600,
      ),
      body: FutureBuilder<List<Receipt>>(
        future: _futureReceipts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final receipts = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
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
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Recent Receipts",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Could show all receipts on a new screen, or do nothing
                                },
                                child: const Text(
                                  "See All",
                                  style: TextStyle(fontSize: 16, color: Colors.teal),
                                ),
                              ),
                            ],
                          ),
                  const SizedBox(height: 15),
                  if (receipts.isEmpty)
                    const Text("No recent receipts.", textAlign: TextAlign.center,)
                  else
                    Column(
                      spacing: 20,
                      children: receipts
                          .reversed // show newest first
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Receipt Statistics",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    children: const [
                      _CategoryChip(label: "Groceries"),
                      _CategoryChip(label: "Electronics"),
                      _CategoryChip(label: "Clothing"),
                      _CategoryChip(label: "Entertainment"),
                    ],
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
              _loadReceipts();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReceiptTile(BuildContext context, Receipt r) {
    final formattedDate = DateFormat.yMMMd().format(r.date);
    return Container(
      
      decoration: BoxDecoration(
       color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(r.vendorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600,), ),
        subtitle: Text("$formattedDate "),
        trailing: Text("\$${r.amountNaira.toStringAsFixed(3)}", style: const TextStyle(color:Colors.deepOrange ,fontSize: 14, fontWeight: FontWeight.w400),),
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
          Container(decoration: BoxDecoration(
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
  const _CategoryChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style:  TextStyle(fontWeight: FontWeight.bold,color: label == "Groceries" ? Colors.deepOrange : label == "Entertainment" ? Colors.purple.shade500 : Colors.black,),),
      backgroundColor: label == "Groceries" ? Colors.white : label == "Entertainment" ? Colors.purple.shade50 : Colors.orange.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
