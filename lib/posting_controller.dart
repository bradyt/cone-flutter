import 'package:flutter/material.dart';

class PostingController {
  Key key;
  TextEditingController accountController;
  TextEditingController amountController;
  TextEditingController currencyController;

  PostingController({
    this.key,
    this.accountController,
    this.amountController,
    this.currencyController,
  });
}
