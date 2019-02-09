import 'package:flutter/material.dart';

class PostingWidget extends StatelessWidget {
  final accountController;
  final amountController;
  final currencyController;
  final int index;

  final BuildContext context;

  PostingWidget({
    this.context,
    this.index,
    this.accountController,
    this.amountController,
    this.currencyController,
  });

  Widget build(BuildContext context) {
    int j = index + 1;
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: accountController,
            decoration: InputDecoration(
              labelText: 'Account $j',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: amountController,
            decoration: InputDecoration(
              labelText: 'Amount $j',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        Flexible(
          child: TextFormField(
            controller: currencyController,
            decoration: InputDecoration(
              labelText: 'Currency $j',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
