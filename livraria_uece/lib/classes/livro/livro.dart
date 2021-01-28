
import 'package:livraria_uece/classes/livro/autor.dart';
import 'package:livraria_uece/classes/livro/categoria.dart';
import 'package:livraria_uece/classes/livro/editora.dart';

class Livro {
  int _id;
  String _url_capa;
  String _titulo;
  double _preco;
  List<int> _avaliacao;
  Editora _editora;
  Categoria _categoria;
  List<Autor> _autores;

  Livro({ int id, String url_capa, String titulo, double preco, Editora editora, Categoria categoria, List<Autor> autores, List<int> avaliacao }) {
    _id = id;
    _url_capa = url_capa;
    _titulo = titulo;
    _preco = preco;
    _editora = editora;
    _categoria = categoria;
    _autores = autores ?? new List();
    _avaliacao = avaliacao ?? new List();
  }

  void addAvaliacao(var avaliacao) {
    _avaliacao.add(avaliacao);
  }

  double get avaliacao {
    double avaliacao = 0;
    _avaliacao.forEach((element) => avaliacao += ( element / _avaliacao.length) );
    return avaliacao;
  }

  void addAutor(Autor autor) {
    _autores.add(autor);
  }

  void removeAutor(Autor autor) {
    _autores.remove(autor);
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

  Editora get editora => _editora;

  set editora(Editora value) {
    _editora = value;
  }

  List<Autor> get autores => _autores;

  set autores(List<Autor> value) {
    _autores = value;
  }

  Categoria get categoria => _categoria;

  set categoria(Categoria value) {
    _categoria = value;
  }
}