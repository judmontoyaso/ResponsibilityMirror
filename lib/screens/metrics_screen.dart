import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/habits_provider.dart';
import '../providers/goals_provider.dart';
import '../models/checkin.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final habitsProvider = context.watch<HabitsProvider>();
    final goalsProvider = context.watch<GoalsProvider>();
    final checkinsBox = Hive.box('checkins');
    
    // Load check-ins
    final checkins = checkinsBox.values.map((e) => DailyCheckIn(
      id: e['id'],
      date: DateTime.parse(e['date']),
      completed: e['completed'],
      notes: e['notes'],
      goalsCompleted: e['goalsCompleted'],
      goalsTotal: e['goalsTotal'],
      mood: CheckInMood.values[e['mood'] ?? 2],
    )).toList();
    checkins.sort((a, b) => b.date.compareTo(a.date));
    
    // Calculate overall statistics
    final totalCheckins = checkins.length;
    final completedDays = checkins.where((c) => c.completed).length;
    final successRate = totalCheckins > 0 ? (completedDays / totalCheckins * 100) : 0.0;
    
    // Weekly stats
    final last7Days = checkins.where((c) {
      final diff = DateTime.now().difference(c.date).inDays;
      return diff <= 7;
    }).toList();
    final weeklySuccess = last7Days.where((c) => c.completed).length;
    
    // Monthly stats
    final now = DateTime.now();
    final monthlyCheckins = checkins.where((c) => 
      c.date.year == now.year && c.date.month == now.month
    ).toList();
    final monthlySuccess = monthlyCheckins.where((c) => c.completed).length;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Mediciones y Métricas'),
        elevation: 0,
        backgroundColor: const Color(0xFF2D3142),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            _buildSectionTitle('Resumen Global'),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Check-ins',
                    value: totalCheckins.toString(),
                    icon: Icons.calendar_today,
                    color: const Color(0xFF4F5D75),
                  ).animate().fadeIn(delay: 0.ms).scale(delay: 0.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Tasa Éxito',
                    value: '${successRate.round()}%',
                    icon: Icons.trending_up,
                    color: successRate >= 70 ? const Color(0xFF51CF66) : const Color(0xFFFF6B6B),
                  ).animate().fadeIn(delay: 100.ms).scale(delay: 100.ms),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Esta Semana',
                    value: '$weeklySuccess/${last7Days.length}',
                    icon: Icons.calendar_view_week,
                    color: const Color(0xFF4ECDC4),
                  ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Este Mes',
                    value: '$monthlySuccess/${monthlyCheckins.length}',
                    icon: Icons.calendar_month,
                    color: const Color(0xFFBF40BF),
                  ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Habits Section
            _buildSectionTitle('Hábitos Diarios'),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D3142), Color(0xFF4F5D75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nivel Actual',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${habitsProvider.userLevel}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total Completados',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${habitsProvider.totalCompletions}',
                            style: const TextStyle(
                              color: Color(0xFF51CF66),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHabitMetric('Racha Promedio', '${habitsProvider.currentStreakAverage.toStringAsFixed(1)} días', Icons.local_fire_department),
                      _buildHabitMetric('Hoy', '${habitsProvider.todayCompletionCount}/7', Icons.check_circle),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0, delay: 400.ms),
            
            const SizedBox(height: 32),
            
            // Goals Section
            _buildSectionTitle('Objetivos'),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildGoalMetricRow('Total de Objetivos', goalsProvider.goals.length.toString(), Icons.flag),
                  const Divider(height: 24),
                  _buildGoalMetricRow('Activos Hoy', goalsProvider.dailyGoals.length.toString(), Icons.today),
                  const Divider(height: 24),
                  _buildGoalMetricRow('Completados Hoy', goalsProvider.completedToday.length.toString(), Icons.check_circle_outline),
                  const Divider(height: 24),
                  _buildGoalMetricRow('Reglas Personales', goalsProvider.personalRules.length.toString(), Icons.rule),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.percent, color: Color(0xFF2D3142)),
                          SizedBox(width: 12),
                          Text(
                            'Tasa de Completado',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF51CF66).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${goalsProvider.getTodayCompletionRate()}%',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF51CF66),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0, delay: 500.ms),
            
            const SizedBox(height: 32),
            
            // Check-ins History Summary
            if (checkins.isNotEmpty) ...[
              _buildSectionTitle('Historial de Check-ins (Últimos 10)'),
              const SizedBox(height: 12),
              
              ...checkins.take(10).map((checkin) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: checkin.completed ? const Color(0xFF51CF66).withOpacity(0.3) : const Color(0xFFFF6B6B).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      checkin.completed ? Icons.check_circle : Icons.cancel,
                      color: checkin.completed ? const Color(0xFF51CF66) : const Color(0xFFFF6B6B),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(checkin.date),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${checkin.goalsCompleted}/${checkin.goalsTotal} metas • ${_getMoodEmoji(checkin.mood)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: checkin.completed ? const Color(0xFF51CF66).withOpacity(0.1) : const Color(0xFFFF6B6B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(checkin.completionRate * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: checkin.completed ? const Color(0xFF51CF66) : const Color(0xFFFF6B6B),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (600 + checkins.indexOf(checkin) * 50).ms)),
            ],
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3142),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6C757D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalMetricRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF2D3142)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5D75),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    if (diff < 7) return 'Hace $diff días';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMoodEmoji(CheckInMood mood) {
    switch (mood) {
      case CheckInMood.great:
        return '🔥';
      case CheckInMood.good:
        return '😊';
      case CheckInMood.neutral:
        return '😐';
      case CheckInMood.struggled:
        return '😓';
      case CheckInMood.failed:
        return '😞';
    }
  }
}
