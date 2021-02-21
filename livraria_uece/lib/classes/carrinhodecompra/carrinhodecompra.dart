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

  void addLivro(Livro livro, {int quantidade = 1}) async {
    for(ItemDeCarrinho item in carrinho){
      if(item.livro.id == livro.id){
        item.incrementa();
        return;
      }
    }
    carrinho.add(new ItemDeCarrinho(livro, quantidade));
  }

  removeItem(ItemDeCarrinho item) {
    carrinho.remove(item);
  }

  void removeLivro(Livro livro) async {
    for(ItemDeCarrinho item in carrinho){
      if(item.livro.id == livro.id){
        removeItem(item);
        return;
      }
    }
  }

  void removeLivroUnidade(Livro livro){
    for(ItemDeCarrinho item in carrinho){
      if(item.livro.id == livro.id){
        if(!item.decrementa()) removeItem(item);
        return;
      }
    }
  }

  void carrinhoClear() {
    carrinho.clear();
  }

  bool searchBook(Livro livro) {
    bool ans = false;
    carrinho.forEach((element) {
      if(element.livro.id == livro.id) {
        ans = true;
        return;
      }
    });
    return ans;
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