import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/habits_provider.dart';
import '../models/daily_habit.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  String _formatDate() {
    final now = DateTime.now();
    final dateFormat = DateFormat("EEEE, d 'de' MMMM", 'es');
    String formatted = dateFormat.format(now);
    // Capitalize first letter
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Hábitos de Elite'),
        elevation: 0,
      ),
      body: Consumer<HabitsProvider>(
        builder: (context, habitsProvider, _) {
          return CustomScrollView(
            slivers: [
              // Date Header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3142).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF2D3142),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
              ),
              
              // Header con stats
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D3142), Color(0xFF4F5D75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Nivel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Text('⚡', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  'NIVEL ${habitsProvider.userLevel}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Progreso del día
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${habitsProvider.completedToday}/${habitsProvider.totalHabits}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Text(
                                  'Completados Hoy',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white24,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${habitsProvider.completionRate.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Color(0xFF51CF66),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Text(
                                  'Tasa del Día',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Barra de progreso
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: habitsProvider.completionRate / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF51CF66)),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Racha promedio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'Racha Promedio: ${habitsProvider.currentStreakAverage} días',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
              ),
              
              // Mensaje motivacional
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    habitsProvider.completedToday == habitsProvider.totalHabits
                        ? '🏆 ¡IMPARABLE! Todos los hábitos completados'
                        : habitsProvider.completedToday == 0
                            ? '💪 Comienza ahora. Sin excusas.'
                            : '⚡ Sigue adelante. Estás construyendo la mejor versión de ti.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              // Lista de hábitos
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = habitsProvider.habits[index];
                      return _buildHabitCard(context, habit, habitsProvider, index);
                    },
                    childCount: habitsProvider.habits.length,
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, DailyHabit habit, HabitsProvider provider, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: habit.isCompletedToday ? 4 : 2,
      child: InkWell(
        onTap: () => provider.toggleHabit(habit.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: habit.isCompletedToday
                ? LinearGradient(
                    colors: [
                      const Color(0xFF51CF66).withOpacity(0.1),
                      const Color(0xFF51CF66).withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: habit.isCompletedToday 
                        ? const Color(0xFF51CF66) 
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: habit.isCompletedToday 
                      ? const Color(0xFF51CF66) 
                      : Colors.transparent,
                ),
                child: habit.isCompletedToday
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Icono del hábito
              Text(
                habit.type.icon,
                style: const TextStyle(fontSize: 28),
              ),
              
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.type.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3142),
                        decoration: habit.isCompletedToday 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.type.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Racha
              if (habit.currentStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF6B6B).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.currentStreak}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFF6B6B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms, delay: (index * 80).ms)
    .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: (index * 80).ms);
  }
}
