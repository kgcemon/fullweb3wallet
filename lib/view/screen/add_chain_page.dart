import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mind_web3_test/controller/wallet_controller.dart';

import '../widget/addChainModal.dart';

class AddChainPage extends StatefulWidget {
  const AddChainPage({super.key});

  @override
  AddChainPageState createState() => AddChainPageState();
}

class AddChainPageState extends State<AddChainPage> {
  final WalletController controller = Get.find();
  final TextEditingController searchController = TextEditingController();

  // This observable will store the filtered chains for display
  RxList<Map<String, String?>> filteredChains = <Map<String, String?>>[].obs;


  @override
  void initState() {
    super.initState();

    // Initially, all chains are shown
    filteredChains.value = controller.chains;

    // Listen to the search input and filter the chain list
    searchController.addListener(() {
      filterChains(searchController.text);
    });
  }

  // Function to filter chains based on the search query
  void filterChains(String query) {
    if (query.isEmpty) {
      // If search query is empty, show all chains
      filteredChains.value = controller.chains;
    } else {
      // Filter chains by name
      filteredChains.value = controller.chains
          .where((chain) => chain['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
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
            // Search Bar
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Chain',
                hintText: 'Enter chain name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // List of added chains (filtered by search query)
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: filteredChains.length,
                itemBuilder: (context, index) {
                  var chain = filteredChains[index];
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
                      subtitle: Text(
                        'Chain ID: ${chain['chainId']}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          if (!isActive) {
                            // Set the active chain and notify the user
                            controller.switchChain(chain['name']!);
                            Get.snackbar(
                              'Success!',
                              '${chain['name']} is now the active chain.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green.withOpacity(0.8),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                              icon: const Icon(Icons.check_circle, color: Colors.white),
                            );
                            setState(() {

                            });
                            // Navigate back to home after switching
                            Future.delayed(const Duration(seconds: 1), () {
                              Get.back(); // Navigate back to the previous screen (likely Home)
                            });
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

      // Floating Action Button to Add a New Chain
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddChainModal(context); // Show Add Chain Modal
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }


}
