import 'package:livraria_uece/classes/carrinhodecompra/itemdecarrinho.dart';
import 'package:livraria_uece/classes/livro/livro.dart';

class CarrinhoDeCompra {
  static final CarrinhoDeCompra _carrinhodecompra = CarrinhoDeCompra._build();
  List<ItemDeCarrinho> carrinho = new List();
  int id;

  CarrinhoDeCompra._build();

  factory CarrinhoDeCompra() {
    return _carrinhodecompra;
  }

  void addLivro(Livro livro){
    for(ItemDeCarrinho item in carrinho){
      if(item.livro.id == livro.id){
        item.incrementa();
        return;
      }
    }
    carrinho.add(new ItemDeCarrinho(livro, 1));
  }

  void removeLivro(Livro livro) {
    for(ItemDeCarrinho item in carrinho){
      if(item.livro.id == livro.id){
        carrinho.remove(item);
        return;
      }
    }
  }

  void removeLivroUnidade(Livro livro){
    for(ItemDeCarrinho item in carrinho){
      if(item.livro.id == livro.id){
        if(!item.decrementa()) carrinho.remove(item);
        return;
      }
    }
  }

  double get preco {
    double soma = 0.0;
    for(ItemDeCarrinho item in carrinho){
      soma += item.livro.preco * item.quantidade;
    }
    return soma;
  }

  double get desconto {
    double soma = preco;
    return soma / 10.0;

  }
  
}