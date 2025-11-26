import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final goalsProvider = context.watch<GoalsProvider>();
    final completionRate = goalsProvider.getTodayCompletionRate();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Check-in Diario'),
        elevation: 0,
        backgroundColor: const Color(0xFF2D3142),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver Historial Completo',
            onPressed: () => _showFullHistory(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: completionRate >= 70 
                    ? [const Color(0xFF51CF66), const Color(0xFF40C057)]
                    : completionRate >= 40
                      ? [const Color(0xFFFFA94D), const Color(0xFFFF922B)]
                      : [const Color(0xFFFF6B6B), const Color(0xFFF03E3E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progreso de Hoy',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '¿Cómo te fue?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$completionRate%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completionRate / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${goalsProvider.completedToday.length}/${goalsProvider.dailyGoals.length + goalsProvider.completedToday.length} metas completadas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).scale(duration: 500.ms),
            
            const SizedBox(height: 24),
            
            // Prompt motivacional
            Card(
              elevation: 0,
              color: const Color(0xFF2D3142).withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3142).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 32,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      MotivationalQuotes.getCheckInPrompt(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3142),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0, delay: 200.ms),
            
            const SizedBox(height: 24),
            
            // ¿Cumpliste?
            const Text(
              '¿Cumpliste tus compromisos?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildChoiceButton(
                    context,
                    label: 'SÍ ✓',
                    value: true,
                    color: const Color(0xFF51CF66),
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChoiceButton(
                    context,
                    label: 'NO ✗',
                    value: false,
                    color: const Color(0xFFFF6B6B),
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),
            
            const SizedBox(height: 24),
            
            // Estado de ánimo
            const Text(
              '¿Cómo te sientes?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CheckInMood.values.map((mood) {
                final isSelected = _selectedMood == mood;
                return InkWell(
                  onTap: () => setState(() => _selectedMood = mood),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D3142) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2D3142) : const Color(0xFFE9ECEF),
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFF2D3142).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Text(
                      _getMoodLabel(mood),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF2D3142),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0, delay: 400.ms),
            
            const SizedBox(height: 24),
            
            // Notas
            const Text(
              'Reflexiones del día',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Qué aprendiste? ¿Qué harás mejor mañana?',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6C757D),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _notesController,
              maxLines: 5,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Escribe tus reflexiones aquí...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D3142), width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ).animate().fadeIn(delay: 500.ms),
            
            const SizedBox(height: 24),
            
            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completed != null ? _saveCheckIn : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF51CF66),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: const Color(0xFFE9ECEF),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Guardar Check-in',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),
            
            const SizedBox(height: 32),
            
            // Historial reciente
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Últimos Check-ins',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showFullHistory(context),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Ver todo'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (_history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sin check-ins anteriores',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._history.take(3).map((checkin) => _buildHistoryItem(checkin)),
            
            const SizedBox(height: 24),
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
    required IconData icon,
  }) {
    final isSelected = _completed == value;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: OutlinedButton(
        onPressed: () => setState(() => _completed = value),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.white,
          side: BorderSide(
            color: isSelected ? color : const Color(0xFFE9ECEF),
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(DailyCheckIn checkin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: checkin.completed 
            ? const Color(0xFF51CF66).withOpacity(0.3)
            : const Color(0xFFFF6B6B).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: checkin.completed 
                ? const Color(0xFF51CF66).withOpacity(0.1)
                : const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              checkin.completed ? Icons.check_circle : Icons.cancel,
              color: checkin.completed ? const Color(0xFF51CF66) : const Color(0xFFFF6B6B),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(checkin.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${checkin.goalsCompleted}/${checkin.goalsTotal} metas • ${_getMoodLabel(checkin.mood)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: checkin.completed 
                ? const Color(0xFF51CF66).withOpacity(0.1)
                : const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(checkin.completionRate * 100).round()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: checkin.completed ? const Color(0xFF51CF66) : const Color(0xFFFF6B6B),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (700 + _history.indexOf(checkin) * 100).ms);
  }

  void _showFullHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Historial Completo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
              Expanded(
                child: _history.isEmpty
                  ? const Center(child: Text('Sin check-ins registrados'))
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _history.length,
                      itemBuilder: (context, index) => _buildHistoryItem(_history[index]),
                    ),
              ),
            ],
          ),
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
