import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/wallet_controller.dart';

void showAddChainModal(BuildContext context) {

  final WalletController controller = Get.find();

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  // Function to validate if the Chain ID is numeric
  bool _isNumeric(String value) {
    return double.tryParse(value) != null;
  }


  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController chainNameController = TextEditingController();
  final TextEditingController symbolController = TextEditingController();
  final TextEditingController nodeUrlController = TextEditingController();
  final TextEditingController chainIdController = TextEditingController();
  final TextEditingController explorerUrlController = TextEditingController(); // Optional

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Makes the modal full-screen on smaller devices
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for the keyboard
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Assign the form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chain Name Input
                TextFormField(
                  controller: chainNameController,
                  decoration: const InputDecoration(
                    labelText: 'Chain Name',
                    hintText: 'e.g. Binance Smart Chain',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Chain name cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Symbol Input
                TextFormField(
                  controller: symbolController,
                  decoration: const InputDecoration(
                    labelText: 'Symbol',
                    hintText: 'e.g. BNB',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Symbol cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Node URL Input
                TextFormField(
                  controller: nodeUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Node URL',
                    hintText: 'e.g. https://bsc-dataseed.binance.org',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Node URL cannot be empty';
                    }
                    if (!_isValidUrl(value)) {
                      return 'Please enter a valid Node URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Chain ID Input
                TextFormField(
                  controller: chainIdController,
                  decoration: const InputDecoration(
                    labelText: 'Chain ID',
                    hintText: 'e.g. 56 (for BSC)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Chain ID cannot be empty';
                    }
                    if (!_isNumeric(value)) {
                      return 'Chain ID must be numeric';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Explorer URL Input (Optional)
                TextFormField(
                  controller: explorerUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Explorer URL (Optional)',
                    hintText: 'e.g. https://bscscan.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !_isValidUrl(value)) {
                      return 'Please enter a valid Explorer URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Add Chain Button with validation
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Get the input values
                      String chainName = chainNameController.text;
                      String symbol = symbolController.text;
                      String nodeUrl = nodeUrlController.text;
                      String chainId = chainIdController.text;
                      String explorerUrl = explorerUrlController.text; // Optional field

                      // Validate inputs (without explorer URL)
                      String? validationError = controller.validateChainInput(
                        chainName,
                        nodeUrl,
                        chainId,
                      );

                      if (validationError != null) {
                        Get.snackbar(
                          'Validation Error',
                          validationError,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.5),
                          colorText: Colors.white,
                        );
                      } else {
                        // Add the chain to the list
                        controller.addCustomChain(
                          chainName,
                          nodeUrl,
                          chainId,
                          symbol, // Symbol now passed along with name
                          explorerUrl, // Optional field
                        );
                        Get.back(); // Close the modal after successfully adding the chain
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text('Add Chain'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}