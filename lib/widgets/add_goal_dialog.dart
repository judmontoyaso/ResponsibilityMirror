import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goals_provider.dart';

class AddGoalDialog extends StatefulWidget {
  final Goal? existingGoal;
  final bool isRule;
  
  const AddGoalDialog({super.key, this.existingGoal, this.isRule = false});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepController = TextEditingController();
  final List<String> _steps = [];
  GoalType _selectedType = GoalType.daily;
  int _selectedPriority = 1;
  
  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      _titleController.text = widget.existingGoal!.title;
      _descriptionController.text = widget.existingGoal!.description ?? '';
      _steps.addAll(widget.existingGoal!.steps);
      _selectedType = widget.existingGoal!.type;
      _selectedPriority = widget.existingGoal!.priority;
    } else if (widget.isRule) {
      _selectedType = GoalType.personal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingGoal != null;
    final title = isEditing 
      ? 'Editar ${widget.isRule ? "Regla" : "Meta"}'
      : widget.isRule 
        ? 'Nueva Regla Personal' 
        : 'Nueva Meta';
    
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Entrenar 30 minutos',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Detalles adicionales',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.list_alt, size: 20, color: Colors.grey[400]),
                const SizedBox(width: 8),
                const Text(
                  'Pasos/Submetas para lograrlo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_steps.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Agrega pasos específicos que te acercarán a tu meta',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  children: _steps.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(color: Colors.grey[200]),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.red,
                          onPressed: () {
                            setState(() => _steps.removeAt(entry.key));
                          },
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Ir al gym 4 veces por semana',
                      isDense: true,
                      prefixIcon: const Icon(Icons.add_circle_outline, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (value) => _addStep(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: _addStep,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Hide goal type selector when creating/editing a rule
            if (!widget.isRule) ...[
              const Text(
                'Tipo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<GoalType>(
                segments: const [
                  ButtonSegment(
                    value: GoalType.daily,
                    label: Text('Diaria'),
                    icon: Icon(Icons.today),
                  ),
                  ButtonSegment(
                    value: GoalType.personal,
                    label: Text('Regla'),
                    icon: Icon(Icons.star),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<GoalType> selected) {
                  setState(() => _selectedType = selected.first);
                },
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Prioridad',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedPriority = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedPriority == 1 ? Colors.green.withOpacity(0.2) : Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedPriority == 1 ? Colors.green : Colors.grey[800]!,
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.green),
                          SizedBox(height: 4),
                          Text('Normal', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedPriority = 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedPriority == 2 ? Colors.orange.withOpacity(0.2) : Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedPriority == 2 ? Colors.orange : Colors.grey[800]!,
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.horizontal_rule, color: Colors.orange),
                          SizedBox(height: 4),
                          Text('Media', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedPriority = 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedPriority == 3 ? Colors.red.withOpacity(0.2) : Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedPriority == 3 ? Colors.red : Colors.grey[800]!,
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.red),
                          SizedBox(height: 4),
                          Text('Alta', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
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
          onPressed: _saveGoal,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _addStep() {
    if (_stepController.text.isEmpty) return;
    setState(() {
      _steps.add(_stepController.text);
      _stepController.clear();
    });
  }

  void _saveGoal() {
    if (_titleController.text.isEmpty) return;

    final goalsProvider = context.read<GoalsProvider>();
    
    if (widget.existingGoal != null) {
      // Editing existing goal
      print('✏️ Editando meta: ${widget.existingGoal!.title}');
      final updatedGoal = widget.existingGoal!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
        type: _selectedType,
        priority: _selectedPriority,
        steps: _steps,
        stepsCompleted: List.filled(_steps.length, false),
      );
      goalsProvider.updateGoal(updatedGoal);
    } else {
      // Creating new goal
      print('💾 Guardando meta con ${_steps.length} pasos');
      for (var i = 0; i < _steps.length; i++) {
        print('   Paso $i: ${_steps[i]}');
      }

      final goal = Goal(
        id: goalsProvider.createNewGoalId(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
        createdAt: DateTime.now(),
        type: widget.isRule ? GoalType.personal : _selectedType,
        priority: _selectedPriority,
        steps: _steps,
      );

      print('✅ Meta creada: ${goal.title}');
      print('📋 Pasos en la meta: ${goal.steps.length}');
      
      goalsProvider.addGoal(goal);
    }
    
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepController.dispose();
    super.dispose();
  }
}
