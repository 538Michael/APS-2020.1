import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCartPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return Scaffold(
        appBar: AppBar(
          title: Text("Carrinho"),
          centerTitle: true,
        ),
        body: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.only(top: 20, left: 40, right: 40),
            )));
  }
}
