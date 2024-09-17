import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../model/token_model.dart';
import '../services/global_abi.dart';
import 'ChainController.dart';

class WalletController extends GetxController {
  final tokens = <Token>[].obs; // List of tokens (native + ERC-20)
  final isLoading = false.obs;  // Loading state
  final totalBalance = '0.00'.obs;  // Total balance
  late Web3Client _web3client;

  // Default wallet address (Example, replace with real wallet)
  final EthereumAddress _walletAddress = EthereumAddress.fromHex('0x86ed528E743B77A727BadC5e24da4B41Da9839E0');

  final ChainController chainController = Get.put(ChainController());  // Find the ChainController instance

  @override
  void onInit() {
    super.onInit();
    _initWeb3();   // Initialize Web3 Client
    fetchBalances(); // Fetch balances for default chain
  }

  /// Initialize Web3 Client with the active chain's RPC URL from ChainController
  void _initWeb3() {
    _web3client = Web3Client(chainController.activeRpcUrl.value, http.Client());
  }

  /// Fetch the balances of both the native token and ERC-20 tokens
  Future<void> fetchBalances() async {
    isLoading.value = true;
    try {
      // Fetch native coin balance (BNB, ETH, etc.)
      final nativeCoinBalance = await _getNativeCoinBalance();

      // Predefined tokens for each chain
      final tokensToFetch = chainController.activeChain.value == 'Binance Smart Chain'
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
          name: chainController.activeNativeCoinName.value,  // Dynamic native token name
          symbol: chainController.activeNativeCoinSymbol.value,
          balance: nativeCoinBalance,
          iconUrl: _getTokenIconUrl(chainController.activeNativeCoinSymbol.value), // Dynamic icon URL
          contractAddress: null, // Native token, no contract address
        ),
      ];

      // Fetch balance for each predefined token
      for (var tokenData in tokensToFetch) {
        final tokenBalance = await _getTokenBalance(EthereumAddress.fromHex(tokenData['contract']!));
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
      final balanceDecimal = Decimal.parse(balance[0].toString()) / Decimal.parse('1e18');
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

  /// Re-fetch balances when the active chain is switched
  void onChainSwitched() {
    _initWeb3();  // Reinitialize Web3Client with new RPC URL
    fetchBalances();  // Fetch the token balances for the new chain
  }

  /// Helper to return token icon URL based on symbol
  String _getTokenIconUrl(String symbol) {
    return 'https://cryptologos.cc/logos/${symbol.toLowerCase()}-${symbol.toLowerCase()}-logo.png';
  }
}
