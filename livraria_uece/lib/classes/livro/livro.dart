
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/livro/editora.dart';

class Livro {
  String _id;
  String _url_capa;
  String _titulo;
  double _preco;
  List<int> _avaliacao;
  Editora _editora;
  List<Autor> _autores;
  List<Categoria> _categorias;

  Livro({ String id, String url_capa, String titulo, double preco, List<int> avaliacao, Editora editora, List<Autor> autores, List<Categoria> categorias }) {
    _id = id;
    _url_capa = url_capa;
    _titulo = titulo;
    _preco = preco;
    _avaliacao = avaliacao ?? new List();
    _editora = editora;
    _autores = autores ?? new List();
    _categorias = categorias ?? new List();
  }

  void newAvaliacao(var avaliacao) {
    _avaliacao.add(avaliacao);
  }

  void newCategoria(Categoria categoria) {
    _categorias.add(categoria);
  }

  void removeCategoria(Categoria categoria) {
    _categorias.remove(categoria);
  }

  void newAutor(Autor autor) {
    _autores.add(autor);
  }

  void removeAutor(Autor autor) {
    _autores.remove(autor);
  }

  double get avaliacao {
    double avaliacao = 0;
    _avaliacao.forEach((element) => avaliacao += ( element / _avaliacao.length) );
    return avaliacao;
  }

  String get id => _id;

  set id(String value) {
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

  Editora get editora => _editora;

  set editora(Editora value) {
    _editora = value;
  }

  List<Autor> get autores => _autores;

  set autores(List<Autor> value) {
    _autores = value;
  }

  List<Categoria> get categorias => _categorias;

  set categorias(List<Categoria> value) {
    _categorias = value;
  }
}