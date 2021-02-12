import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';

class EscolherPagamentoPage extends StatefulWidget {
  @override
  _EscolherPagamentoState createState() => _EscolherPagamentoState();
}

class _EscolherPagamentoState extends State<EscolherPagamentoPage> {
  CarrinhoDeCompra carrinho = new CarrinhoDeCompra();

  Pagamento _pagamento = Pagamento.boleto;

  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escolher Forma de Pagamento"),
      ),
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  _body(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          ListTile(
            title: Text("Boleto Bancário"),
            leading: Radio(
              value: Pagamento.boleto,
              groupValue: _pagamento,
              onChanged: (Pagamento value) {
                setState(() {
                  _pagamento = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text("Cartão de Crédito"),
            leading: Radio(
              value: Pagamento.cartao,
              groupValue: _pagamento,
              onChanged: (Pagamento value) {
                setState(() {
                  _pagamento = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  _bottomNavigationBar(BuildContext context) {
    return Container(
      height: 190,
      child: Column(
        children: <Widget>[
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Subtotal:",
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("R\$ " + carrinho.preco.toStringAsFixed(2),
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          Container(
            height: 40,
            margin:
                EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Desconto:",
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                    (_pagamento == Pagamento.boleto)
                        ? "10% (R\$ " +
                            carrinho.desconto.toStringAsFixed(2) +
                            ")"
                        : "0%",
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total:",
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                    "R\$ " +
                        (carrinho.preco -
                                ((_pagamento == Pagamento.boleto)
                                    ? carrinho.desconto
                                    : 0))
                            .toStringAsFixed(2),
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.orangeAccent,
              child: InkWell(
                splashColor: Colors.blueGrey,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                      "Confirmar Compra",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                onTap: () async {
                  CollectionReference orders = firestore.collection('orders');

                  Map<String, List<dynamic>> itemsNoCarrinho = new Map();

                  carrinho.carrinho.forEach((element) {
                    itemsNoCarrinho[element.livro.id] = [
                      element.quantidade,
                      element.livro.preco
                    ];
                  });

                  await orders
                      .add({
                        'user_id': auth.currentUser.uid,
                        'items': itemsNoCarrinho,
                        'payment_method': _pagamento.index,
                        'status': 0,
                        'created_at': (DateTime.now().millisecondsSinceEpoch/1000).truncate()
                      })
                      .then((value) {
                        print("Order Added");
                        carrinho.carrinhoClear();
                        _AlertDialog(context, "Compra concluída");
                      })
                      .catchError((error) {
                        print("Failed to order user: $error");
                        _AlertDialog(context, "Ocorreu um erro ao efetuar a compra");
                      });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

_AlertDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              var nav = Navigator.of(context);
              nav.pop();
              nav.pop();
              nav.pop();
            },
          ),
        ],
      );
    },
  );
}

enum Pagamento { boleto, cartao }
