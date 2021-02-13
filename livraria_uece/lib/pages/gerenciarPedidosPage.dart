import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/services/request.dart';

class GerenciarPedidosPage extends StatefulWidget {
  @override
  _GerenciarPedidosPageState createState() => _GerenciarPedidosPageState();
}

class _GerenciarPedidosPageState extends State<GerenciarPedidosPage> {
  final request = new Request();

  final _streamController = new StreamController();

  bool _cadastroVerified = true;

  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Map<String, int> orderStatus = new Map();

  List<String> statusCodes = ['Solicitado', 'Em Trânsito', 'Entregue'];
  Map<String, int> codeStatus = {
    'Solicitado': 0,
    'Em Trânsito': 1,
    'Entregue': 2
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  void _loadData() async {
    if (auth.currentUser != null) {
      QuerySnapshot pedidos = await orders.get();

      pedidos.docs.forEach((element) {
        orderStatus[element.id] = element.data()['status'];
      });

      _streamController.add(pedidos);
    }
  }

  _body() {
    //_getOrders();
    _loadData();
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerênciar Pedidos"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro ao acessar os dados."));
          }
          if (!snapshot.hasData && auth.currentUser != null) {
            return Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> data = snapshot.data.docs;

          return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    data[index].id,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: DropdownButton<String>(
                    value: statusCodes[orderStatus[data[index].id]],
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black),
                    underline: Container(
                      height: 2,
                      color: Theme.of(context).backgroundColor,
                    ),
                    onChanged: (String newValue) {
                      if (auth.currentUser != null) {
                        orders
                            .doc(data[index].id)
                            .update({'status': codeStatus[newValue]});
                        setState(() {
                          orderStatus[data[index].id] = codeStatus[newValue];
                        });
                      }
                    },
                    items: statusCodes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                );
              });
        },
      ),
    );
  }
}
