import 'package:livraria_uece/classes/livro/livro.dart';

class CarrinhoDeCompra {
  Map _carrinho =  Map<Livro, int>();
  
  void newLivro(Livro livro) {
    if(_carrinho.containsKey(livro)) {
      _carrinho[livro] = 1;
    } else {
      _carrinho[Livro]++;
    }
  }

  void removeLivro(Livro livro) {
    _carrinho.remove(livro);
  }

  void removeLivroUnidade(Livro livro) {
    _carrinho.forEach((key, value) {
      if(key == livro) {
        value--;
      }
    });
    if(_carrinho[livro] == 0) {
      removeLivro(livro);
    }
  }

  double getPreco() {
    double preco = 0.0;
    _carrinho.forEach((key, value) {
      preco += key.preco * value;
    });
    return preco;
  }
}