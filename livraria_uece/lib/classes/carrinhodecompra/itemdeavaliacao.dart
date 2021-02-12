import 'package:livraria_uece/classes/carrinhodecompra/itemdecarrinho.dart';
import 'package:livraria_uece/classes/livro/livro.dart';

class ItemDeAvaliacao extends ItemDeCarrinho {
  double avaliacao;

  ItemDeAvaliacao(Livro livro, int quantidade, {double avaliacao}) : super(livro, quantidade) {
    this.avaliacao = avaliacao;
  }
}