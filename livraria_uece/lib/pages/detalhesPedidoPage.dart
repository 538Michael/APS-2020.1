import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livraria_uece/classes/pedido/pedido.dart';

class DetalhesPedidoPage extends StatelessWidget {
  Pedido pedido;

  DetalhesPedidoPage(this.pedido);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalhes do Pedido")),
      body: Container(),
    );
  }

}