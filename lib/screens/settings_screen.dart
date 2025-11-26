import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/notifications_provider.dart';
import '../models/notification_config.dart';
import '../services/notification_service.dart';
import 'phrases_screen.dart';
import 'notes_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Perfil
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Nombre'),
                  subtitle: Text(
                    settings.userName.isEmpty 
                        ? 'Sin nombre' 
                        : settings.userName
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showNameDialog(context),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Gestión de Contenido
          Text(
            'Gestión de Contenido',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.format_quote, color: Colors.red),
                  ),
                  title: const Text('Frases Motivacionales'),
                  subtitle: const Text('Ver y agregar frases personalizadas'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PhrasesScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sticky_note_2, color: Colors.yellow),
                  ),
                  title: const Text('Notas del Espejo'),
                  subtitle: const Text('Post-its sinceros para ti mismo'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotesScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Notificaciones
          Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 12),
          
          Consumer<NotificationsProvider>(
            builder: (context, notifProvider, _) {
              return Column(
                children: [
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.style),
                          title: const Text('Modo de notificaciones'),
                          subtitle: Text(_getModeLabel(notifProvider.currentMode)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: SegmentedButton<NotificationMode>(
                            segments: const [
                              ButtonSegment(
                                value: NotificationMode.gogginsBrutal,
                                label: Text('Brutal'),
                                icon: Icon(Icons.fitness_center),
                              ),
                              ButtonSegment(
                                value: NotificationMode.balanced,
                                label: Text('Equilibrado'),
                                icon: Icon(Icons.balance),
                              ),
                              ButtonSegment(
                                value: NotificationMode.motivationalSoft,
                                label: Text('Suave'),
                                icon: Icon(Icons.favorite),
                              ),
                            ],
                            selected: {notifProvider.currentMode},
                            onSelectionChanged: (Set<NotificationMode> selected) {
                              notifProvider.setMode(selected.first);
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Lista de notificaciones
                  if (notifProvider.configs.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.notifications_off, size: 48, color: Colors.grey[600]),
                              const SizedBox(height: 12),
                              Text(
                                'No hay notificaciones programadas',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...notifProvider.configs.map((config) {
                      // Formatear horas con minutos
                      String horasTexto = '';
                      for (int i = 0; i < config.hours.length; i++) {
                        final hora = config.hours[i];
                        final minuto = (config.minutes != null && i < config.minutes!.length) 
                            ? config.minutes![i] 
                            : 0;
                        if (i > 0) horasTexto += ', ';
                        horasTexto += '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
                      }
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Switch(
                            value: config.isEnabled,
                            onChanged: (_) => notifProvider.toggleNotification(config.id),
                          ),
                          title: const Text('Frases aleatorias'),
                          subtitle: Text(
                            horasTexto,
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditNotificationDialog(context, config, notifProvider),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => notifProvider.deleteNotification(config.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  
                  const SizedBox(height: 8),
                  
                  OutlinedButton.icon(
                    onPressed: () => _showAddNotificationDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar notificación'),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Botón para ir a configuración de permisos
                  OutlinedButton.icon(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.grey[900],
                          title: const Text(
                            '⚙️ Configurar Permisos',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Para que las notificaciones funcionen correctamente:',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '1. Ve a Ajustes del sistema',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '2. Apps → Responsibility Mirror',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '3. Notificaciones → Activar TODO',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '4. Permisos → Alarmas y recordatorios → Permitir',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '⚠️ Importante: No optimices la batería para esta app',
                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Entendido'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Guía de permisos'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Acerca de
          Text(
            'Acerca de',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Responsibility Mirror',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.0.0',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Inspirado en David Goggins',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"El único enemigo que no puede derrotarte es el que vive dentro de ti."',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNameDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final controller = TextEditingController(text: settings.userName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tu nombre'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu nombre',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              settings.setUserName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddNotificationDialog(BuildContext context) {
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    List<String> selectedTimes = [];
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '⏰ Programar Notificaciones',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hora de la notificación:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                
                // Selector moderno de hora
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, color: Colors.orange, size: 32),
                          const SizedBox(width: 16),
                          Text(
                            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colors.orange,
                                    onPrimary: Colors.black,
                                    surface: Color(0xFF1E1E1E),
                                    onSurface: Colors.white,
                                  ),
                                  dialogBackgroundColor: const Color(0xFF1E1E1E),
                                ),
                                child: child!,
                              );
                            },
                          );
                          
                          if (picked != null) {
                            setState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.edit_calendar),
                        label: const Text('Cambiar Hora'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                      if (!selectedTimes.contains(timeString)) {
                        selectedTimes.add(timeString);
                        selectedTimes.sort();
                      }
                    });
                  },
                  icon: const Icon(Icons.add_alarm),
                  label: const Text('Agregar Esta Hora'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                if (selectedTimes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Horas programadas:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedTimes.map((time) {
                        return Chip(
                          label: Text(
                            time,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.orange,
                          deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                          onDeleted: () {
                            setState(() {
                              selectedTimes.remove(time);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Se enviará una frase aleatoria a cada hora programada',
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: selectedTimes.isEmpty ? null : () {
                final notifProvider = dialogContext.read<NotificationsProvider>();
                
                // Convertir las horas seleccionadas en formato de horas y minutos
                final hours = <int>[];
                final minutes = <int>[];
                
                for (var time in selectedTimes) {
                  final parts = time.split(':');
                  hours.add(int.parse(parts[0]));
                  minutes.add(int.parse(parts[1]));
                }
                
                notifProvider.addNotification(
                  NotificationConfig(
                    id: notifProvider.createNewId(),
                    message: 'Mensaje aleatorio',
                    mode: notifProvider.currentMode,
                    hours: hours,
                    minutes: minutes,
                    isCustom: true,
                  ),
                );
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${selectedTimes.length} notificaciones programadas'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Programar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _getModeLabel(NotificationMode mode) {
    switch (mode) {
      case NotificationMode.gogginsBrutal:
        return 'Brutal (Estilo Goggins)';
      case NotificationMode.motivationalSoft:
        return 'Suave (Compasivo)';
      case NotificationMode.balanced:
        return 'Equilibrado';
    }
  }

  void _showEditNotificationDialog(BuildContext context, NotificationConfig config, NotificationsProvider notifProvider) {
    // Reconstruir las horas existentes en formato HH:MM FUERA del builder
    final List<String> selectedTimes = [];
    for (int i = 0; i < config.hours.length; i++) {
      final hour = config.hours[i];
      final minute = (config.minutes != null && i < config.minutes!.length) 
          ? config.minutes![i] 
          : 0;
      selectedTimes.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Editar alarma', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Horas programadas:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedTimes.map((time) => Chip(
                      label: Text(time),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() => selectedTimes.remove(time));
                      },
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  OutlinedButton.icon(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark(),
                            child: child!,
                          );
                        },
                      );
                      
                      if (picked != null) {
                        final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        if (!selectedTimes.contains(timeStr)) {
                          setState(() => selectedTimes.add(timeStr));
                        }
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: const Text('Agregar hora'),
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
                onPressed: selectedTimes.isEmpty ? null : () {
                  final hours = <int>[];
                  final minutes = <int>[];
                  
                  for (var time in selectedTimes) {
                    final parts = time.split(':');
                    hours.add(int.parse(parts[0]));
                    minutes.add(int.parse(parts[1]));
                  }
                  
                  final updated = config.copyWith(
                    hours: hours,
                    minutes: minutes,
                  );
                  
                  notifProvider.updateNotification(updated);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Alarma actualizada'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
