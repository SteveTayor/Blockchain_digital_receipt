import 'package:flutter/material.dart';
import '../models/receipt.dart';
import '../repository/receipt_repository.dart';
import 'receipt_details_screen.dart';

class SeeAllReceiptsPage extends StatefulWidget {
  const SeeAllReceiptsPage({Key? key}) : super(key: key);

  @override
  State<SeeAllReceiptsPage> createState() => _SeeAllReceiptsPageState();
}

class _SeeAllReceiptsPageState extends State<SeeAllReceiptsPage> {
  late Future<List<Receipt>> _futureReceipts;
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  void _loadReceipts() {
    _futureReceipts = ReceiptRepository.instance.getAllReceipts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Receipts', style: TextStyle(fontSize: 35,color: Colors.white),),
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
          final filteredReceipts = _selectedCategory == "All"
              ? receipts
              : receipts
                  .where((r) => r.category == _selectedCategory)
                  .toList();

          return Padding(
            padding: const EdgeInsets.symmetric(),
            child: Column(
              spacing: 20,
              children: [
                _buildCategoryDropdown(receipts),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredReceipts.length,
                    itemBuilder: (context, index) {
                      final receipt = filteredReceipts[index];
                      return Card(
                        child: ListTile(
                          title: Text(receipt.vendorName),
                          subtitle: Text(
                              "₦${receipt.amountNaira.toStringAsFixed(2)} • ${receipt.category}"),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReceiptDetailsScreen(
                                  receiptId: receipt.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(List<Receipt> receipts) {
    final categories = {"All", ...receipts.map((r) => r.category)}.toList();
    return DropdownButton<String>(
      value: _selectedCategory,
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }
}
