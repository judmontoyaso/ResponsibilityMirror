import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goals_provider.dart';

class GoalCard extends StatefulWidget {
  final Goal goal;
  final bool isRule;
  final VoidCallback? onGoalCompleted;

  const GoalCard({
    super.key,
    required this.goal,
    this.isRule = false,
    this.onGoalCompleted,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {

  @override
  Widget build(BuildContext context) {
    // Calcular porcentaje de completitud
    int completionPercentage = 0;
    if (widget.goal.steps.isNotEmpty) {
      int completedSteps = widget.goal.stepsCompleted.where((completed) => completed).length;
      completionPercentage = ((completedSteps / widget.goal.steps.length) * 100).round();
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: widget.isRule
                ? Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 28,
                  )
                : Checkbox(
                    value: widget.goal.isCompleted,
                    onChanged: (_) => _toggleGoal(context),
                    shape: const CircleBorder(),
                  ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.goal.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: widget.goal.isCompleted ? TextDecoration.lineThrough : null,
                      color: widget.goal.isCompleted ? Colors.grey : null,
                    ),
                  ),
                ),
                if (widget.goal.steps.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: completionPercentage == 100 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: completionPercentage == 100 ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Text(
                      '$completionPercentage%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: completionPercentage == 100 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: widget.goal.description != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.goal.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : null,
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteGoal(context);
                } else if (value == 'edit') {
                  _editGoal(context);
                }
              },
            ),
          ),
          // Mostrar pasos si existen
          if (widget.goal.steps.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.list_alt, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 6),
                      Text(
                        'Pasos para lograrlo:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...widget.goal.steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isStepCompleted = index < widget.goal.stepsCompleted.length 
                        ? widget.goal.stepsCompleted[index] 
                        : false;
                    
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: InkWell(
                        onTap: () => _toggleStep(context, index),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isStepCompleted,
                              onChanged: (_) => _toggleStep(context, index),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 11),
                                child: Text(
                                  step,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isStepCompleted ? Colors.grey[600] : Colors.grey[300],
                                    decoration: isStepCompleted ? TextDecoration.lineThrough : null,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _toggleGoal(BuildContext context) {
    // Capturar estado actual antes de cambiar
    final wasCompleted = widget.goal.isCompleted;
    
    context.read<GoalsProvider>().toggleGoal(widget.goal.id);
    
    // Activar confeti si se está completando (no descompletando)
    if (!wasCompleted && widget.onGoalCompleted != null) {
      widget.onGoalCompleted!();
    }
  }

  void _toggleStep(BuildContext context, int stepIndex) {
    final provider = context.read<GoalsProvider>();
    final updatedStepsCompleted = List<bool>.from(widget.goal.stepsCompleted);
    
    // Asegurar que la lista tenga el tamaño correcto
    while (updatedStepsCompleted.length < widget.goal.steps.length) {
      updatedStepsCompleted.add(false);
    }
    
    updatedStepsCompleted[stepIndex] = !updatedStepsCompleted[stepIndex];
    
    final updatedGoal = widget.goal.copyWith(stepsCompleted: updatedStepsCompleted);
    provider.updateGoal(updatedGoal);
  }

  void _deleteGoal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar meta?'),
        content: Text('¿Estás seguro de eliminar "${widget.goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GoalsProvider>().deleteGoal(widget.goal.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _editGoal(BuildContext context) {
    final titleController = TextEditingController(text: widget.goal.title);
    final descController = TextEditingController(text: widget.goal.description ?? '');
    final stepController = TextEditingController();
    final steps = List<String>.from(widget.goal.steps);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Meta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text('Pasos:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...steps.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text('${e.key + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: e.value),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => steps[e.key] = value,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => setState(() => steps.removeAt(e.key)),
                      ),
                    ],
                  ),
                )),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stepController,
                        decoration: const InputDecoration(
                          hintText: 'Nuevo paso',
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (stepController.text.isNotEmpty) {
                          setState(() {
                            steps.add(stepController.text);
                            stepController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = widget.goal.copyWith(
                  title: titleController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  steps: steps,
                  stepsCompleted: List.filled(steps.length, false),
                );
                context.read<GoalsProvider>().updateGoal(updated);
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
