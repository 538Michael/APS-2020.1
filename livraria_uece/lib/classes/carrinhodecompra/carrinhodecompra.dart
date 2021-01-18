import 'package:livraria_uece/classes/livro/livro.dart';

class CarrinhoDeCompra {
  Map _carrinho =  Map<Livro, int>();
  
  void newLivro(Livro livro) {
    this._carrinho[Livro]++;
  }

  void removeLivro(Livro livro) {
    this._carrinho.remove(livro);
  }

  void removeUmLivro(Livro livro) {
    this._carrinho.forEach((key, value) {
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
    this._carrinho.forEach((key, value) {
      preco += key.preco * value;
    });
    return preco;
  }
}