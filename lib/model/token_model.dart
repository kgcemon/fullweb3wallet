import 'package:web3dart/credentials.dart';

class Token {
  final String name;
  final String symbol;
  late final String balance;
  final String iconUrl;
  final EthereumAddress? contractAddress;

  Token({
    required this.name,
    required this.symbol,
    required this.balance,
    required this.iconUrl,
    this.contractAddress,
  });
}