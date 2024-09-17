import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mind_web3_test/controller/wallet_controller.dart';

class AddTokenPage extends StatelessWidget {
  final WalletController controller = Get.find();

  final TextEditingController tokenNameController = TextEditingController();
  final TextEditingController tokenSymbolController = TextEditingController();
  final TextEditingController contractAddressController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  AddTokenPage({super.key});

  // Function to validate if the contract address is a valid Ethereum/BNB address
  bool _isValidContractAddress(String value) {
    return value.isNotEmpty && value.startsWith('0x') && value.length == 42;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Token to ${controller.activeChain.value}'),
        backgroundColor: const Color(0xFF0E1121),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key for validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Token Name Input
              TextFormField(
                controller: tokenNameController,
                decoration: const InputDecoration(
                  labelText: 'Token Name',
                  hintText: 'e.g. Tether USD',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Token name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Token Symbol Input
              TextFormField(
                controller: tokenSymbolController,
                decoration: const InputDecoration(
                  labelText: 'Token Symbol',
                  hintText: 'e.g. USDT',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Token symbol cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Contract Address Input
              TextFormField(
                controller: contractAddressController,
                decoration: const InputDecoration(
                  labelText: 'Contract Address',
                  hintText: 'e.g. 0x...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contract address cannot be empty';
                  }
                  if (!_isValidContractAddress(value)) {
                    return 'Invalid contract address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Add Token Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Get the input values
                    String tokenName = tokenNameController.text;
                    String tokenSymbol = tokenSymbolController.text;
                    String contractAddress = contractAddressController.text;

                    // Add the token to the active chain's token list
                    controller.addCustomToken(tokenName, tokenSymbol, contractAddress);

                    // Notify user and close the page after adding the token
                    Get.snackbar(
                      'Success!',
                      '$tokenName has been added to ${controller.activeChain.value}.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                    );

                    // Close the screen after successfully adding the token
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('Add Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
