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
                      
                      // Post-its / Notas personales con mejor diseño
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.sticky_note_2, color: Color(0xFF2D3142), size: 24),
                                          SizedBox(width: 8),
                                          Text(
                                            'NOTAS RÁPIDAS',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D3142),
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const NotesScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.arrow_forward, size: 16),
                                        label: const Text('Ver todas'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF2D3142),
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1, end: 0, delay: 600.ms),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: notesProvider.notes.take(5).length,
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
                      
                      // TODO del día con mejor diseño
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF51CF66),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.check_box, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'TAREAS DE HOY',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.1, end: 0, delay: 700.ms),
                        ),
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      
                      // Lista de TODO mejorada
                      Consumer<TodoProvider>(
                        builder: (context, todoProvider, _) {
                          if (todoProvider.todos.isEmpty && todoProvider.completedTodos.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE9ECEF),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF51CF66).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_circle_outline,
                                          size: 48,
                                          color: const Color(0xFF51CF66),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Sin tareas pendientes',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3142),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '¡Agrega tu primera tarea del día!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () => _showAddTodoDialog(context, todoProvider),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Agregar Tarea'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF51CF66),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(delay: 800.ms).scale(delay: 800.ms),
                            );
                          }
                          
                          return SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final allTodos = [...todoProvider.todos, ...todoProvider.completedTodos];
                                  final todo = allTodos[index];
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: todo.isCompleted 
                                          ? const Color(0xFF51CF66).withOpacity(0.3)
                                          : const Color(0xFFE9ECEF),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      leading: Checkbox(
                                        value: todo.isCompleted,
                                        onChanged: (_) => todoProvider.toggleTodo(todo.id),
                                        activeColor: const Color(0xFF51CF66),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      title: Text(
                                        todo.task,
                                        style: TextStyle(
                                          decoration: todo.isCompleted 
                                            ? TextDecoration.lineThrough 
                                            : null,
                                          color: todo.isCompleted 
                                            ? Colors.grey[500] 
                                            : const Color(0xFF2D3142),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20),
                                        color: const Color(0xFFFF6B6B),
                                        onPressed: () => todoProvider.deleteTodo(todo.id),
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: (800 + index * 50).ms).slideX(begin: -0.1, end: 0, delay: (800 + index * 50).ms);
                                },
                                childCount: todoProvider.todos.length + todoProvider.completedTodos.length,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      
                      // Objetivos del día con diseño mejorado
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
                                'OBJETIVOS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.1, end: 0, delay: 900.ms),
                        ),
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      
                      // Lista de objetivos mejorada
                      if (goalsProvider.dailyGoals.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE9ECEF),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.flag_outlined,
                                      size: 48,
                                      color: const Color(0xFFFF6B6B),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Sin objetivos definidos',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3142),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '¡Define tus metas del día!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _showAddGoalDialog(context),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Agregar Objetivo'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6B6B),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 1000.ms).scale(delay: 1000.ms),
                        )
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
                                ).animate().fadeIn(delay: (1000 + index * 100).ms).slideX(begin: -0.1, end: 0, delay: (1000 + index * 100).ms);
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
                  
                  // Botones flotantes con animación
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.extended(
                          heroTag: 'addTodo',
                          onPressed: () {
                            final todoProvider = context.read<TodoProvider>();
                            _showAddTodoDialog(context, todoProvider);
                          },
                          backgroundColor: const Color(0xFF51CF66),
                          icon: const Icon(Icons.check_box_outlined, color: Colors.white),
                          label: const Text('Tarea', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          elevation: 4,
                        )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .shimmer(delay: 2000.ms, duration: 1500.ms, color: Colors.white.withOpacity(0.3))
                        .shake(hz: 0.3, duration: 2000.ms, delay: 3000.ms),
                        const SizedBox(height: 12),
                        FloatingActionButton.extended(
                          heroTag: 'addGoal',
                          onPressed: () => _showAddGoalDialog(context),
                          backgroundColor: const Color(0xFFFF6B6B),
                          icon: const Icon(Icons.flag_outlined, color: Colors.white),
                          label: const Text('Objetivo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          elevation: 4,
                        )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .shimmer(delay: 2500.ms, duration: 1500.ms, color: Colors.white.withOpacity(0.3))
                        .shake(hz: 0.3, duration: 2000.ms, delay: 3500.ms),
                      ],
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
  
  Widget _buildEnhancedPostIt(PersonalNote note, int index) {
    final color = NotesScreen.postItColors[note.colorIndex % NotesScreen.postItColors.length];
    final rotation = (index % 2 == 0 ? -0.04 : 0.04) + (math.Random(index).nextDouble() * 0.02 - 0.01);
    
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(3, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Pin mejorado
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  note.content,
                  style: const TextStyle(
                    color: Color(0xFF2D3142),
                    fontSize: 14,
                    height: 1.4,
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
      ).animate().fadeIn(delay: (700 + index * 100).ms).scale(delay: (700 + index * 100).ms).then().shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
    );
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
                    color: Colors.grey.withOpacity(0.2),
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
                  color: Color(0xFF2D3142),
                  fontSize: 15,
                  height: 1.5,
                  letterSpacing: 0.2,
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

  void _showAddTodoDialog(BuildContext context, TodoProvider todoProvider) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add_task, color: Color(0xFF51CF66)),
            SizedBox(width: 12),
            Text('Nueva Tarea', style: TextStyle(color: Color(0xFF2D3142))),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Color(0xFF2D3142)),
          decoration: InputDecoration(
            hintText: '¿Qué vas a hacer hoy?',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF51CF66), width: 2),
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              todoProvider.addTodo(value);
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF6C757D))),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                todoProvider.addTodo(controller.text);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF51CF66),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
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
