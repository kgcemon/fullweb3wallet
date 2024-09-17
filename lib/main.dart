import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mind_web3_test/view/screen/wallet_screen.dart';

void main() {
  runApp(GetMaterialApp(
    home: TrustWalletUI(),
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0E1121),
      primaryColor: Colors.blue,
    ),
  ));
}