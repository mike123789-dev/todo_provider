import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class TodoListProvider with ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  // total number of todos
  int get totalTodos => _todos.length;

  // total number of completed todos
  int get totalCompletedTodos => _todos.where((todo) => todo.completed).length;

  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
    saveTodos();
  }

  void toggleTodoCompletion(int index) {
    _todos[index] = Todo(
      title: _todos[index].title,
      completed: !_todos[index].completed,
    );
    notifyListeners();
    saveTodos();
  }

  void completeAllTodos() {
    _todos = _todos.map((todo) {
      return Todo(
        title: todo.title,
        completed: true,
      );
    }).toList();
    notifyListeners();
    saveTodos();
  }

  void removeAllTodos() {
    _todos = [];
    notifyListeners();
    saveTodos();
  }

  Future<void> saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = _todos.map((todo) => todo.toJson()).toList();
      await prefs.setString('todos', json.encode(todosJson));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosString = prefs.getString('todos');
      if (todosString != null) {
        final todosJson = json.decode(todosString) as List<dynamic>;
        _todos = todosJson.map((json) => Todo.fromJson(json)).toList();
      }
    } catch (e) {
      log(e.toString());
    }
    notifyListeners();
  }
}
