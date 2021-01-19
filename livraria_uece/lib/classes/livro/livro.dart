
class Livro {
  String _titulo;
  double _preco;
  double _avaliacao;
  int _qntavaliacoes;
  String _editora;
  Set<String> _autores;
  Set<String> _categorias;
  Livro.complete(this._titulo, this._preco, this._editora, {Set<String> autores, Set<String> categorias}) {
    _autores = autores;
    _categorias = categorias;
    resetAvaliacao();
  }

  void resetAvaliacao() {
    _qntavaliacoes = 0;
    _avaliacao = 5;
  }

  void newAvaliacao(var avaliacao) {
    _avaliacao *= _qntavaliacoes;
    _avaliacao = (_avaliacao + avaliacao) / ++_qntavaliacoes;
  }

  void newCategoria(String categoria) {
    _categorias.add(categoria);
  }

  void removeCategoria(String categoria) {
    _categorias.remove(categoria);
  }

  void newAutor(String autor) {
    _autores.add(autor);
  }

  void removeAutor(String autor) {
    _autores.remove(autor);
  }
}