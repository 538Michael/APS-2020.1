class Editora {
  String _id;
  String _editora;

  Editora(this._id, this._editora);

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get editora => _editora;

  set editora(String value) {
    _editora = value;
  }

  String toString(){
    return "Editora "+_id.toString()+' '+_editora.toString();
  }
}