class Categoria {
  int _id;
  String _categoria;

  Categoria(this._id, this._categoria);

  String get categoria => _categoria;

  set categoria(String value) {
    _categoria = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String toString(){
    return "Categoria "+_id.toString()+' '+_categoria.toString();
  }
}
