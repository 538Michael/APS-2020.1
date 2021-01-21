import 'package:livraria_uece/classes/livro/livro.dart';

class ItemDeCarrinho {
  int livroId;
  int quantidade;

  ItemDeCarrinho(livro, int quantidade){
    if(livro is int)
      this.livroId = livro;
    if(livro is Livro)
      this.livroId = livro.id;
    this.quantidade = quantidade;
  }

  bool incrementa(){
    quantidade++;
    return true;
  }

  bool decrementa(){
    quantidade--;
    return quantidade > 0;
  }

  Future<Livro> get livro async {
    //return await Ctrl.getLivro(livroId);
    return null;
  }

}