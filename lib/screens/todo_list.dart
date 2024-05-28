import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/screens/todo_details.dart';
import 'package:todo_app/utils/database_helper.dart';

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodoListState();
  }
}

class TodoListState extends State<TodoList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  late List<Todo> todoList = [];
  late List<Todo> filteredTodoList = [];
  int count = 0;

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
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
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list_alt, color: Colors.white, size: 36),
            onSelected: (String value) {
              _filterTodoList(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'All',
                  child: Text('All'),
                  
                ),
                PopupMenuItem<String>(
                  value: 'Todo',
                  child: Text('Todo'),
                ),
                PopupMenuItem<String>(
                  value: 'In progress',
                  child: Text('In progress'),
                ),
                PopupMenuItem<String>(
                  value: 'Done',
                  child: Text('Done'),
                ),
                PopupMenuItem<String>(
                  value: 'Bug',
                  child: Text('Bug'),
                ),
              ];
            },
          ),
        ],
      ),
      body: getTodoListView(),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Color.fromRGBO(15, 15, 15, 0.883),
        onPressed: () {
          navigateToDetails(Todo.withId(null, '', '', ''), "Ajouter");
        },
        tooltip: 'Add note',
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  ListView getTodoListView() {
    return ListView.builder(
      itemCount: filteredTodoList.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: getStatusColor(filteredTodoList[index].status),
            ),
          ),
          elevation: 0,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 30),
            leading: CircleAvatar(
              backgroundColor: getStatusColor(filteredTodoList[index].status),
              child: Icon(Icons.lens_rounded, color: getStatusColor(filteredTodoList[index].status)),
            ),
            title: Text(filteredTodoList[index].title, style: TextStyle(fontSize: 24, color: Colors.black)),
            onTap: () {
              navigateToDetails(filteredTodoList[index], 'Modifier');
            },
          ),
        );
      },
    );
  }

  void navigateToDetails(Todo todo, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TodoDetail(todo, title);
    })) ?? false;

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Todo>> todoListFuture = databaseHelper.getTodoList();
      todoListFuture.then((todoList) {
        setState(() {
          this.todoList = _sortTodoListByStatus(todoList);
          this.filteredTodoList = List.from(this.todoList); 
          this.count = todoList.length;
        });
      }).catchError((error) {
        debugPrint('Error occurred while fetching todo list: $error');
      });
    }).catchError((error) {
      debugPrint('Error occurred while initializing database: $error');
    });
  }

  List<Todo> _sortTodoListByStatus(List<Todo> todoList) {
    todoList.sort((a, b) {
      return _getStatusPriority(a.status).compareTo(_getStatusPriority(b.status));
    });
    return todoList;
  }

  int _getStatusPriority(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return 1;
      case 'in progress':
        return 2;
      case 'done':
        return 3;
      case 'bug':
        return 4;
      default:
        return 5;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return Colors.grey;
      case 'in progress':
        return Colors.blue;
      case 'done':
        return Colors.green;
      case 'bug':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _filterTodoList(String status) {
    setState(() {
      if (status == 'All') {
        filteredTodoList = List.from(todoList);
      } else {
        filteredTodoList = todoList.where((todo) => todo.status == status).toList();
      }
    });
  }
}
