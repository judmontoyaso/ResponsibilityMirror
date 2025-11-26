import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goals_provider.dart';

class MirrorGoalItem extends StatelessWidget {
  final Goal goal;
  final bool isRule;

  const MirrorGoalItem({
    super.key,
    required this.goal,
    this.isRule = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isRule ? null : () => _toggleGoal(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (!isRule)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: goal.isCompleted ? Colors.green : Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      color: goal.isCompleted 
                          ? Colors.green.withOpacity(0.3) 
                          : Colors.transparent,
                    ),
                    child: goal.isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 20,
                          )
                        : null,
                  )
                else
                  Icon(
                    Icons.military_tech,
                    color: Colors.amber.withOpacity(0.8),
                    size: 28,
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: isRule ? 18 : 16,
                          fontWeight: isRule ? FontWeight.bold : FontWeight.w600,
                          color: goal.isCompleted 
                              ? Colors.white.withOpacity(0.4)
                              : Colors.white.withOpacity(0.9),
                          decoration: goal.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                          letterSpacing: isRule ? 1 : 0,
                        ),
                      ),
                      if (goal.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            goal.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                    ],
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
                      '!',
                      style: TextStyle(
                        color: _getPriorityColor(goal.priority),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleGoal(BuildContext context) {
    context.read<GoalsProvider>().toggleGoal(goal.id);
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      default:
        return Colors.white;
    }
  }
}
