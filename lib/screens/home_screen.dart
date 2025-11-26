import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/goals_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/goal_card.dart';
import '../widgets/add_goal_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsibility Mirror'),
        actions: [
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
                
                const SizedBox(height: 24),
                
                // Completion rate
                _buildCompletionCard(context, goalsProvider),
                
                const SizedBox(height: 24),
                
                // Life Goals
                Text(
                  'Objetivos',
                  style: Theme.of(context).textTheme.displayMedium,
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
                
                // Personal Rules
                if (goalsProvider.personalRules.isNotEmpty) ...[
                  Text(
                    'Reglas personales',
                    style: Theme.of(context).textTheme.displayMedium,
                  ).animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 400.ms),
                  const SizedBox(height: 12),
                  ...goalsProvider.personalRules.asMap().entries.map(
                    (entry) => GoalCard(goal: entry.value, isRule: true)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (500 + entry.key * 100).ms)
                      .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: (500 + entry.key * 100).ms)
                  ),
                ],
                
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
