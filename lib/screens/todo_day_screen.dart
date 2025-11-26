import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../models/daily_todo.dart';

class TodoDayScreen extends StatelessWidget {
  const TodoDayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('TODO del Día'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearCompletedDialog(context),
            tooltip: 'Limpiar completadas',
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, _) {
          final totalTodos = todoProvider.todos.length + todoProvider.completedTodos.length;
          final completedCount = todoProvider.completedTodos.length;
          final completionRate = totalTodos > 0 ? (completedCount / totalTodos * 100) : 0;
          
          return Column(
            children: [
              // Header con stats
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF51CF66), Color(0xFF40C057)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF51CF66).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Progreso del Día',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$completedCount/$totalTodos',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: completionRate / 100,
                                strokeWidth: 8,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                            Text(
                              '${completionRate.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: completionRate / 100,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
              
              // Mensaje motivacional
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  completedCount == totalTodos && totalTodos > 0
                      ? '🎉 ¡Increíble! Has completado todas tus tareas'
                      : completedCount == 0
                          ? '💪 Comienza tu día productivo'
                          : '⚡ Sigue así, estás arrasando',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Lista de TODOs
              Expanded(
                child: todoProvider.todos.isEmpty && todoProvider.completedTodos.isEmpty
                    ? _buildEmptyState(context)
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // TODOs pendientes
                          if (todoProvider.todos.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.pending_actions, size: 18, color: Color(0xFF2D3142)),
                                  SizedBox(width: 8),
                                  Text(
                                    'PENDIENTES',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2D3142),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...todoProvider.todos.asMap().entries.map((entry) {
                              return _buildTodoCard(
                                context,
                                entry.value,
                                todoProvider,
                                entry.key,
                                false,
                              );
                            }).toList(),
                          ],
                          
                          // TODOs completados
                          if (todoProvider.completedTodos.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 18, color: Color(0xFF51CF66)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'COMPLETADAS (${todoProvider.completedTodos.length})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF51CF66),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...todoProvider.completedTodos.asMap().entries.map((entry) {
                              return _buildTodoCard(
                                context,
                                entry.value,
                                todoProvider,
                                entry.key,
                                true,
                              );
                            }).toList(),
                          ],
                          
                          const SizedBox(height: 100),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Tarea'),
        backgroundColor: const Color(0xFF51CF66),
      ).animate()
        .fadeIn(duration: 500.ms, delay: 600.ms)
        .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 500.ms, delay: 600.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF51CF66).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt,
              size: 80,
              color: Color(0xFF51CF66),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin tareas para hoy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primera tarea\ny comienza a ser productivo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms);
  }

  Widget _buildTodoCard(BuildContext context, DailyTodo todo, TodoProvider provider, int index, bool isCompleted) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isCompleted ? 1 : 2,
      child: InkWell(
        onTap: () => provider.toggleTodo(todo.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isCompleted ? const Color(0xFF51CF66).withOpacity(0.05) : Colors.white,
          ),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? const Color(0xFF51CF66) : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isCompleted ? const Color(0xFF51CF66) : Colors.transparent,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Texto
              Expanded(
                child: Text(
                  todo.task,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.grey[600] : const Color(0xFF2D3142),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              
              // Botón eliminar
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.grey[400],
                ),
                onPressed: () => provider.deleteTodo(todo.id),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: (index * 80).ms)
      .slideX(begin: -0.2, end: 0, duration: 400.ms, delay: (index * 80).ms);
  }

  void _showAddTodoDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nueva Tarea'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '¿Qué vas a hacer hoy?',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<TodoProvider>().addTodo(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF51CF66),
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showClearCompletedDialog(BuildContext context) {
    final provider = context.read<TodoProvider>();
    if (provider.completedTodos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay tareas completadas')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar completadas'),
        content: Text('¿Eliminar ${provider.completedTodos.length} tareas completadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              for (var todo in provider.completedTodos) {
                provider.deleteTodo(todo.id);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
