import 'package:livraria_uece/classes/livro/livro.dart';

class ItemDeCarrinho {
  Livro livro;
  int quantidade;

  ItemDeCarrinho(this.livro, this.quantidade);

  bool incrementa(){
    quantidade++;
    return true;
  }

  bool decrementa(){
    quantidade--;
    return quantidade > 0;
  }

  // Future<Livro> get livro async {
  //   return await Ctrl.getLivro(livroId);
  //   return null;
  // }

  toString(){
    return livro.titulo + ' (' + quantidade.toString() + 'x)';
  }

}