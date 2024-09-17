import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../model/token_model.dart';
import '../services/global_abi.dart';

class WalletController extends GetxController {
  final tokens = <Token>[].obs; // List of tokens (native + ERC-20)
  final isLoading = false.obs;  // Loading state
  final totalBalance = '0.00'.obs;  // Total balance
  final activeChain = 'Binance Smart Chain'.obs;  // Active chain name
  final activeRpcUrl = 'https://bsc-dataseed.binance.org'.obs; // Active RPC URL
  final activeNativeCoinName = 'BNB'.obs; // Active native coin name (BNB, ETH, etc.)
  final activeNativeCoinSymbol = 'BNB'.obs; // Active native coin symbol
  final activeExplorerUrl = ''.obs; // Active Explorer URL (Optional)
  late Web3Client _web3client;

  // List of user-added and predefined chains with Explorer URL (optional)
  final List<Map<String, String?>> chains = <Map<String, String?>>[
    // Binance Smart Chain (Predefined)
    {
      'name': 'Binance Smart Chain',
      'rpcUrl': 'https://bsc-dataseed.binance.org',
      'chainId': '56',
      'nativeCoinName': 'Binance Coin',
      'nativeCoinSymbol': 'BNB',
      'explorerUrl': 'https://bscscan.com', // Optional
    },
    // Ethereum (Predefined)
    {
      'name': 'Ethereum',
      'rpcUrl': 'https://rpc.lokibuilder.xyz/wallet', // Replace with your Infura ID
      'chainId': '1',
      'nativeCoinName': 'Ethereum',
      'nativeCoinSymbol': 'ETH',
      'explorerUrl': 'https://etherscan.io', // Optional
    },
  ].obs;

  // Default wallet address (Example, replace with real wallet)
  final EthereumAddress _walletAddress =
  EthereumAddress.fromHex('0x86ed528E743B77A727BadC5e24da4B41Da9839E0');

  @override
  void onInit() {
    super.onInit();
    _initWeb3();
    fetchBalances();
  }

  /// Initialize Web3 Client with the active chain's RPC URL
  void _initWeb3() {
    _web3client = Web3Client(activeRpcUrl.value, http.Client());
  }

  /// Fetch the balances of both the native token and ERC-20 tokens
  Future<void> fetchBalances() async {
    isLoading.value = true;
    try {
      // Fetch native coin balance (BNB, ETH, etc.)
      final nativeCoinBalance = await _getNativeCoinBalance();

      // Predefined tokens for each chain (e.g., USDT, BUSD for BNB Chain)
      final tokensToFetch = activeChain.value == 'Binance Smart Chain'
          ? [
        // USDT on BNB Chain
        {'name': 'Tether USD', 'symbol': 'USDT', 'contract': '0x55d398326f99059fF775485246999027B3197955'},
        // BUSD on BNB Chain
        {'name': 'Binance USD', 'symbol': 'BUSD', 'contract': '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56'},
      ]
          : [
        // USDT on Ethereum
        {'name': 'Tether USD', 'symbol': 'USDT', 'contract': '0xdAC17F958D2ee523a2206206994597C13D831ec7'},
        // DAI on Ethereum
        {'name': 'Dai Stablecoin', 'symbol': 'DAI', 'contract': '0x6B175474E89094C44Da98b954EedeAC495271d0F'},
      ];

      List<Token> tokensList = [
        Token(
          name: activeNativeCoinName.value,  // Dynamic native token name
          symbol: activeNativeCoinSymbol.value,
          balance: nativeCoinBalance,
          iconUrl: _getTokenIconUrl(activeNativeCoinSymbol.value), // Dynamic icon URL
          contractAddress: null, // Native token, no contract address
        ),
      ];

      // Fetch balance for each predefined token
      for (var tokenData in tokensToFetch) {
        final tokenBalance = await _getTokenBalance(
            EthereumAddress.fromHex(tokenData['contract']!));
        tokensList.add(Token(
          name: tokenData['name']!,
          symbol: tokenData['symbol']!,
          balance: tokenBalance,
          iconUrl: _getTokenIconUrl(tokenData['symbol']!),
          contractAddress: EthereumAddress.fromHex(tokenData['contract']!),
        ));
      }

      // Update tokens list
      tokens.value = tokensList;

      _calculateTotalBalance();
    } catch (e) {
      print('Error fetching balances: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get the balance of the native token (BNB, ETH, etc.)
  Future<String> _getNativeCoinBalance() async {
    try {
      final balance = await _web3client.getBalance(_walletAddress);
      final balanceDecimal = balance.getValueInUnit(EtherUnit.ether);
      return balanceDecimal.toStringAsFixed(4);
    } catch (e) {
      print('Error fetching native token balance: $e');
      return '0.00';
    }
  }

  /// Get the balance of an ERC-20 token
  Future<String> _getTokenBalance(EthereumAddress tokenAddress) async {
    try {
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
    } catch (e) {
      print('Error fetching token balance: $e');
      return '0.00';
    }
  }

  /// Calculate the total balance of all tokens in the wallet
  void _calculateTotalBalance() {
    double total = 0;
    for (var token in tokens) {
      total += double.parse(token.balance);
    }
    totalBalance.value = total.toStringAsFixed(2);
  }

  /// Validate and add a custom chain
  String? validateChainInput(String name, String rpcUrl, String chainId) {
    if (name.isEmpty) {
      return 'Chain name cannot be empty';
    }
    if (chains.any((chain) => chain['name'] == name)) {
      return 'Chain $name already exists';
    }
    if (!_isValidRpcUrl(rpcUrl)) {
      return 'Invalid RPC URL';
    }
    if (chainId.isEmpty || !_isNumeric(chainId)) {
      return 'Chain ID must be numeric and not empty';
    }
    return null; // Return null if all validations pass
  }

  /// Helper method to validate if a URL is valid
  bool _isValidRpcUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  /// Helper method to check if a value is numeric
  bool _isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  /// Add a custom chain to the list
  void addCustomChain(String name, String rpcUrl, String chainId, String nativeCoinName, String nativeCoinSymbol, [String? explorerUrl]) {
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
      'nativeCoinName': nativeCoinName,
      'nativeCoinSymbol': nativeCoinSymbol,
      'explorerUrl': explorerUrl ?? '',
    });

    print("Added new chain: $name");
  }

  /// Switch between different chains and fetch balances
  void switchChain(String name) {
    try {
      var selectedChain = chains.firstWhere(
            (chain) => chain['name'] == name,
        orElse: () => chains.first,
      ); // Fallback to the first chain if not found

      activeChain.value = selectedChain['name']!;
      activeRpcUrl.value = selectedChain['rpcUrl']!;
      activeNativeCoinName.value = selectedChain['nativeCoinName']!;
      activeNativeCoinSymbol.value = selectedChain['nativeCoinSymbol']!;
      activeExplorerUrl.value = selectedChain['explorerUrl'] ?? ''; // Set optional Explorer URL

      // Reinitialize the Web3Client with the new RPC URL
      _initWeb3();

      // Fetch balances for the newly active chain
      fetchBalances();

      print('Switched to chain: ${selectedChain['name']}');
    } catch (e) {
      print('Error switching chain: $e');
    }
  }

  /// Add a custom ERC-20 token to the wallet
  void addCustomToken(String name, String symbol, String contractAddress) {
    try {
      final tokenAddress = EthereumAddress.fromHex(contractAddress);

      tokens.add(
        Token(
          name: name,
          symbol: symbol,
          balance: '0.00', // Placeholder until the balance is fetched
          iconUrl: _getTokenIconUrl(symbol), // Dynamic icon based on symbol
          contractAddress: tokenAddress,
        ),
      );

      // Optionally, fetch the balance of the added token immediately
      _getTokenBalance(tokenAddress).then((balance) {
        tokens.firstWhere((token) => token.contractAddress == tokenAddress)
            .balance = balance;
        _calculateTotalBalance(); // Recalculate total balance after adding the token
      });
    } catch (e) {
      print('Error adding custom token: $e');
    }
  }

  /// Helper to return token icon URL based on symbol
  String _getTokenIconUrl(String symbol) {
    return 'https://cryptologos.cc/logos/${symbol.toLowerCase()}-${symbol.toLowerCase()}-logo.png';
  }
}
