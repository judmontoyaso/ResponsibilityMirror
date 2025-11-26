import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/habits_provider.dart';
import '../providers/goals_provider.dart';
import '../models/daily_habit.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Estadísticas'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hábitos stats
            _buildHabitsStats(context),
            
            const SizedBox(height: 24),
            
            // Gráfico semanal
            _buildWeeklyChart(context),
            
            const SizedBox(height: 24),
            
            // Objetivos stats
            _buildGoalsStats(context),
            
            const SizedBox(height: 24),
            
            // Gráfico de rachas
            _buildStreaksChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsStats(BuildContext context) {
    return Consumer<HabitsProvider>(
      builder: (context, provider, _) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('📊', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'Resumen de Hábitos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Nivel Actual',
                        '${provider.userLevel}',
                        '⚡',
                        const Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Racha Promedio',
                        '${provider.currentStreakAverage}',
                        '🔥',
                        const Color(0xFFFF9100),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Completados',
                        '${provider.habits.fold(0, (sum, h) => sum + h.totalCompletions)}',
                        '✅',
                        const Color(0xFF51CF66),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Tasa Hoy',
                        '${provider.completionRate.toStringAsFixed(0)}%',
                        '📈',
                        const Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.2, end: 0, duration: 500.ms);
      },
    );
  }

  Widget _buildStatCard(String label, String value, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    return Consumer<HabitsProvider>(
      builder: (context, provider, _) {
        final history = provider.getCompletionHistory(7);
        final dates = history.keys.toList()..sort((a, b) => a.compareTo(b));
        
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('📅', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'Últimos 7 Días',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: dates.map((date) {
                      final count = history[date] ?? 0;
                      final maxHeight = 150.0;
                      final height = (count / 7) * maxHeight;
                      final isToday = date.day == DateTime.now().day;
                      
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Número
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isToday ? const Color(0xFF51CF66) : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Barra
                              Container(
                                width: double.infinity,
                                height: height < 10 ? 10 : height,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isToday
                                        ? [const Color(0xFF51CF66), const Color(0xFF40C057)]
                                        : [const Color(0xFF2D3142), const Color(0xFF4F5D75)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                              ).animate()
                                .fadeIn(duration: 400.ms, delay: (dates.indexOf(date) * 100).ms)
                                .slideY(begin: 0.5, end: 0, duration: 600.ms, delay: (dates.indexOf(date) * 100).ms),
                              const SizedBox(height: 8),
                              // Día
                              Text(
                                _getDayLabel(date),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                  color: isToday ? const Color(0xFF51CF66) : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms, delay: 200.ms)
          .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms);
      },
    );
  }

  Widget _buildGoalsStats(BuildContext context) {
    return Consumer<GoalsProvider>(
      builder: (context, provider, _) {
        final totalGoals = provider.goals.length;
        final completedGoals = provider.goals.where((g) => g.isCompleted).length;
        final activeGoals = totalGoals - completedGoals;
        final completionRate = totalGoals > 0 ? (completedGoals / totalGoals * 100) : 0;
        
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🎯', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'Objetivos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Círculo de progreso
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: completionRate / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF51CF66)),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${completionRate.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                          Text(
                            '$completedGoals/$totalGoals',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF51CF66).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$completedGoals',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF51CF66),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Completados',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3142).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$activeGoals',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Activos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms, delay: 400.ms)
          .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 400.ms);
      },
    );
  }

  Widget _buildStreaksChart(BuildContext context) {
    return Consumer<HabitsProvider>(
      builder: (context, provider, _) {
        // Ordenar hábitos por racha
        final habits = [...provider.habits]..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
        
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'Rachas Actuales',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ...habits.map((habit) {
                  final maxStreak = habits.first.currentStreak;
                  final percentage = maxStreak > 0 ? habit.currentStreak / maxStreak : 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(habit.type.icon, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  habit.type.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${habit.currentStreak} días',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              habit.currentStreak >= 7
                                  ? const Color(0xFF51CF66)
                                  : habit.currentStreak >= 3
                                      ? const Color(0xFFFF9100)
                                      : const Color(0xFFFF6B6B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 400.ms, delay: (habits.indexOf(habit) * 80).ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms, delay: (habits.indexOf(habit) * 80).ms);
                }).toList(),
              ],
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms, delay: 600.ms)
          .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 600.ms);
      },
    );
  }

  String _getDayLabel(DateTime date) {
    final days = ['D', 'L', 'M', 'X', 'J', 'V', 'S'];
    return days[date.weekday % 7];
  }
}
