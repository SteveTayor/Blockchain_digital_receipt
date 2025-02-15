import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';

class BlockchainService {
  // Replace with your Infura or other Ethereum node URL
  final String rpcUrl = "https://goerli.infura.io/v3/YOUR_INFURA_PROJECT_ID";
  // Replace with a valid private key for testing
  final String privateKey = "YOUR_PRIVATE_KEY";

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
    final transaction = Transaction(
      from: _ownAddress,
      to: _ownAddress,
      value: EtherAmount.zero(),
      data: _encodeData(data),
    );
    // chainId for Goerli is 5; adjust if using another testnet
    final txHash =
        await _client.sendTransaction(_credentials, transaction, chainId: 5);
    return txHash;
  }

  /// Encodes the receipt data as bytes.
  Uint8List _encodeData(String data) {
    return Uint8List.fromList(data.codeUnits);
  }
}
