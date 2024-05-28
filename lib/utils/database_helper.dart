import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/models/todo.dart';


class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  String todoTable = 'todo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colStatus = 'status';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = path.join(directory.path, 'todos.db');
    var todoDatabase = await openDatabase(dbPath, version: 1, onCreate: _createDb);
    return todoDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTO_INCREMENT, $colTitle TEXT, $colDescription TEXT, $colStatus TEXT)'
    );
  }

  Future<List<Map<String, dynamic>>> getTodoMapList() async {
    Database db = await this.database;
    var result = await db.query(todoTable, orderBy: '$colId ASC');
    return result;
  }

  Future<int> insertTodo(Todo todo) async {
  Database db = await this.database;
  var result = await db.insert(todoTable, {
    colTitle: todo.title,
    colDescription: todo.description,
    colStatus: todo.status,
  });
  return result;
}


  Future<int> updateTodo(Todo todo) async {
    Database db = await this.database;
    var result = await db.update(
      todoTable,
      todo.toMap(),
      where: '$colId = ?',
      whereArgs: [todo.id]
    );
    return result;
  }


  Future<int> deleteTodo(int id) async {
    Database db = await this.database;
  int result = await db.delete('todo_table', where: 'id = ?', whereArgs: [id]);
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $todoTable');
    int? result = Sqflite.firstIntValue(x);
    return result ?? 0;
  }

  Future<List<Todo>> getTodoList() async {
    var todoMapList = await getTodoMapList();
    int count = todoMapList.length;

    List<Todo> todoList = [];
    for (int i = 0; i < count; i++) {
      todoList.add(Todo.fromMapObject(todoMapList[i]));
    }

    return todoList;
  }
}
