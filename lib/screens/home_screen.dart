import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/goals_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/goal_card.dart';
import '../widgets/add_goal_dialog.dart';
import 'statistics_screen.dart';
import 'todo_day_screen.dart';
import 'metrics_screen.dart';
import 'personal_rules_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsibility Mirror'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Mediciones',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MetricsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Estadísticas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(context),
          ),
        ],
      ),
      body: Consumer<GoalsProvider>(
        builder: (context, goalsProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 60,
                              height: 60,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                settings.userName.isEmpty 
                                    ? 'Bienvenido, guerrero' 
                                    : 'Hola, ${settings.userName}',
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getMotivationalGreeting(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Botón TODO del día
                Card(
                  color: const Color(0xFF51CF66).withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TodoDayScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF51CF66),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.task_alt, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TODO del Día',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Gestiona tus tareas diarias',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF51CF66)),
                        ],
                      ),
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideX(begin: -0.2, end: 0, duration: 500.ms, delay: 100.ms),
                
                const SizedBox(height: 16),
                
                // Metrics Card
                Card(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MetricsScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ECDC4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.assessment, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mediciones y Métricas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Análisis completo de tu progreso',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF4ECDC4)),
                        ],
                      ),
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideX(begin: -0.2, end: 0, duration: 500.ms, delay: 200.ms),
                
                const SizedBox(height: 16),
                
                // Personal Rules Card
                Card(
                  color: const Color(0xFFBF40BF).withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PersonalRulesScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFBF40BF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reglas Personales',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${goalsProvider.personalRules.length} ${goalsProvider.personalRules.length == 1 ? "Principio" : "Principios"}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFBF40BF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '• Inquebrantables',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6C757D),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFFBF40BF)),
                        ],
                      ),
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideX(begin: -0.2, end: 0, duration: 500.ms, delay: 300.ms),
                
                const SizedBox(height: 24),
                
                // Completion rate
                _buildCompletionCard(context, goalsProvider),
                
                const SizedBox(height: 32),
                
                // Life Goals with improved styling
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.flag, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Objetivos de Hoy',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (goalsProvider.dailyGoals.isEmpty)
                  _buildEmptyState(context)
                else
                  ...goalsProvider.dailyGoals.asMap().entries.map(
                    (entry) => GoalCard(goal: entry.value)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (200 + entry.key * 100).ms)
                      .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: (200 + entry.key * 100).ms)
                  ),
                
                const SizedBox(height: 24),
                
                // Completed today (goals)
                if (goalsProvider.completedToday.isNotEmpty) ...[
                  Text(
                    'Objetivos completados hoy ✅',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 12),
                  ...goalsProvider.completedToday.map(
                    (goal) => GoalCard(goal: goal)
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context, GoalsProvider provider) {
    final rate = provider.getTodayCompletionRate();
    // Contar TODOS los objetivos (tanto daily como personal)
    final total = provider.goals.length;
    final completed = provider.completedToday.length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularProgressIndicator(
              value: total > 0 ? rate / 100 : 0,
              strokeWidth: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                rate >= 80 ? const Color(0xFF51CF66) : 
                rate >= 50 ? Colors.orange : const Color(0xFFFF6B6B)
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$rate% completado',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed de $total objetivos',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 100.ms)
    .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 100.ms, curve: Curves.easeOutCubic)
    .shimmer(delay: 800.ms, duration: 1200.ms, color: const Color(0xFF51CF66).withOpacity(0.3));
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Sin objetivos. Sin propósito.',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega OBJETIVOS y empieza a construir tu legado',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddGoalDialog(),
    );
  }

  String _getMotivationalGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Es hora de dominar el día antes de que empiece.';
    if (hour < 12) return 'El día recién comienza. Hazlo valer.';
    if (hour < 18) return 'Mantén el ritmo. No negocies tu estándar.';
    return 'El día casi termina. ¿Cumpliste tus promesas?';
  }
}
