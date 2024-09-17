import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mind_web3_test/controller/wallet_controller.dart';
import 'package:mind_web3_test/view/widget/ActionButton.dart';
import 'package:mind_web3_test/view/widget/TokenListWidget.dart';

import 'add_chain_page.dart';

class TrustWalletUI extends StatelessWidget {
  final WalletController controller = Get.put(WalletController());

  TrustWalletUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1121),
        elevation: 0,
        title: const Text('Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Get.to(()=> const AddChainPage());  // Navigate to AddChainPage
            },
          ),
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchBalances,
        child: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Obx(() => Text(
                '\$${controller.totalBalance.value}',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              )),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Total Balance',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionButton(
                  icon: Icons.call_made,
                  label: 'Send',
                  onPressed: () {},
                ),
                ActionButton(
                  icon: Icons.call_received,
                  label: 'Receive',
                  onPressed: () {},
                ),
                ActionButton(
                  icon: Icons.credit_card,
                  label: 'Buy',
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 30),
            ...controller.tokens.map((token) => TokenListItem(token: token)),
          ],
        )),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF171D33),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Swap'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'DApp'),
        ],
      ),
    );
  }
}
