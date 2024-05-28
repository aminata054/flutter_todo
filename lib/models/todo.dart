class Todo {
  int? _id; // ID can be null
  String _title;
  String _description;
  String _status;

  Todo(this._title, [this._description = '', this._status = '']);
  Todo.withId(this._id, this._title, [this._description = '', this._status = '']);

  int? get id => _id;
  String get title => _title;
  String get description => _description;
  String get status => _status;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      _title = newTitle;
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 255) {
      _description = newDescription;
    }
  }

  set status(String newStatus) {
    _status = newStatus;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['status'] = _status;
    return map;
  }

  Todo.fromMapObject(Map<String, dynamic> map)
      : _id = map['id'],
        _title = map['title'],
        _description = map['description'],
        _status = map['status'];
}
