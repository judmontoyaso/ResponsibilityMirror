import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/goals_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/todo_provider.dart';
import '../models/personal_note.dart';
import '../widgets/mirror_goal_item.dart';
import '../widgets/add_goal_dialog.dart';
import 'notes_screen.dart';
import 'dart:math' as math;

class MirrorScreen extends StatelessWidget {
  const MirrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptionsDialog(context),
        backgroundColor: const Color(0xFFFF6B6B),
        child: const Icon(Icons.add, color: Colors.white),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(delay: 2000.ms, duration: 1500.ms, color: Colors.white.withOpacity(0.3)),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8F9FA),
              const Color(0xFFE9ECEF).withOpacity(0.3),
              const Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<GoalsProvider>(
            builder: (context, goalsProvider, _) {
              return Stack(
                children: [
                  // Efecto espejo con círculos animados
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MirrorEffectPainter(),
                    ),
                  ),
                  
                  // Contenido
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header mejorado
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF2D3142).withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo con efecto de brillo
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white,
                                      const Color(0xFFF8F9FA),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2D3142).withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 100,
                                  height: 100,
                                ),
                              ).animate(onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 3000.ms, delay: 1000.ms, color: Colors.white.withOpacity(0.5))
                                .shake(hz: 0.2, duration: 1500.ms, delay: 4000.ms),
                              
                              const SizedBox(height: 20),
                              
                              Consumer<SettingsProvider>(
                                builder: (context, settings, _) {
                                  return Column(
                                    children: [
                                      if (settings.userName.isNotEmpty)
                                        Text(
                                          settings.userName.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF2D3142),
                                            letterSpacing: 3,
                                          ),
                                        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF2D3142), Color(0xFF4F5D75)],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF2D3142).withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          'MURO DE LA RESPONSABILIDAD',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scale(delay: 200.ms),
                                    ],
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  _getMirrorQuote(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF2D3142),
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, end: 0, delay: 400.ms),
                            ],
                          ),
                        ),
                      ),
                      
                      // Post-its / Notas personales
                      Consumer<NotesProvider>(
                        builder: (context, notesProvider, _) {
                          if (notesProvider.notes.isEmpty) {
                            return const SliverToBoxAdapter(child: SizedBox.shrink());
                          }
                          
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.amber[700],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.sticky_note_2, color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'POST-ITS',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3142),
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0, delay: 600.ms),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: notesProvider.notes.length,
                                      itemBuilder: (context, index) {
                                        final note = notesProvider.notes[index];
                                        return _buildEnhancedPostIt(note, index);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      
                      // Reglas Personales
                      if (goalsProvider.personalRules.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBF40BF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.shield, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'REGLAS PERSONALES',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3142),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 800.ms),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: MirrorGoalItem(
                                    goal: goalsProvider.personalRules[index],
                                    isRule: true,
                                  ),
                                );
                              },
                              childCount: goalsProvider.personalRules.length,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],
                      
                      // Metas como tarjetas atractivas
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
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
                              const Text(
                                'METAS',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                            ).animate().fadeIn(delay: 900.ms),
                        ),
                      ),                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      
                      // Lista de metas
                      if (goalsProvider.dailyGoals.isEmpty)
                        const SliverToBoxAdapter(child: SizedBox.shrink())
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: MirrorGoalItem(
                                    goal: goalsProvider.dailyGoals[index],
                                  ),
                                );
                              },
                              childCount: goalsProvider.dailyGoals.length,
                            ),
                          ),
                        ),
                      
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
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

  String _getMirrorQuote() {
    final quotes = [
      'El espejo no miente',
      'Tus acciones definen quién eres',
      'No negocies con la versión débil de ti',
      'Cada promesa cuenta',
      'El respeto propio se gana',
    ];
    return quotes[DateTime.now().day % quotes.length];
  }
  
  Widget _buildEnhancedPostIt(PersonalNote note, int index) {
    final color = NotesScreen.postItColors[note.colorIndex % NotesScreen.postItColors.length];
    final rotation = (index % 2 == 0 ? -0.04 : 0.04) + (math.Random(index).nextDouble() * 0.02 - 0.01);
    
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 180,
        height: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(3, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Pin
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Text(
                  note.content,
                  style: const TextStyle(
                    color: Color(0xFF2D3142),
                    fontSize: 15,
                    height: 1.5,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 7,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (700 + index * 100).ms).scale(delay: (700 + index * 100).ms),
    );
  }
}

// Painter para efecto de espejo
class _MirrorEffectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Círculos de reflejo sutiles
    for (int i = 0; i < 3; i++) {
      paint.color = Colors.white.withOpacity(0.02);
      canvas.drawCircle(
        Offset(size.width * (0.2 + i * 0.3), size.height * (0.1 + i * 0.3)),
        size.width * (0.3 + i * 0.1),
        paint,
      );
    }
    
    // Líneas diagonales sutiles
    paint.color = Colors.white.withOpacity(0.01);
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 10; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / 10),
        Offset(size.width, size.height * (i + 2) / 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
