import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_todo.dart';

class TodoProvider extends ChangeNotifier {
  late Box<DailyTodo> _todoBox;
  List<DailyTodo> _todos = [];
  DateTime _lastResetDate = DateTime.now();

  List<DailyTodo> get todos => _todos.where((t) => !t.isCompleted).toList();
  List<DailyTodo> get completedTodos => _todos.where((t) => t.isCompleted).toList();

  Future<void> initialize() async {
    _todoBox = await Hive.openBox<DailyTodo>('daily_todos');
    _loadTodos();
    _checkDailyReset();
  }

  void _loadTodos() {
    _todos = _todoBox.values.toList();
    notifyListeners();
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    final lastReset = _lastResetDate;
    
    // Si es un nuevo día, limpiar todos completados
    if (now.day != lastReset.day || now.month != lastReset.month || now.year != lastReset.year) {
      _clearCompleted();
      _lastResetDate = now;
    }
  }

  Future<void> addTodo(String task) async {
    final todo = DailyTodo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      task: task,
    );
    
    await _todoBox.put(todo.id, todo);
    _loadTodos();
  }

  Future<void> toggleTodo(String id) async {
    final todo = _todoBox.get(id);
    if (todo != null) {
      final updated = todo.copyWith(isCompleted: !todo.isCompleted);
      await _todoBox.put(id, updated);
      _loadTodos();
    }
  }

  Future<void> updateTodo(String id, String task) async {
    final todo = _todoBox.get(id);
    if (todo != null) {
      final updated = todo.copyWith(task: task);
      await _todoBox.put(id, updated);
      _loadTodos();
    }
  }

  Future<void> deleteTodo(String id) async {
    await _todoBox.delete(id);
    _loadTodos();
  }

  Future<void> _clearCompleted() async {
    final completed = _todos.where((t) => t.isCompleted).toList();
    for (var todo in completed) {
      await _todoBox.delete(todo.id);
    }
    _loadTodos();
  }
}
