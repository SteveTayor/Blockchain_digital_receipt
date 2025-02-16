import 'package:flutter/material.dart';
// import 'package:flutter_share_me/flutter_share_me.dart';
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
//   void shareTransactionDetails(String txHash) {
//   final shareText = 'Check out this blockchain transaction: $txHash\n'
//       'You can verify it on the Ethereum Sepolia testnet explorer.';
//   Share.share(shareText, subject: 'Blockchain Receipt');
// }
// Future<void> shareTransactionDetails(String txHash) async {
//   String shareText = 'Check out this blockchain transaction: $txHash\n'
//       'You can verify it on the Ethereum Sepolia testnet explorer.';

//   FlutterShareMe flutterShareMe = FlutterShareMe();

  // Share to system's native share dialog
  // await flutterShareMe.shareToSystem(msg: shareText);
// }
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
        title: const Text("Receipt Details",
            style: TextStyle(fontSize: 30, color: Colors.white)),
        backgroundColor: Colors.deepOrange.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        child: Column(
          spacing: 24,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor and Amount
            Card(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          receipt.vendorName,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          totalAmount,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    Text(dateString,
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),

            // Transaction Details
            Card(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  spacing: 8,
                  children: [
                    const Text(
                      "Transaction Details",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    _buildDetailRow("Receipt ID", receipt.id),
                    _buildDetailRow("Payment Method", receipt.paymentMethod),
                    _buildDetailRow("Store Location", receipt.storeLocation),
                    _buildDetailRow("Category", receipt.category),
                  ],
                ),
              ),
            ),

            // Blockchain Verification
            Card(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  spacing: 16,
                  children: [
                    const Text(
                      "Blockchain Verification",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Text(
                      "Transaction Hash",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    _buildDetailRow("", transactionHash),
                    if (transactionHash.startsWith("0x"))
                      const Text(
                        "Verified on Ethereum",
                        style: TextStyle(color: Colors.green),
                      ),
                  ],
                ),
              ),
            ),
            // const SizedBox(height: 16),

            // Items
            Card(
              
              child: Column(
                spacing: 10,
                children: [
                  const Text(
                    "Items",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
              
              
                ],
              ),
            ),

            // Share / Additional actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement share functionality
                  // shareTransactionDetails(transactionHash);
                },
                child: const Text("Share Receipt"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String? label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
