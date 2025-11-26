import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/daily_habit.dart';
import 'package:uuid/uuid.dart';

class HabitsProvider extends ChangeNotifier {
  final Box _habitsBox = Hive.box('habits');
  final _uuid = const Uuid();
  
  List<DailyHabit> _habits = [];
  
  List<DailyHabit> get habits => _habits;
  
  int get completedToday => _habits.where((h) => h.isCompletedToday).length;
  int get todayCompletionCount => _habits.where((h) => h.isCompletedToday).length;
  int get totalHabits => _habits.length;
  double get completionRate => totalHabits > 0 ? (completedToday / totalHabits) * 100 : 0;
  int get currentStreakAverage => _habits.isEmpty ? 0 : (_habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / _habits.length).round();
  int get totalCompletions => _habits.fold(0, (sum, h) => sum + h.totalCompletions);
  
  HabitsProvider() {
    _initializeHabits();
  }

  void _initializeHabits() {
    print('🎮 Inicializando sistema de hábitos...');
    loadHabits();
    
    // Si no hay hábitos, crear los 7 obligatorios
    if (_habits.isEmpty) {
      print('📝 Creando hábitos obligatorios...');
      for (var type in HabitType.values) {
        _habits.add(DailyHabit(
          id: _uuid.v4(),
          type: type,
        ));
      }
      saveHabits();
      print('✅ ${_habits.length} hábitos creados');
    }
    
    // Verificar reset diario
    _checkDailyReset();
  }

  void loadHabits() {
    final data = _habitsBox.get('habits', defaultValue: []);
    _habits = (data as List).map((e) => DailyHabit(
      id: e['id'],
      type: HabitType.values[e['type']],
      isCompletedToday: e['isCompletedToday'] ?? false,
      currentStreak: e['currentStreak'] ?? 0,
      longestStreak: e['longestStreak'] ?? 0,
      lastCompletedDate: e['lastCompletedDate'] != null 
          ? DateTime.parse(e['lastCompletedDate']) 
          : null,
      totalCompletions: e['totalCompletions'] ?? 0,
      completionHistory: e['completionHistory'] != null
          ? (e['completionHistory'] as List).map((d) => DateTime.parse(d)).toList()
          : [],
    )).toList();
    
    notifyListeners();
  }

  Future<void> saveHabits() async {
    await _habitsBox.put('habits', _habits.map((h) => {
      'id': h.id,
      'type': h.type.index,
      'isCompletedToday': h.isCompletedToday,
      'currentStreak': h.currentStreak,
      'longestStreak': h.longestStreak,
      'lastCompletedDate': h.lastCompletedDate?.toIso8601String(),
      'totalCompletions': h.totalCompletions,
      'completionHistory': h.completionHistory.map((d) => d.toIso8601String()).toList(),
    }).toList());
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    bool needsReset = false;
    
    for (int i = 0; i < _habits.length; i++) {
      final habit = _habits[i];
      
      // Si el hábito fue completado pero no hoy, resetear
      if (habit.lastCompletedDate != null) {
        final lastDate = habit.lastCompletedDate!;
        final isToday = lastDate.year == now.year && 
                       lastDate.month == now.month && 
                       lastDate.day == now.day;
        
        if (!isToday && habit.isCompletedToday) {
          // Reset del día
          _habits[i] = habit.copyWith(isCompletedToday: false);
          needsReset = true;
          
          // Verificar si rompió la racha (más de 1 día sin completar)
          final daysDiff = now.difference(lastDate).inDays;
          if (daysDiff > 1) {
            print('💔 Racha rota para ${habit.type.name}');
            _habits[i] = _habits[i].copyWith(currentStreak: 0);
          }
        }
      }
    }
    
    if (needsReset) {
      saveHabits();
      notifyListeners();
    }
  }

  Future<void> toggleHabit(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    
    final habit = _habits[index];
    final now = DateTime.now();
    
    if (habit.isCompletedToday) {
      // Desmarcar
      _habits[index] = habit.copyWith(
        isCompletedToday: false,
        currentStreak: habit.currentStreak > 0 ? habit.currentStreak - 1 : 0,
        totalCompletions: habit.totalCompletions > 0 ? habit.totalCompletions - 1 : 0,
      );
      
      // Remover de historial
      final history = List<DateTime>.from(habit.completionHistory);
      history.removeWhere((d) => 
        d.year == now.year && d.month == now.month && d.day == now.day
      );
      _habits[index] = _habits[index].copyWith(completionHistory: history);
      
    } else {
      // Marcar como completado
      int newStreak = habit.currentStreak + 1;
      int newLongest = newStreak > habit.longestStreak ? newStreak : habit.longestStreak;
      
      final history = List<DateTime>.from(habit.completionHistory);
      history.add(now);
      
      _habits[index] = habit.copyWith(
        isCompletedToday: true,
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastCompletedDate: now,
        totalCompletions: habit.totalCompletions + 1,
        completionHistory: history,
      );
      
      print('🔥 ${habit.type.name} - Racha: $newStreak días');
    }
    
    await saveHabits();
    notifyListeners();
  }

  // Obtener hábitos completados en los últimos N días
  Map<DateTime, int> getCompletionHistory(int days) {
    final now = DateTime.now();
    final history = <DateTime, int>{};
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      
      int count = 0;
      for (var habit in _habits) {
        final hasCompletion = habit.completionHistory.any((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day
        );
        if (hasCompletion) count++;
      }
      
      history[dateKey] = count;
    }
    
    return history;
  }

  // Nivel del usuario basado en total de completaciones
  int get userLevel {
    final total = _habits.fold(0, (sum, h) => sum + h.totalCompletions);
    return (total / 10).floor() + 1;
  }

  int get completionsForNextLevel {
    final total = _habits.fold(0, (sum, h) => sum + h.totalCompletions);
    return 10 - (total % 10);
  }
}
