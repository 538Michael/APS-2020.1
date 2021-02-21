import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/carrinhodecompra/carrinhodecompra.dart';
import 'package:livraria_uece/classes/services/request.dart';

class EscolherPagamentoPage extends StatefulWidget {
  @override
  _EscolherPagamentoState createState() => _EscolherPagamentoState();
}

class _EscolherPagamentoState extends State<EscolherPagamentoPage> {
  CarrinhoDeCompra carrinho = new CarrinhoDeCompra();

  Pagamento _pagamento = Pagamento.boleto;

  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final request = new Request(loadBooks: true, loadShoppingCart: true);

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
    return ValueListenableBuilder(
        valueListenable: request.updating,
        builder: (context, snapshot, widget) {

          double preco = -1;

          if (!request.updating.value &&
              request.carrinho != null &&
              request.carrinho.carrinho != null) {
            preco = request.carrinho.preco;
          }

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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("R\$ " + ((preco == -1) ? 0.toStringAsFixed(2) : request.carrinho.preco.toStringAsFixed(2)),
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  margin: EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Desconto:",
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(
                          (_pagamento == Pagamento.boleto)
                              ? "10% (R\$ " +
                              ((preco == -1) ? 0.toStringAsFixed(2) : request.carrinho.desconto.toStringAsFixed(2)) +
                                  ")"
                              : "0%",
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(
                          "R\$ " +
                              (((preco == -1) ? 0 : request.carrinho.preco) -
                                      ((_pagamento == Pagamento.boleto)
                                          ? ((preco == -1) ? 0 : request.carrinho.desconto)
                                          : 0))
                                  .toStringAsFixed(2),
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
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
                        child: Text("Confirmar Compra",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      onTap: () async {
                        BotToast.showLoading(
                          clickClose: false,
                          allowClick: false,
                          crossPage: false,
                          backButtonBehavior: BackButtonBehavior.none,
                          animationDuration: Duration(milliseconds: 200),
                          animationReverseDuration: Duration(milliseconds: 200),
                          backgroundColor: Color(0x42000000),
                        );

                        CollectionReference orders =
                            firestore.collection('orders');

                        Map<String, List<dynamic>> itemsNoCarrinho = new Map();

                        request.carrinho.carrinho.forEach((element) {
                          itemsNoCarrinho[element.livro.id] = [
                            element.quantidade,
                            element.livro.preco
                          ];
                        });

                        await orders.add({
                          'user_id': auth.currentUser.uid,
                          'items': itemsNoCarrinho,
                          'payment_method': _pagamento.index,
                          'status': 0,
                          'created_at':
                              (DateTime.now().millisecondsSinceEpoch / 1000)
                                  .truncate()
                        }).then((value) {
                          print("Order Added");
                          request.carrinho.carrinhoClear();
                          request.clearShoppingCart();

                          BotToast.closeAllLoading();

                          BotToast.showNotification(
                            leading: (cancel) => SizedBox.fromSize(
                                size: const Size(40, 40),
                                child: IconButton(
                                  icon: Icon(Icons.assignment_turned_in,
                                      color: Colors.green),
                                  onPressed: cancel,
                                )),
                            title: (_) => Text('Compra concluída com sucesso!'),
                            trailing: (cancel) => IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: cancel,
                            ),
                            enableSlideOff: true,
                            backButtonBehavior: BackButtonBehavior.none,
                            crossPage: true,
                            contentPadding: EdgeInsets.all(2),
                            onlyOne: true,
                            animationDuration: Duration(milliseconds: 200),
                            animationReverseDuration:
                                Duration(milliseconds: 200),
                            duration: Duration(seconds: 3),
                          );

                          if (!mounted) return;

                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        }).catchError(
                          (error) {
                            print("Failed to order user: $error");

                            BotToast.closeAllLoading();

                            BotToast.showNotification(
                              leading: (cancel) => SizedBox.fromSize(
                                  size: const Size(40, 40),
                                  child: IconButton(
                                    icon: Icon(Icons.warning_rounded,
                                        color: Colors.red),
                                    onPressed: cancel,
                                  )),
                              title: (_) =>
                                  Text('Ocorreu um erro ao efetuar a compra!'),
                              subtitle: (_) => Text('$error'),
                              trailing: (cancel) => IconButton(
                                icon: Icon(Icons.cancel),
                                onPressed: cancel,
                              ),
                              enableSlideOff: true,
                              backButtonBehavior: BackButtonBehavior.none,
                              crossPage: true,
                              contentPadding: EdgeInsets.all(2),
                              onlyOne: true,
                              animationDuration: Duration(milliseconds: 200),
                              animationReverseDuration:
                                  Duration(milliseconds: 200),
                              duration: Duration(seconds: 3),
                            );

                            if (!mounted) return;

                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
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
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      );
    },
  );
}

enum Pagamento { boleto, cartao }
