import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phrases_provider.dart';
import '../utils/quotes.dart';

class PhrasesScreen extends StatefulWidget {
  const PhrasesScreen({Key? key}) : super(key: key);

  @override
  State<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends State<PhrasesScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddPhraseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Agregar Nueva Frase',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Escribe una frase motivacional brutal...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                context.read<PhrasesProvider>().addPhrase(_controller.text.trim());
                _controller.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Frase agregada'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar'),
          ),
        ],
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
          'Frases Motivacionales',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<PhrasesProvider>(
        builder: (context, phrasesProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Sección de frases de David Goggins
              _buildSection(
                'David Goggins (${MotivationalQuotes.gogginsBrutal.length})',
                MotivationalQuotes.gogginsBrutal,
                isDefault: true,
              ),
              
              const SizedBox(height: 24),
              
              // Sección de frases personalizadas
              _buildSection(
                'Mis Frases Personalizadas (${phrasesProvider.customPhrases.length})',
                phrasesProvider.customPhrases.map((p) => p.text).toList(),
                isDefault: false,
                customPhrases: phrasesProvider.customPhrases,
              ),
              
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPhraseDialog,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add),
        label: const Text(
          'Agregar Frase',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> phrases, {
    required bool isDefault,
    List<dynamic>? customPhrases,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: isDefault ? Colors.red : Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (phrases.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Center(
              child: Text(
                'No hay frases personalizadas aún.\nToca el botón + para agregar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...phrases.asMap().entries.map((entry) {
            int index = entry.key;
            String phrase = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDefault ? Colors.red.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  phrase,
                  style: TextStyle(
                    color: customPhrases != null && !customPhrases[index].isActive
                        ? Colors.grey[600]
                        : Colors.white,
                    fontSize: 15,
                  ),
                ),
                trailing: isDefault
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Toggle activo/inactivo
                          IconButton(
                            icon: Icon(
                              customPhrases![index].isActive
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: customPhrases[index].isActive
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              context.read<PhrasesProvider>().togglePhrase(index);
                            },
                          ),
                          // Eliminar
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.grey[900],
                                  title: const Text(
                                    '¿Eliminar frase?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Esta acción no se puede deshacer.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.read<PhrasesProvider>().deletePhrase(index);
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
