import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mind_web3_test/controller/wallet_controller.dart';

class AddChainPage extends StatelessWidget {
  final WalletController controller = Get.find();

  final TextEditingController chainNameController = TextEditingController();
  final TextEditingController rpcUrlController = TextEditingController();
  final TextEditingController chainIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  AddChainPage({super.key});

  // Function to validate the RPC URL
  bool _isValidRpcUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  // Function to validate if the Chain ID is numeric
  bool _isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Chains'),
        backgroundColor: const Color(0xFF0E1121),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form for adding a new chain
            Form(
              key: _formKey, // Assign the form key for validation
              child: Column(
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

                  // RPC URL Input
                  TextFormField(
                    controller: rpcUrlController,
                    decoration: const InputDecoration(
                      labelText: 'RPC URL',
                      hintText: 'e.g. https://bsc-dataseed.binance.org',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'RPC URL cannot be empty';
                      }
                      if (!_isValidRpcUrl(value)) {
                        return 'Please enter a valid RPC URL';
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
                  const SizedBox(height: 20),

                  // Add Chain Button with validation
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Get the input values
                        String chainName = chainNameController.text;
                        String rpcUrl = rpcUrlController.text;
                        String chainId = chainIdController.text;

                        // Validate inputs
                        String? validationError = controller.validateChainInput(
                          chainName,
                          rpcUrl,
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
                          controller.addCustomChain(chainName, rpcUrl, chainId);
                          Get.back(); // Close the modal after successfully adding the chain
                        }
                      }
                    },
                    child: const Text('Add Chain'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // List of added chains
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.chains.length,
                itemBuilder: (context, index) {
                  var chain = controller.chains[index];
                  bool isActive = chain['name'] == controller.activeChain.value;

                  return Card(
                    color: isActive ? Colors.blueGrey.withOpacity(0.2) : null,
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        chain['name']!,
                        style: TextStyle(
                          color: isActive ? Colors.blue : Colors.white,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text('Chain ID: ${chain['chainId']}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          if (!isActive) {
                            controller.switchChain(chain['name']!); // Activate the selected chain
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? Colors.grey : Colors.blue,
                        ),
                        child: isActive
                            ? const Text('Active')
                            : const Text('Set Active'),
                      ),
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}
