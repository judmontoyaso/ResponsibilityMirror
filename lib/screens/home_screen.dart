import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../providers/goals_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/phrases_provider.dart';
import '../models/ai_generated_phrase.dart';
import '../models/goal.dart';
import '../widgets/goal_card.dart';
import '../widgets/add_goal_dialog.dart';
import 'statistics_screen.dart';
import 'todo_day_screen.dart';
import 'metrics_screen.dart';
import 'personal_rules_screen.dart';
import '../providers/todo_provider.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPhraseIndex = 0;
  bool _migrationDone = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Ejecutar migración solo una vez
    if (!_migrationDone) {
      _migrationDone = true;
      final phrasesProvider = context.read<PhrasesProvider>();
      final goalsProvider = context.read<GoalsProvider>();
      
      Future.microtask(() async {
        await phrasesProvider.migratePhrasesToUseGoalIds(goalsProvider.goals);
      });
    }
  }

  void _nextPhrase(PhrasesProvider phrasesProvider) {
    final allPhrases = phrasesProvider.allActivePhrases;
    if (allPhrases.isNotEmpty) {
      setState(() {
        _currentPhraseIndex = Random().nextInt(allPhrases.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
      appBar: AppBar(
        title: const Text('Responsibility Mirror'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptionsDialog(context),
        backgroundColor: const Color(0xFFFF6B6B),
        child: const Icon(Icons.add, color: Colors.white),
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
                
                // Tarjeta de frase motivacional
                Consumer<PhrasesProvider>(
                  builder: (context, phrasesProvider, _) {
                    final allPhrases = phrasesProvider.allActivePhrases;
                    
                    if (allPhrases.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Priorizar frases personalizadas (AI)
                    final aiPhrases = phrasesProvider.aiPhrases.where((p) => p.isActive).toList();
                    final displayPhrases = aiPhrases.isNotEmpty ? aiPhrases : allPhrases;
                    
                    if (_currentPhraseIndex >= displayPhrases.length) {
                      _currentPhraseIndex = 0;
                    }
                    
                    final currentPhrase = displayPhrases[_currentPhraseIndex];
                    final phraseText = currentPhrase is String 
                      ? currentPhrase 
                      : (currentPhrase as AIGeneratedPhrase).text;
                    String? relatedGoal;
                    if (currentPhrase is! String) {
                      final aiPhrase = currentPhrase as AIGeneratedPhrase;
                      final relatedGoalRef = aiPhrase.relatedGoal;
                      if (relatedGoalRef != null) {
                        // Buscar la meta por ID
                        final goalsProvider = context.read<GoalsProvider>();
                        final matchingGoal = goalsProvider.goals.cast<Goal?>().firstWhere(
                          (g) => g?.id == relatedGoalRef,
                          orElse: () => null,
                        );
                        relatedGoal = matchingGoal?.title;
                      }
                    }
                    
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Patrón de fondo
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _QuotePatternPainter(),
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.format_quote,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        aiPhrases.isNotEmpty ? 'Frase Personalizada' : 'Frase del Día',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _nextPhrase(phrasesProvider),
                                      icon: const Icon(Icons.refresh, color: Colors.white),
                                      tooltip: 'Nueva frase',
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 20),
                                
                                Text(
                                  phraseText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                
                                if (relatedGoal != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.flag, color: Colors.white, size: 14),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            relatedGoal,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOut)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Botones de acceso rápido
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MetricsScreen()),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(Icons.assessment, color: Color(0xFF8B5CF6), size: 32),
                                SizedBox(height: 8),
                                Text(
                                  'Métricas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B5CF6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(Icons.bar_chart, color: Color(0xFF3B82F6), size: 32),
                                SizedBox(height: 8),
                                Text(
                                  'Estadísticas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Consumer<TodoProvider>(
                        builder: (context, todoProvider, _) {
                          final total = todoProvider.todos.length + todoProvider.completedTodos.length;
                          final completed = todoProvider.completedTodos.length;
                          final percentage = total > 0 ? (completed / total * 100).toInt() : 0;
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TodoDayScreen()),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const Icon(Icons.check_circle, color: Color(0xFF51CF66), size: 32),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'TODO',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF51CF66),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$percentage%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<GoalsProvider>(
                        builder: (context, provider, _) {
                          final rate = provider.getTodayCompletionRate();
                          final total = provider.goals.length;
                          final completed = provider.completedToday.length;
                          final color = rate >= 80 ? const Color(0xFF51CF66) : 
                                       rate >= 50 ? Colors.orange : const Color(0xFFFF6B6B);
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: CircularProgressIndicator(
                                          value: total > 0 ? rate / 100 : 0,
                                          strokeWidth: 6,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(color),
                                        ),
                                      ),
                                      Text(
                                        '$rate%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$completed/$total',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Metas de Hoy - Header
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
                      'Metas',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (goalsProvider.dailyGoals.isEmpty)
                  _buildEmptyState(context)
                else
                  ...goalsProvider.dailyGoals.asMap().entries.map(
                    (entry) => GoalCard(
                      goal: entry.value,
                      onGoalCompleted: () => _confettiController.play(),
                    )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (100 + entry.key * 80).ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: (100 + entry.key * 80).ms)
                  ),
                
                const SizedBox(height: 32),
                
                // Metas completadas hoy
                if (goalsProvider.completedToday.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF51CF66),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.celebration, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '🎉 Completadas',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...goalsProvider.completedToday.map(
                    (goal) => GoalCard(
                      goal: goal,
                      onGoalCompleted: () => _confettiController.play(),
                    ).animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.95, 0.95)),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      ),
    ),
        // Confetti widget a nivel de pantalla completa
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2, // hacia abajo
            emissionFrequency: 0.02,
            numberOfParticles: 50,
            gravity: 0.2,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 30,
            minBlastForce: 15,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
              Colors.red,
              Colors.teal,
            ],
          ),
        ),
      ],
    );
  }

  void _showAddOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¿Qué deseas agregar?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBF40BF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield, color: Color(0xFFBF40BF)),
              ),
              title: const Text(
                'Regla Personal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text('Principio inquebrantable'),
              onTap: () {
                Navigator.pop(context);
                _showAddGoalDialog(context, isRule: true);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flag, color: Color(0xFFFF6B6B)),
              ),
              title: const Text(
                'Meta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text('Objetivo específico'),
              onTap: () {
                Navigator.pop(context);
                _showAddGoalDialog(context, isRule: false);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, {bool isRule = false}) {
    showDialog(
      context: context,
      builder: (context) => AddGoalDialog(isRule: isRule),
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

  String _getMotivationalGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Es hora de dominar el día antes de que empiece.';
    if (hour < 12) return 'El día recién comienza. Hazlo valer.';
    if (hour < 18) return 'Mantén el ritmo. No negocies tu estándar.';
    return 'El día casi termina. ¿Cumpliste tus promesas?';
  }
}

// Custom painter para el patrón de fondo de la tarjeta de frase
class _QuotePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Dibuja círculos decorativos
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.2 + (i * 15)),
        8 + (i * 4),
        paint,
      );
    }

    // Dibuja líneas decorativas
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.6,
      size.width * 0.5,
      size.height * 0.75,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
