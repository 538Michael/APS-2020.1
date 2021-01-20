
class Livro {
  int _id;
  String _url_capa;
  String _titulo;
  double _preco;
  List<int> _avaliacao;
  int _editora_id;
  Set<String> _autores;
  Set<String> _categorias;

  Livro({ int id, String url_capa, String titulo, double preco, List<int> avaliacao, int editora_id, Set<String> autores, Set<String> categorias }) {
    _id = id;
    _url_capa = url_capa;
    _titulo = titulo;
    _preco = preco;
    _avaliacao = avaliacao;
    _editora_id = editora_id;
    _autores = autores;
    _categorias = categorias;
  }

  void newAvaliacao(var avaliacao) {
    _avaliacao.add(avaliacao);
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

  double get avaliacao {
    double avaliacao = 0;
    _avaliacao.forEach((element) => avaliacao += ( element / _avaliacao.length) );
    return avaliacao;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get url_capa => _url_capa;

  set url_capa(String value) {
    _url_capa = value;
  }

  String get titulo => _titulo;

  set titulo(String value) {
    _titulo = value;
  }

  double get preco => _preco;

  set preco(double value) {
    _preco = value;
  }

  int get editora_id => _editora_id;

  set editora_id(int value) {
    _editora_id = value;
  }

  Set<String> get autores => _autores;

  set autores(Set<String> value) {
    _autores = value;
  }

  Set<String> get categorias => _categorias;

  set categorias(Set<String> value) {
    _categorias = value;
  }
}