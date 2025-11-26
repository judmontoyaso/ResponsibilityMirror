import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/personal_note.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({Key? key}) : super(key: key);

  static final List<Color> postItColors = [
    const Color(0xFFFFF740), // Amarillo
    const Color(0xFFFF6B9D), // Rosa
    const Color(0xFF00E5FF), // Cyan
    const Color(0xFF76FF03), // Verde lima
    const Color(0xFFFF9100), // Naranja
    const Color(0xFFE040FB), // Púrpura
  ];

  void _showAddNoteDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    int selectedColorIndex = 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '✍️ Nueva Nota Personal',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Escribe algo sincero para ti mismo...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: postItColors[selectedColorIndex], width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Color del Post-it:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(postItColors.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColorIndex = index;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: postItColors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColorIndex == index
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: postItColors[index].withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: selectedColorIndex == index ? 2 : 0,
                            ),
                          ],
                        ),
                        child: selectedColorIndex == index
                            ? const Icon(Icons.check, color: Colors.black87)
                            : null,
                      ),
                    );
                  }),
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
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  dialogContext.read<NotesProvider>().addNote(
                    controller.text.trim(),
                    colorIndex: selectedColorIndex,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✓ Nota agregada al espejo'),
                      backgroundColor: postItColors[selectedColorIndex].withOpacity(0.8),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: postItColors[selectedColorIndex],
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, PersonalNote note) {
    final TextEditingController controller = TextEditingController(text: note.content);
    int selectedColorIndex = note.colorIndex;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '✏️ Editar Nota',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Edita tu nota...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: postItColors[selectedColorIndex], width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Color del Post-it:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(postItColors.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColorIndex = index;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: postItColors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColorIndex == index ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selectedColorIndex == index
                            ? const Icon(Icons.check, color: Colors.black87)
                            : null,
                      ),
                    );
                  }),
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
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  note.content = controller.text.trim();
                  note.colorIndex = selectedColorIndex;
                  dialogContext.read<NotesProvider>().updateNote(note);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: postItColors[selectedColorIndex],
                foregroundColor: Colors.black87,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '📌 Notas del Espejo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          if (notesProvider.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 80, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notas aún',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca el botón + para crear\nuna nota sincera para ti',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: notesProvider.notes.length,
            itemBuilder: (context, index) {
              final note = notesProvider.notes[index];
              return _buildPostItNote(context, note, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        backgroundColor: const Color(0xFFFFF740),
        child: const Icon(Icons.add, color: Colors.black87, size: 32),
      ),
    );
  }

  Widget _buildPostItNote(BuildContext context, PersonalNote note, int index) {
    final color = postItColors[note.colorIndex % postItColors.length];
    
    return GestureDetector(
      onTap: () => _showEditNoteDialog(context, note),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('¿Eliminar nota?', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Esta nota se eliminará permanentemente.',
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  context.read<NotesProvider>().deleteNote(note);
                  Navigator.pop(context);
                },
                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Transform.rotate(
        angle: (index % 2 == 0 ? -0.02 : 0.02),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pin visual
              Container(
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
              ),
              const SizedBox(height: 12),
              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    note.content,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Fecha
              const SizedBox(height: 8),
              Text(
                _formatDate(note.createdAt),
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
