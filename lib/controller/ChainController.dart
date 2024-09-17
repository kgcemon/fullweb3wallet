import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'wallet_controller.dart'; // Import the WalletController

class ChainController extends GetxController {
  final activeChain = 'Binance Smart Chain'.obs;  // Active chain name
  final activeRpcUrl = 'https://bsc-dataseed.binance.org'.obs; // Active RPC URL
  final activeNativeCoinName = 'BNB'.obs; // Active native coin name (BNB, ETH, etc.)
  final activeNativeCoinSymbol = 'BNB'.obs; // Active native coin symbol
  final activeExplorerUrl = ''.obs; // Active Explorer URL (Optional)

  final chains = <Map<String, String?>>[].obs; // List of user-added/predefined chains
  final box = GetStorage(); // GetStorage instance for local storage

  @override
  void onInit() {
    super.onInit();
    loadChainsFromStorage(); // Load chains from local storage on init
  }

  /// Load chains from local storage or initialize with default chains
  void loadChainsFromStorage() {
    List<dynamic>? storedChains = box.read<List<dynamic>>('chains');
    if (storedChains != null && storedChains.isNotEmpty) {
      // Populate chains from local storage
      for (var chain in storedChains) {
        chains.add(Map<String, String?>.from(chain));
      }
    } else {
      // Initialize with predefined chains if no chains in storage
      chains.addAll([
        {
          'name': 'Binance Smart Chain',
          'rpcUrl': 'https://bsc-dataseed.binance.org',
          'chainId': '56',
          'nativeCoinName': 'Binance Coin',
          'nativeCoinSymbol': 'BNB',
          'explorerUrl': 'https://bscscan.com', // Optional
        }
      ]);
      saveChainsToStorage(); // Save default chains to storage
    }
  }

  /// Save chains to local storage
  void saveChainsToStorage() {
    box.write('chains', chains.toList());
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

  /// Add a custom chain to the list and save to local storage
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

    saveChainsToStorage(); // Save the updated chain list to local storage

    print("Added new chain: $name");
  }

  /// Switch between different chains and notify WalletController
  void switchChain(String name) {
    try {
      var selectedChain = chains.firstWhere(
            (chain) => chain['name'] == name,
        orElse: () => chains.first,
      ); // Fallback to the first chain if not found

      // Update active chain info
      activeChain.value = selectedChain['name']!;
      activeRpcUrl.value = selectedChain['rpcUrl']!;
      activeNativeCoinName.value = selectedChain['nativeCoinName']!;
      activeNativeCoinSymbol.value = selectedChain['nativeCoinSymbol']!;
      activeExplorerUrl.value = selectedChain['explorerUrl'] ?? ''; // Set optional Explorer URL

      // Notify WalletController to re-fetch balances on the new chain
      Get.find<WalletController>().onChainSwitched();  // Notify WalletController

      print('Switched to chain: ${selectedChain['name']}');
    } catch (e) {
      print('Error switching chain: $e');
    }
  }
}
