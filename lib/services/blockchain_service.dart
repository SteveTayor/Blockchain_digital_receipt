import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';

class BlockchainService {
  // Alchemy Sepolia Network URL
  final String rpcUrl =
      "https://eth-sepolia.g.alchemy.com/v2/47_HeGgiNZbZAWCLBs3uN-uyncSsyjGt";

  // Replace with a valid private key for testing
  final String privateKey = "bc54366ea*******32f69527";

  late Web3Client _client;
  late EthPrivateKey _credentials;
  late EthereumAddress _ownAddress;

  BlockchainService() {
    _client = Web3Client(rpcUrl, http.Client());
    _credentials = EthPrivateKey.fromHex(privateKey);
    _ownAddress = _credentials.address;
  }

  /// Logs receipt data on-chain (for demonstration, sending a zero-value tx).
  Future<String> logReceiptOnBlockchain(String data) async {
    try {
      final transaction = Transaction(
        from: _ownAddress,
        to: _ownAddress,
        value: EtherAmount.zero(),
        data: _encodeData(data),
      );
      // Sepolia Chain ID is 11155111
      final txHash = await _client.sendTransaction(
        _credentials,
        transaction,
        chainId: 11155111,
      );
      print("Transaction Hash: $txHash");
      return txHash;
    } catch (e) {
      print("Error sending transaction: $e");
      return "Error: $e";
    }
  }

  /// Encodes the receipt data as bytes.
  Uint8List _encodeData(String data) {
    return Uint8List.fromList(data.codeUnits);
  }

  /// Get latest block number
  Future<int> getLatestBlockNumber() async {
    try {
      final latestBlock = await _client.getBlockNumber();
      print("Latest Block Number: $latestBlock");
      return latestBlock;
    } catch (e) {
      print("Error getting latest block: $e");
      return -1;
    }
  }
}
