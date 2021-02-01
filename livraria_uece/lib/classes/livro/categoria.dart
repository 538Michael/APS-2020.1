class Categoria {
  String _id;
  String _categoria;

  Categoria(this._id, this._categoria);

  String get categoria => _categoria;

  set categoria(String value) {
    _categoria = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String toString(){
    return "Categoria "+_id.toString()+' '+_categoria.toString();
  }
}
