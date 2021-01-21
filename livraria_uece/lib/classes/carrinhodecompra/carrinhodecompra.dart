import 'package:livraria_uece/classes/carrinhodecompra/itemdecarrinho.dart';
import 'package:livraria_uece/classes/livro/livro.dart';

class CarrinhoDeCompra {
  // Map _carrinho =  Map<Livro, int>();
  List<ItemDeCarrinho> carrinho;
  int id;
  
  // void newLivro(Livro livro) {
  //   if(_carrinho.containsKey(livro)) {
  //     _carrinho[livro] = 1;
  //   } else {
  //     _carrinho[Livro]++;
  //   }
  // }
  void addLivro(Livro livro){
    for(ItemDeCarrinho item in carrinho){
      if(item.livroId == livro.id){
        item.incrementa();
        return;
      }
    }
    carrinho.add(new ItemDeCarrinho(livro, 1));
  }

  // void removeLivro(Livro livro) {
  //   _carrinho.remove(livro);
  // }
  void removeLivro(Livro livro){
    for(ItemDeCarrinho item in carrinho){
      if(item.livroId == livro.id){
        bool zero = item.decrementa();
        if(zero) carrinho.remove(item);
        return;
      }
    }
  }

  // void removeLivroUnidade(Livro livro) {
  //   _carrinho.forEach((key, value) {
  //     if(key == livro) {
  //       value--;
  //     }
  //   });
  //   if(_carrinho[livro] == 0) {
  //     removeLivro(livro);
  //   }
  // }

  // double getPreco() {
  //   double preco = 0.0;
  //   _carrinho.forEach((key, value) {
  //     preco += key.preco * value;
  //   });
  //   return preco;
  // }
  Future<double> get preco async {
    double soma = 0;
    for(ItemDeCarrinho item in carrinho){
      soma += (await item.livro).preco * item.quantidade;
    }
    return soma;
  }
  
}