import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                  'Metas de mi vida',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 12),
                
                if (goalsProvider.dailyGoals.isEmpty)
                  _buildEmptyState(context)
                else
                  ...goalsProvider.dailyGoals.map(
                    (goal) => GoalCard(goal: goal)
                  ),
                
                const SizedBox(height: 24),
                
                // Personal Rules
                if (goalsProvider.personalRules.isNotEmpty) ...[
                  Text(
                    'Reglas personales',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 12),
                  ...goalsProvider.personalRules.map(
                    (rule) => GoalCard(goal: rule, isRule: true)
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Completed today
                if (goalsProvider.completedToday.isNotEmpty) ...[
                  Text(
                    'Completadas hoy ✅',
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
    final total = provider.dailyGoals.length + provider.completedToday.length;
    final completed = provider.completedToday.length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularProgressIndicator(
              value: rate / 100,
              strokeWidth: 8,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                rate >= 80 ? Colors.green : 
                rate >= 50 ? Colors.orange : Colors.red
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
                    '$completed de $total metas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
              'Sin metas. Sin propósito.',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega metas de VIDA y empieza a construir tu legado',
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
