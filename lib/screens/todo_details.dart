import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/utils/database_helper.dart';

class TodoDetail extends StatefulWidget {
  final String appBarTitle;
  final Todo todo;

  TodoDetail(this.todo, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return TodoDetailState(this.todo, this.appBarTitle);
  }
}

class TodoDetailState extends State<TodoDetail> {
  final String appBarTitle;
  final Todo todo;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  static var _status = ['Status', 'Todo', 'In progress', 'Done', 'Bug'];

  DatabaseHelper helper = DatabaseHelper();

  TodoDetailState(this.todo, this.appBarTitle);

  @override
  void initState() {
    super.initState();
    titleController.text = todo.title;
    descriptionController.text = todo.description;
    statusController.text = todo.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Color.fromARGB(139, 28, 28, 28),
        backgroundColor: Color.fromRGBO(15, 15, 15, 0.883),
        title: Text(
          "Todo App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Color.fromRGBO(15, 15, 15, 0.883),
        onPressed: () {
          moveToLastScreen();
        },
        tooltip: 'Quitter',
        child: Icon(
          Icons.close,
          color: Colors.white,
          size: 30,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      appBarTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: DropdownButtonFormField(
                        items: _status.map((String DropdownStringItem) {
                          return DropdownMenuItem<String>(
                            value: DropdownStringItem,
                            child: Container(
                              width: MediaQuery.of(context).size.width *0.15, 
                              child: Text(DropdownStringItem),
                            ),
                          );
                        }).toList(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        value: todo.status.isEmpty ? "Status" : todo.status,
                        onChanged: (selectedStatus) {
                          setState(() {
                            todo.status = selectedStatus as String;
                            updateStatus(selectedStatus as String);
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lens_rounded, ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 66, 66, 66),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 66, 66, 66),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Partie titre de tâche
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Tâche',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                controller: titleController,
                onChanged: (value) {
                  updateTitle();
                },
              ),
            ),
            // Partie description de tâche
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                controller: descriptionController,
                onChanged: (value) {
                  updateDescription();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(15, 15, 15, 0.883),
                      ),
                      onPressed: () {
                        setState(() {
                          _save();
                        });
                      },
                      child: Text(
                        appBarTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(15, 15, 15, 0.883),
                      ),
                      onPressed: () {
                        setState(() {
                          _delete();
                        });
                      },
                      child: Text(
                        'Supprimer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateTitle() {
    todo.title = titleController.text;
  }

  void updateStatus(String selectedStatus) {
    todo.status = selectedStatus;
  }

  void updateDescription() {
    todo.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();

    todo.title = titleController.text;
    todo.description = descriptionController.text;

    int result;
    if (todo.id != null && todo.id! > 0) {
      result = await helper.updateTodo(todo);
    } else {
      result = await helper.insertTodo(todo);
    }

    if (result != 0) {
      _showAlertDialog('Succès', 'Tâche ajoutée avec succès !');
    } else {
      _showAlertDialog('Erreur', 'Erreur lors de la récupération de la tâche.');
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (todo.id == null) {
      _showAlertDialog('Status', 'Aucune tâche n\'a été supprimée');
      return;
    }

    int result = await helper.deleteTodo(todo.id!);
    if (result != 0) {
      _showAlertDialog('Status', 'Tâche supprimée avec succès !');
    } else {
      _showAlertDialog(
          'Status', 'Une erreur s\'est produite lors de la suppression');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
