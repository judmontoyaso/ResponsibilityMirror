import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/checkin.dart';
import '../providers/goals_provider.dart';
import '../utils/quotes.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _notesController = TextEditingController();
  final _checkinsBox = Hive.box('checkins');
  final _uuid = const Uuid();
  
  CheckInMood _selectedMood = CheckInMood.neutral;
  bool? _completed;
  List<DailyCheckIn> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _checkTodayCheckIn();
  }

  void _loadHistory() {
    final data = _checkinsBox.values.toList();
    _history = data.map((e) => DailyCheckIn(
      id: e['id'],
      date: DateTime.parse(e['date']),
      completed: e['completed'],
      notes: e['notes'],
      goalsCompleted: e['goalsCompleted'],
      goalsTotal: e['goalsTotal'],
      mood: CheckInMood.values[e['mood'] ?? 2],
    )).toList();
    
    _history.sort((a, b) => b.date.compareTo(a.date));
    setState(() {});
  }

  void _checkTodayCheckIn() {
    final today = DateTime.now();
    final todayCheckIn = _history.where((c) => 
      c.date.year == today.year && 
      c.date.month == today.month && 
      c.date.day == today.day
    ).firstOrNull;
    
    if (todayCheckIn != null) {
      _completed = todayCheckIn.completed;
      _selectedMood = todayCheckIn.mood;
      _notesController.text = todayCheckIn.notes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in Diario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prompt motivacional
            Card(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.question_mark, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      MotivationalQuotes.getCheckInPrompt(),
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ¿Cumpliste?
            Text(
              '¿Cumpliste tus compromisos?',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildChoiceButton(
                    context,
                    label: 'SÍ',
                    value: true,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChoiceButton(
                    context,
                    label: 'NO',
                    value: false,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Estado de ánimo
            Text(
              '¿Cómo te sientes?',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: CheckInMood.values.map((mood) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_getMoodLabel(mood)),
                      selected: _selectedMood == mood,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedMood = mood);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Notas
            Text(
              'Notas del día (opcional)',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '¿Qué aprendiste hoy? ¿Qué harás mejor mañana?',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completed != null ? _saveCheckIn : null,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Guardar Check-in'),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Historial
            Text(
              'Historial',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            
            if (_history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Sin check-ins anteriores'),
                ),
              )
            else
              ..._history.take(7).map((checkin) => _buildHistoryItem(checkin)),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(
    BuildContext context, {
    required String label,
    required bool value,
    required Color color,
  }) {
    final isSelected = _completed == value;
    
    return OutlinedButton(
      onPressed: () => setState(() => _completed = value),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.2) : null,
        side: BorderSide(
          color: isSelected ? color : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.all(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isSelected ? color : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(DailyCheckIn checkin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          checkin.completed ? Icons.check_circle : Icons.cancel,
          color: checkin.completed ? Colors.green : Colors.red,
        ),
        title: Text(
          _formatDate(checkin.date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${checkin.goalsCompleted}/${checkin.goalsTotal} metas • ${_getMoodLabel(checkin.mood)}',
        ),
        trailing: Text(
          '${(checkin.completionRate * 100).round()}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _saveCheckIn() async {
    final goalsProvider = context.read<GoalsProvider>();
    
    final checkin = DailyCheckIn(
      id: _uuid.v4(),
      date: DateTime.now(),
      completed: _completed!,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      goalsCompleted: goalsProvider.completedToday.length,
      goalsTotal: goalsProvider.dailyGoals.length + goalsProvider.completedToday.length,
      mood: _selectedMood,
    );
    
    await _checkinsBox.put(checkin.id, {
      'id': checkin.id,
      'date': checkin.date.toIso8601String(),
      'completed': checkin.completed,
      'notes': checkin.notes,
      'goalsCompleted': checkin.goalsCompleted,
      'goalsTotal': checkin.goalsTotal,
      'mood': checkin.mood.index,
    });
    
    _loadHistory();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in guardado ✅')),
      );
    }
  }

  String _getMoodLabel(CheckInMood mood) {
    switch (mood) {
      case CheckInMood.great:
        return '🔥 Excelente';
      case CheckInMood.good:
        return '😊 Bien';
      case CheckInMood.neutral:
        return '😐 Normal';
      case CheckInMood.struggled:
        return '😓 Difícil';
      case CheckInMood.failed:
        return '😞 Fallé';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}
