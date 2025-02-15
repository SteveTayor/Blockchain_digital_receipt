import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../models/receipt.dart';
import '../repository/receipt_repository.dart';

class ReceiptDetailsScreen extends StatefulWidget {
  final String receiptId;
  const ReceiptDetailsScreen({Key? key, required this.receiptId})
      : super(key: key);

  @override
  State<ReceiptDetailsScreen> createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends State<ReceiptDetailsScreen> {
  Receipt? _receipt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    final repo = ReceiptRepository.instance;
    final r = await repo.getReceiptById(widget.receiptId);
    setState(() {
      _receipt = r;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_receipt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Receipt Details")),
        body: const Center(child: Text("Receipt not found.")),
      );
    }

    final receipt = _receipt!;
    final dateString =
        "${DateFormat.yMMMMd().format(receipt.date)} • ${DateFormat('h:mm a').format(receipt.date)}";
    final totalAmount = "\$${receipt.amount.toStringAsFixed(2)}";
    final transactionHash = receipt.blockchainHash ?? "Pending or Error";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  receipt.vendorName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totalAmount,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(dateString, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            // Transaction Details
            const Text(
              "Transaction Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildDetailRow("Receipt ID", receipt.id),
            _buildDetailRow("Payment Method", receipt.paymentMethod),
            _buildDetailRow("Store Location", receipt.storeLocation),
            _buildDetailRow("Category", receipt.category),
            const SizedBox(height: 16),

            // Blockchain Verification
            const Text(
              "Blockchain Verification",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildDetailRow("Transaction Hash", transactionHash),
            if (transactionHash.startsWith("0x"))
              const Text(
                "Verified on Ethereum",
                style: TextStyle(color: Colors.green),
              ),
            const SizedBox(height: 16),

            // Items
            const Text(
              "Items",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Column(
              children: receipt.items
                  .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.name),
                            Text("\$${item.price.toStringAsFixed(2)}"),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Notes
            if (receipt.notes.isNotEmpty) ...[
              const Text(
                "Notes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(receipt.notes),
              const SizedBox(height: 16),
            ],

            // Image
            if (receipt.imageFile != null) ...[
              const Text(
                "Receipt Image",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Image.file(receipt.imageFile!),
              const SizedBox(height: 16),
            ],

            // Share / Additional actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement share functionality if desired
                },
                child: const Text("Share Receipt"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
