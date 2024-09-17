import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mind_web3_test/bindings.dart';
import 'package:mind_web3_test/view/screen/wallet_screen.dart';

void main() {
  GetStorage.init();
  runApp(
    GetMaterialApp(
      initialBinding: ControllerBinder(),
      home: TrustWalletUI(),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E1121),
        primaryColor: Colors.blue,
      ),
    ),
  );
}
