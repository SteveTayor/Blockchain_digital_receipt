import 'package:flutter/material.dart';
// import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../models/receipt.dart';
import '../repository/receipt_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiptDetailsScreen extends StatefulWidget {
  final String receiptId;
  const ReceiptDetailsScreen({Key? key, required this.receiptId})
      : super(key: key);

  @override
  State<ReceiptDetailsScreen> createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends State<ReceiptDetailsScreen> {
  final double nairaToUsdRate = 1500.0; 
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
     double amountUsd = receipt.amountNaira / nairaToUsdRate;
    final totalAmount = "\$${amountUsd.toStringAsFixed(2)}";
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
                        Text("Amount: ₦${receipt.amountNaira}", style: const TextStyle(fontSize: 18)),
                    // Text("Equivalent in USD: \$${amountUsd.toStringAsFixed(2)}", style: TextStyle(fontSize: 14, color: Colors.grey)),
         
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
                    _buildDetailRow("Payment Method", receipt.encryptedPaymentMethod),
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
                    _buildTransactionRow(transactionHash),
                    if (transactionHash.startsWith("0x"))
                      const Text(
                        "Verified on Ethereum",
                        style: TextStyle(color: Colors.green),
                      ),
                    if (transactionHash.startsWith("0x"))
                      QrImageView(data: transactionHash, size: 200),
                  ],
                ),
              ),
            ),
            // const SizedBox(height: 16),

            // Items
            Card(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    const Text(
                      "Items",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Column(
                      children: receipt.items
                          .map((item) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item.name),
                                    Text("\$${item.price.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          color: Colors.orange.shade600,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    // Notes
                    if (receipt.notes.isNotEmpty) ...[
                      const Text(
                        "Notes",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(receipt.notes),
                      const SizedBox(height: 16),
                    ],

                    // Image
                    if (receipt.imageFile != null) ...[
                      const Text(
                        "Receipt Image",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Image.file(receipt.imageFile!),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 36),
            // Share / Additional actions
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // TODO: Implement share functionality
            //       // shareTransactionDetails(transactionHash);
            //     },
            //     child: const Text("Share Receipt"),
            //   ),
            // ),
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

  Widget _buildTransactionRow(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: value.contains("Insufficient funds ")
          ? Card(
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text("Insufficient funds for transfer on your wallet",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          : Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(label!,
                    //     style: const TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //     )),
                    Expanded(
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
