import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/goals_provider.dart';
import '../widgets/add_goal_dialog.dart';

class PersonalRulesScreen extends StatelessWidget {
  const PersonalRulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Reglas Personales'),
        elevation: 0,
        backgroundColor: const Color(0xFF2D3142),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar Regla',
            onPressed: () => _showAddRuleDialog(context),
          ),
        ],
      ),
      body: Consumer<GoalsProvider>(
        builder: (context, goalsProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header explicativo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFBF40BF), Color(0xFF8B2F8B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBF40BF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tus Principios Inquebrantables',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No se completan, se viven',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Las reglas personales son los pilares de tu identidad. No son metas temporales, son compromisos permanentes que defines quién eres y quién quieres ser.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).scale(duration: 500.ms),
                
                const SizedBox(height: 32),
                
                // Contador
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBF40BF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBF40BF).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield, color: Color(0xFFBF40BF), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${goalsProvider.personalRules.length} ${goalsProvider.personalRules.length == 1 ? "Regla" : "Reglas"}',
                            style: const TextStyle(
                              color: Color(0xFFBF40BF),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0, delay: 200.ms),
                
                const SizedBox(height: 24),
                
                // Lista de reglas
                if (goalsProvider.personalRules.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No has definido tus reglas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Las reglas personales son tu código inquebrantable',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _showAddRuleDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Primera Regla'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBF40BF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms)
                else
                  ...goalsProvider.personalRules.asMap().entries.map((entry) {
                    final rule = entry.value;
                    final index = entry.key;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            const Color(0xFFBF40BF).withOpacity(0.03),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFBF40BF).withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBF40BF).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBF40BF).withOpacity(0.05),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBF40BF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.shield,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    rule.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3142),
                                    ),
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_vert, color: Color(0xFF6C757D)),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(Icons.edit, size: 18, color: Color(0xFF2D3142)),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                      onTap: () {
                                        Future.delayed(Duration.zero, () => _showEditRuleDialog(context, rule));
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(Icons.delete, size: 18, color: Color(0xFFFF6B6B)),
                                          SizedBox(width: 8),
                                          Text('Eliminar', style: TextStyle(color: Color(0xFFFF6B6B))),
                                        ],
                                      ),
                                      onTap: () {
                                        Future.delayed(Duration.zero, () => _confirmDelete(context, rule.id));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Descripción
                          if (rule.description != null && rule.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                rule.description!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6C757D),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          
                          // Footer
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBF40BF).withOpacity(0.03),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.auto_awesome, size: 16, color: Color(0xFFBF40BF)),
                                SizedBox(width: 8),
                                Text(
                                  'Principio Inquebrantable',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFBF40BF),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (300 + index * 100).ms).slideX(begin: -0.1, end: 0, delay: (300 + index * 100).ms);
                  }),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddRuleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddGoalDialog(isRule: true),
    );
  }

  void _showEditRuleDialog(BuildContext context, goal) {
    showDialog(
      context: context,
      builder: (context) => AddGoalDialog(existingGoal: goal, isRule: true),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar regla?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GoalsProvider>().deleteGoal(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
