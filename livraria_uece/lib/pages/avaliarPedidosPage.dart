import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/pedido/pedido.dart';
import 'package:livraria_uece/pages/detalhesAvaliarPedidoPage.dart';

import 'detalhesPedidoPage.dart';

class AvaliarPedidoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AvaliarPedidoState();
}

class _AvaliarPedidoState extends State<AvaliarPedidoPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text("Avaliar Pedidos Entregues") ),
      body: _body(context),
    );
  }

  final _streamController = new StreamController();

  _getOrders() async {
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');
    QuerySnapshot order = await orders
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .where('status', isEqualTo: 2)
        .get();
    _streamController.add(order);
  }

  _body(BuildContext context) {
    _getOrders();
    return Container(
      color: Theme.of(context).backgroundColor,
      child: StreamBuilder(
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
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        pedidos[index].ID,
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
                                        "Pagamento: ",
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
                                            ? "Boleto Bancário"
                                            : "Cartão de Credito"),
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
                                          MaterialPageRoute(builder: (context) => DetalhesAvaliarPedidoPage(pedidos[index])),
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
      ),
    );
  }

  detalhesPedidoPage(Pedido pedido) {}
}