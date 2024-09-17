import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../model/token_model.dart';
import '../services/global_abi.dart';

class WalletController extends GetxController {
  final tokens = <Token>[].obs;
  final isLoading = false.obs;
  final totalBalance = '0.00'.obs;
  final activeChain = 'Binance Smart Chain'.obs;  // Active Chain name
  final activeRpcUrl = 'https://bsc-dataseed.binance.org'.obs; // Active RPC URL
  late Web3Client _web3client;

  // List to store user-added chains (RPC URL, Chain ID, Name)
  final List<Map<String, String>> chains = <Map<String, String>>[
    {
      'name': 'Binance Smart Chain',
      'rpcUrl': 'https://bsc-dataseed.binance.org',
      'chainId': '56',
    },
  ].obs;

  final EthereumAddress _walletAddress =
  EthereumAddress.fromHex('0x86ed528E743B77A727BadC5e24da4B41Da9839E0');

  @override
  void onInit() {
    super.onInit();
    _initWeb3();
    fetchBalances();
  }

  void _initWeb3() {
    _web3client = Web3Client(activeRpcUrl.value, http.Client());
  }

  Future<void> fetchBalances() async {
    isLoading.value = true;
    try {
      final bnbBalance = await _getNativeCoinBalance();
      final usdtBalance = await _getTokenBalance(
          EthereumAddress.fromHex('0x55d398326f99059fF775485246999027B3197955'));
      final busdBalance = await _getTokenBalance(
          EthereumAddress.fromHex('0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56'));

      tokens.value = [
        Token(
          name: 'Binance Coin',
          symbol: 'BNB',
          balance: bnbBalance,
          iconUrl: 'https://cryptologos.cc/logos/bnb-bnb-logo.png',
          contractAddress: null,
        ),
        Token(
          name: 'Tether USD',
          symbol: 'USDT',
          balance: usdtBalance,
          iconUrl: 'https://cryptologos.cc/logos/tether-usdt-logo.png',
          contractAddress: EthereumAddress.fromHex(
              '0x55d398326f99059fF775485246999027B3197955'),
        ),
        Token(
          name: 'Binance USD',
          symbol: 'BUSD',
          balance: busdBalance,
          iconUrl: 'https://cryptologos.cc/logos/binance-usd-busd-logo.png',
          contractAddress: EthereumAddress.fromHex(
              '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56'),
        ),
      ];

      _calculateTotalBalance();
    } catch (e) {
      print('Error fetching balances: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _getNativeCoinBalance() async {
    final balance = await _web3client.getBalance(_walletAddress);
    final balanceDecimal = balance.getValueInUnit(EtherUnit.ether);
    return balanceDecimal.toStringAsFixed(4);
  }

  Future<String> _getTokenBalance(EthereumAddress tokenAddress) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abiJson), 'Token'),
      tokenAddress,
    );

    final balanceFunction = contract.function('balanceOf');
    final balance = await _web3client.call(
      contract: contract,
      function: balanceFunction,
      params: [_walletAddress],
    );

    final balanceDecimal =
        Decimal.parse(balance[0].toString()) / Decimal.parse('1e18');
    return balanceDecimal.toDouble().toStringAsFixed(4);
  }

  void _calculateTotalBalance() {
    double total = 0;
    for (var token in tokens) {
      total += double.parse(token.balance);
    }
    totalBalance.value = total.toStringAsFixed(2);
  }

  /// Method to add a custom chain with validation
  String? validateChainInput(String name, String rpcUrl, String chainId) {
    // Chain Name Validation
    if (name.isEmpty) {
      return 'Chain name cannot be empty';
    }
    if (chains.any((chain) => chain['name'] == name)) {
      return 'Chain $name already exists';
    }

    // RPC URL Validation
    if (!_isValidRpcUrl(rpcUrl)) {
      return 'Invalid RPC URL';
    }

    // Chain ID Validation
    if (chainId.isEmpty || !_isNumeric(chainId)) {
      return 'Chain ID must be numeric and not empty';
    }

    return null; // If everything is valid, return null
  }

  /// Helper method to validate if a URL is valid
  bool _isValidRpcUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  /// Helper method to check if Chain ID is numeric
  bool _isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  /// Method to add a custom chain with validation
  void addCustomChain(String name, String rpcUrl, String chainId) {
    String? validationError = validateChainInput(name, rpcUrl, chainId);
    if (validationError != null) {
      print(validationError);
      return;
    }

    // Add new chain if validation passes
    chains.add({
      'name': name,
      'rpcUrl': rpcUrl,
      'chainId': chainId,
    });

    print("Added new chain: $name");
  }

  /// Method to switch between chains
  void switchChain(String name) {
    var selectedChain = chains.firstWhere(
          (chain) => chain['name'] == name,
      orElse: () => chains.first,
    ); // Fallback to the first chain if not found

    activeChain.value = selectedChain['name']!;
    activeRpcUrl.value = selectedChain['rpcUrl']!;
    _initWeb3();  // Re-initialize the Web3Client with the new RPC URL

    fetchBalances();  // Refresh balances for the new chain
  }

  /// Example method to add a custom token
  void addCustomToken(String name, String symbol, String contractAddress) {
    final tokenAddress = EthereumAddress.fromHex(contractAddress);

    tokens.add(
      Token(
        name: name,
        symbol: symbol,
        balance: '0.00', // Fetch balance after adding
        iconUrl: 'https://via.placeholder.com/50', // Placeholder for token icon
        contractAddress: tokenAddress,
      ),
    );

    // Optionally, you can call _getTokenBalance to fetch the balance of the added token.
  }
}
