import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/pedido/pedido.dart';

import 'detalhesPedidoPage.dart';

class AcompanharPedidoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AcompanharPedidoState();
}

class _AcompanharPedidoState extends State<AcompanharPedidoPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text("Acompanhar Pedidos") ),
      body: _body(context),
    );
  }

  final _streamController = new StreamController();

  _getOrders() async {
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');
    QuerySnapshot order = await orders.where('user_id', isEqualTo: FirebaseAuth.instance.currentUser.uid).get();
    _streamController.add(order);
    return order;
  }

  _body(BuildContext context) {
    _getOrders();
    return StreamBuilder(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Erro ao acessar os dados."));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> data = snapshot.data.docs;
        List<Pedido> pedidos = new List();
        data.forEach((element) {
          pedidos.add(new Pedido(element));
        });

        return Container(
          color: Theme.of(context).backgroundColor,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.all(5.0),
                      color: Colors.white,
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  Text(
                                    "ID: ",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    " " + pedidos[index].ID,
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 17,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Status:",
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                      (pedidos[index].status == 0
                                      ? " Solicitação Recebida"
                                      : pedidos[index].status == 1
                                      ? " Em trânsito"
                                      : pedidos[index].status == 2
                                      ? " Entregue"
                                      : " Sem status"),
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Pagamento:",
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    (pedidos[index].pagamento == 0
                                        ? " Boleto Bancário"
                                        : " Cartão de Credito"),
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.all(10.0),
                            height: 50,
                            width: 50,
                            child: Material(
                              color: Colors.orange,
                              child: InkWell(
                                splashColor: Colors.lightGreen,
                                child: Icon(Icons.account_tree),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DetalhesPedidoPage(pedidos[index])),
                                  );
                                },
                              ),
                            )
                          )
                        ],
                      ),
                    );
                  },
                  childCount: pedidos.length,
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  detalhesPedidoPage(Pedido pedido) {}
}