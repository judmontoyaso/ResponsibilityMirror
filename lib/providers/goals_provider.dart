import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/goal.dart';
import 'package:uuid/uuid.dart';

class GoalsProvider extends ChangeNotifier {
  final Box _goalsBox = Hive.box('goals');
  final _uuid = const Uuid();
  
  List<Goal> _goals = [];
  
  List<Goal> get goals => _goals;
  List<Goal> get dailyGoals => 
      _goals.where((g) => g.type == GoalType.daily && !g.isCompleted).toList();
  List<Goal> get personalRules => 
      _goals.where((g) => g.type == GoalType.personal).toList();
  List<Goal> get completedToday => 
      _goals.where((g) => g.isCompleted && _isToday(g.completedAt)).toList();
  
  GoalsProvider() {
    loadGoals();
  }

  void loadGoals() {
    print('📖 Cargando goals desde Hive...');
    _goals = _goalsBox.values
        .map((e) {
          final steps = e['steps'] != null ? List<String>.from(e['steps']) : <String>[];
          final stepsCompleted = e['stepsCompleted'] != null 
              ? List<bool>.from(e['stepsCompleted']) 
              : null;
          
          print('   Meta: ${e['title']} - Pasos: ${steps.length}');
          
          return Goal(
            id: e['id'],
            title: e['title'],
            description: e['description'],
            isCompleted: e['isCompleted'] ?? false,
            createdAt: DateTime.parse(e['createdAt']),
            completedAt: e['completedAt'] != null 
                ? DateTime.parse(e['completedAt']) 
                : null,
            type: GoalType.values[e['type'] ?? 0],
            priority: e['priority'] ?? 1,
            steps: steps,
            stepsCompleted: stepsCompleted,
          );
        })
        .toList();
    
    print('✅ ${_goals.length} metas cargadas');
    
    // Ordenar por prioridad
    _goals.sort((a, b) => b.priority.compareTo(a.priority));
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    print('📥 Guardando en Hive - Meta: ${goal.title}');
    print('📋 Pasos a guardar: ${goal.steps.length}');
    print('✅ StepsCompleted: ${goal.stepsCompleted.length}');
    
    await _goalsBox.put(goal.id, {
      'id': goal.id,
      'title': goal.title,
      'description': goal.description,
      'isCompleted': goal.isCompleted,
      'createdAt': goal.createdAt.toIso8601String(),
      'completedAt': goal.completedAt?.toIso8601String(),
      'type': goal.type.index,
      'priority': goal.priority,
      'steps': goal.steps,
      'stepsCompleted': goal.stepsCompleted,
    });
    
    print('💿 Guardado en Hive exitoso');
    loadGoals();
  }

  Future<void> toggleGoal(String id) async {
    final goal = _goals.firstWhere((g) => g.id == id);
    
    // Si intenta marcar como completado, verificar subtareas
    if (!goal.isCompleted && goal.steps.isNotEmpty) {
      final allStepsCompleted = goal.stepsCompleted.every((completed) => completed);
      if (!allStepsCompleted) {
        print('⚠️ No se puede completar: faltan subtareas');
        // No hacer nada, retornar sin actualizar
        return;
      }
    }
    
    final updated = goal.copyWith(
      isCompleted: !goal.isCompleted,
      completedAt: !goal.isCompleted ? DateTime.now() : null,
    );
    await addGoal(updated);
  }

  Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
    loadGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    await addGoal(goal);
  }

  String createNewGoalId() => _uuid.v4();

  int getTodayCompletionRate() {
    final today = dailyGoals;
    final completed = completedToday;
    final total = today.length + completed.length;
    
    if (total == 0) return 0;
    if (completed.length == total) return 100;
    
    return ((completed.length / total) * 100).round();
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // Limpiar metas diarias completadas (se ejecuta cada noche)
  Future<void> resetDailyGoals() async {
    final dailyCompleted = _goals.where(
      (g) => g.type == GoalType.daily && g.isCompleted
    ).toList();
    
    for (var goal in dailyCompleted) {
      await deleteGoal(goal.id);
    }
  }
}
