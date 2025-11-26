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

class MirrorScreen extends StatelessWidget {
  const MirrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
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
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2D3142),
                                      letterSpacing: 2,
                                      height: 1.2,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getMirrorQuote(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6C757D),
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
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3142),
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
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3142),
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
                      
                      // TODO del día
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'TODO DEL DÍA',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      
                      // Lista de TODO
                      Consumer<TodoProvider>(
                        builder: (context, todoProvider, _) {
                          if (todoProvider.todos.isEmpty && todoProvider.completedTodos.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.check_box_outline_blank,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Sin tareas para hoy',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () => _showAddTodoDialog(context, todoProvider),
                                        child: const Text(
                                          'Agregar tarea',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          return SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final allTodos = [...todoProvider.todos, ...todoProvider.completedTodos];
                                  final todo = allTodos[index];
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    color: todo.isCompleted 
                                      ? Colors.green.withOpacity(0.1) 
                                      : Colors.grey[100],
                                    child: ListTile(
                                      leading: Checkbox(
                                        value: todo.isCompleted,
                                        onChanged: (_) => todoProvider.toggleTodo(todo.id),
                                      ),
                                      title: Text(
                                        todo.task,
                                        style: TextStyle(
                                          decoration: todo.isCompleted 
                                            ? TextDecoration.lineThrough 
                                            : null,
                                          color: todo.isCompleted 
                                            ? Colors.grey[600] 
                                            : const Color(0xFF2D3142),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20),
                                        onPressed: () => todoProvider.deleteTodo(todo.id),
                                      ),
                                    ),
                                  );
                                },
                                childCount: todoProvider.todos.length + todoProvider.completedTodos.length,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      
                      // Objetivos del día
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'OBJETIVOS',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      
                      // Lista de objetivos
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
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Sin objetivos',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => _showAddGoalDialog(context),
                                    child: const Text(
                                      'Agregar objetivo',
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
        title: const Text('Nueva tarea', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '¿Qué vas a hacer hoy?',
            hintStyle: TextStyle(color: Colors.grey[400]),
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                todoProvider.addTodo(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
