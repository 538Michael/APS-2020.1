import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livraria_uece/classes/carrinhodecompra/itemdecarrinho.dart';
import 'package:livraria_uece/classes/livro/livro.dart';

class Pedido {
  Map<String,dynamic> items;
  String userID;
  String ID;
  int status;
  int pagamento;

  Pedido(QueryDocumentSnapshot pedido) {
    items = pedido.data()['items'];
    userID = pedido.data()['user_id'];
    ID = pedido.id;
    pagamento = pedido.data()['payment_method'];
    status = pedido.data()['status'];
  }

  double get preco {
    double soma = 0.0;
    items.forEach((key, value) {
      soma += value[1];
    });
    return soma;
  }

  double get desconto {
    double soma = preco;
    return soma / 10.0;
  }

  toString(){
    return 'pedido ${ID} userID ${userID} status ${status} pagamento ${pagamento}\n${items}';
  }
}