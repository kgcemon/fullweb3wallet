import 'package:flutter/material.dart';
import '../../model/token_model.dart';

class TokenListItem extends StatelessWidget {
  final Token token;

  const TokenListItem({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // leading: CircleAvatar(
      //   backgroundImage: NetworkImage(token.iconUrl),
      //   backgroundColor: Colors.transparent,
      // ),
      leading: const Icon(Icons.currency_bitcoin),
      title: Text(token.name, style: const TextStyle(color: Colors.white)),
      subtitle: Text(token.symbol, style: const TextStyle(color: Colors.grey)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(token.balance, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('\$${token.balance}', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}