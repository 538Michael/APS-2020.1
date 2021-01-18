
class Livro {
  String _titulo;
  var _preco;
  var _avaliacao;
  var _qntavaliacoes;
  String _editora;
  Set<String> _autores;
  Set<String> _categorias;

  Livro.incomplete(this._titulo, this._preco, this._editora) {
    this.resetAvaliacao();
  }

  Livro.complete(this._titulo, this._preco, this._editora, Set<String> this._autores, Set<String> this._categorias) {
    this.resetAvaliacao();
  }

  void resetAvaliacao() {
    this._qntavaliacoes = 0;
    this._avaliacao = 5;
  }

  void newAvaliacao(var avaliacao) {
    this._avaliacao *= this._qntavaliacoes;
    this._avaliacao = (this._avaliacao + _avaliacao) / ++this._qntavaliacoes;
  }

  void newCategoria(String categoria) {
    this._categorias.add(categoria);
  }

  void removeCategoria(String categoria) {
    this._categorias.remove(categoria);
  }

  void newAutor(String autor) {
    this._autores.add(autor);
  }

  void removeAutor(String autor) {
    this._autores.remove(autor);
  }
}