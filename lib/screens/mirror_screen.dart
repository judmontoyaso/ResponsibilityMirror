import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/notes_provider.dart';
import '../models/personal_note.dart';
import '../widgets/mirror_goal_item.dart';
import '../widgets/add_goal_dialog.dart';
import 'notes_screen.dart';

class MirrorScreen extends StatelessWidget {
  const MirrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
              Colors.grey[800]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<GoalsProvider>(
            builder: (context, goalsProvider, _) {
              return Stack(
                children: [
                  // Efecto espejo - reflejo sutil
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                            Colors.white.withOpacity(0.03),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Contenido
                  CustomScrollView(
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Consumer<SettingsProvider>(
                                builder: (context, settings, _) {
                                  return Text(
                                    settings.userName.isEmpty
                                        ? 'MURO DE LA RESPONSABILIDAD'
                                        : '${settings.userName.toUpperCase()}\nMURO DE LA RESPONSABILIDAD',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 2,
                                      height: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(2, 2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getMirrorQuote(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.6),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Reglas personales
                      if (goalsProvider.personalRules.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MIS REGLAS',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...goalsProvider.personalRules.map(
                                  (rule) => MirrorGoalItem(
                                    goal: rule,
                                    isRule: true,
                                  ),
                                ),
                                const SizedBox(height: 32),
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
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'NOTAS PARA MI',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(0.8),
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const NotesScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text('Ver todas →'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 180,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: notesProvider.notes.take(5).length,
                                      itemBuilder: (context, index) {
                                        final note = notesProvider.notes[index];
                                        return _buildMiniPostIt(note, index);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Metas del día
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'HOY',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      
                      // Lista de metas
                      if (goalsProvider.dailyGoals.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Sin compromisos para hoy',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => _showAddGoalDialog(context),
                                    child: const Text(
                                      'Agregar meta',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return MirrorGoalItem(
                                  goal: goalsProvider.dailyGoals[index],
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
                  
                  // Botón flotante
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: FloatingActionButton(
                      onPressed: () => _showAddGoalDialog(context),
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                ],
              );
            },
          ),
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
  
  Widget _buildMiniPostIt(PersonalNote note, int index) {
    final color = NotesScreen.postItColors[note.colorIndex % NotesScreen.postItColors.length];
    
    return Transform.rotate(
      angle: (index % 2 == 0 ? -0.03 : 0.03),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pin visual
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.red[700],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 3,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Contenido
            Expanded(
              child: Text(
                note.content,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  height: 1.3,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
