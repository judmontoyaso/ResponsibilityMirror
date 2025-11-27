import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/goals_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/notes_provider.dart';
import '../models/personal_note.dart';
import '../models/goal.dart';
import '../widgets/add_goal_dialog.dart';
import 'notes_screen.dart';
import 'dart:math' as math;

class MirrorScreen extends StatelessWidget {
  const MirrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MURO',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 22,
            color: Color(0xFF2D3142),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptionsDialog(context),
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'AGREGAR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(delay: 2000.ms, duration: 1500.ms)
        .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F7FA),
              const Color(0xFFE8EBF0),
              const Color(0xFFF0F2F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<GoalsProvider>(
            builder: (context, goalsProvider, _) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header épico
                  SliverToBoxAdapter(
                    child: _buildEpicHeader(context),
                  ),
                  
                  // Grid masonry unificado
                  Consumer<NotesProvider>(
                    builder: (context, notesProvider, _) {
                      // Combinar todos los elementos
                      final allItems = <Widget>[];
                      
                      // Agregar post-its
                      for (var i = 0; i < notesProvider.notes.length; i++) {
                        allItems.add(_buildPostItCard(notesProvider.notes[i], i));
                      }
                      
                      // Agregar reglas
                      for (var i = 0; i < goalsProvider.personalRules.length; i++) {
                        allItems.add(_buildRuleCard(goalsProvider.personalRules[i], i));
                      }
                      
                      // Agregar metas
                      for (var i = 0; i < goalsProvider.dailyGoals.length; i++) {
                        allItems.add(_buildGoalCard(goalsProvider.dailyGoals[i], i));
                      }
                      
                      if (allItems.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _buildEmptyState(),
                        );
                      }
                      
                      return SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childCount: allItems.length,
                          itemBuilder: (context, index) => allItems[index],
                        ),
                      );
                    },
                  ),
                  
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEpicHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return Column(
            children: [
              // Logo con efecto suave
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3))
                .then(delay: 1000.ms)
                .shake(hz: 0.5, duration: 500.ms),
              
              const SizedBox(height: 24),
              
              if (settings.userName.isNotEmpty)
                Text(
                  settings.userName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Color(0xFF2D3142),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFFFF8E53),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text(
                  'RESPONSABILIDAD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms),
              
              const SizedBox(height: 20),
              
              Text(
                _getMirrorQuote(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF2D3142).withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostItCard(PersonalNote note, int index) {
    final color = NotesScreen.postItColors[note.colorIndex % NotesScreen.postItColors.length];
    final rotation = (index % 2 == 0 ? -0.03 : 0.03);
    
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pin
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red[800],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              note.content,
              style: const TextStyle(
                color: Color(0xFF2D3142),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (200 + index * 100).ms).scale(delay: (200 + index * 100).ms),
    );
  }

  Widget _buildRuleCard(Goal rule, int index) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFBF40BF),
            const Color(0xFF8E44AD),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBF40BF).withOpacity(0.6),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'REGLA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            rule.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          if (rule.description != null) ...[
            const SizedBox(height: 12),
            Text(
              rule.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: (300 + index * 100).ms).slideX(begin: -0.2, end: 0, delay: (300 + index * 100).ms);
  }

  Widget _buildGoalCard(Goal goal, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flag,
                  color: Color(0xFFFF6B6B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'META',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3142).withOpacity(0.5),
                    letterSpacing: 2,
                  ),
                ),
              ),
              if (goal.priority > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(goal.priority).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getPriorityColor(goal.priority),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'P${goal.priority}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(goal.priority),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            goal.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3142),
              height: 1.3,
            ),
          ),
          if (goal.description != null) ...[
            const SizedBox(height: 10),
            Text(
              goal.description!,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF2D3142).withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],
          if (goal.steps.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.checklist,
                    color: const Color(0xFF2D3142).withOpacity(0.6),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${goal.stepsCompleted.where((c) => c).length}/${goal.steps.length} pasos',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF2D3142).withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: (400 + index * 100).ms).slideX(begin: 0.2, end: 0, delay: (400 + index * 100).ms);
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(40),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2D3142).withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: const Color(0xFF2D3142).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Tu muro está vacío',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3142).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Agrega reglas, metas o notas\npara comenzar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF2D3142).withOpacity(0.5),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(duration: 800.ms);
  }

  void _showAddOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              '¿QUÉ DESEAS AGREGAR?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D3142),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 28),
            _buildOptionTile(
              context,
              icon: Icons.shield,
              title: 'Regla Personal',
              subtitle: 'Principio inquebrantable',
              color: const Color(0xFFBF40BF),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const AddGoalDialog(isRule: true),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context,
              icon: Icons.flag,
              title: 'Meta',
              subtitle: 'Objetivo específico',
              color: const Color(0xFFFF6B6B),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const AddGoalDialog(isRule: false),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF2D3142).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getMirrorQuote() {
    final quotes = [
      'El espejo no miente, tú decides quién ves',
      'Tus acciones definen quién eres realmente',
      'No negocies con la versión débil de ti',
      'Cada promesa que cumples es un ladrillo',
      'El respeto propio se gana, no se declara',
    ];
    return quotes[DateTime.now().day % quotes.length];
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return const Color(0xFFFF4757);
      case 2:
        return const Color(0xFFFFD93D);
      default:
        return Colors.grey;
    }
  }
}
