import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phrases_provider.dart';
import '../providers/goals_provider.dart';
import '../utils/quotes.dart';

class PhrasesScreen extends StatefulWidget {
  const PhrasesScreen({Key? key}) : super(key: key);

  @override
  State<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends State<PhrasesScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Goggins'),
            Tab(text: 'Personalizadas'),
            Tab(text: 'Mías'),
          ],
        ),
      ),
      body: Consumer2<PhrasesProvider, GoalsProvider>(
        builder: (context, phrasesProvider, goalsProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Frases de Goggins
              _buildPhrasesTab(
                phrases: MotivationalQuotes.gogginsBrutal,
                emptyMessage: 'No hay frases de Goggins',
                isDefault: true,
              ),
              
              // Tab 2: Frases generadas por IA
              _buildAIPhrasesTab(phrasesProvider, goalsProvider),
              
              // Tab 3: Frases personalizadas manuales
              _buildCustomPhrasesTab(phrasesProvider),
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

  Widget _buildPhrasesTab({
    required List<String> phrases,
    required String emptyMessage,
    required bool isDefault,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: phrases.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              phrases[index],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIPhrasesTab(PhrasesProvider provider, GoalsProvider goalsProvider) {
    final aiPhrases = provider.aiPhrases;
    
    if (aiPhrases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, size: 80, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                'No hay frases generadas por IA',
                style: TextStyle(color: Colors.grey[400], fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ve a Ajustes > Generar Frases con IA',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: aiPhrases.length,
      itemBuilder: (context, index) {
        final phrase = aiPhrases[index];
        final relatedGoal = phrase.relatedGoal != null
            ? goalsProvider.goals.firstWhere(
                (g) => g.id == phrase.relatedGoal,
                orElse: () => goalsProvider.goals.first,
              )
            : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.purple.withOpacity(0.3),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              phrase.text,
              style: TextStyle(
                color: phrase.isActive ? Colors.white : Colors.grey[600],
                fontSize: 15,
                decoration: phrase.isEdited ? TextDecoration.none : null,
              ),
            ),
            subtitle: relatedGoal != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.flag, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            relatedGoal.title,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (phrase.isEdited)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'EDITADA',
                              style: TextStyle(color: Colors.blue, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  )
                : phrase.isEdited
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'EDITADA',
                            style: TextStyle(color: Colors.blue, fontSize: 10),
                          ),
                        ),
                      )
                    : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    phrase.isActive ? Icons.visibility : Icons.visibility_off,
                    color: phrase.isActive ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => provider.toggleAIPhrase(index),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editAIPhrase(context, provider, index, phrase.text),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteAIPhrase(context, provider, index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomPhrasesTab(PhrasesProvider provider) {
    final customPhrases = provider.customPhrases;
    
    if (customPhrases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.format_quote, size: 80, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                'No hay frases personalizadas',
                style: TextStyle(color: Colors.grey[400], fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Toca el botón + para agregar',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customPhrases.length,
      itemBuilder: (context, index) {
        final phrase = customPhrases[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              phrase.text,
              style: TextStyle(
                color: phrase.isActive ? Colors.white : Colors.grey[600],
                fontSize: 15,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    phrase.isActive ? Icons.visibility : Icons.visibility_off,
                    color: phrase.isActive ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => provider.togglePhrase(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCustomPhrase(context, provider, index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editAIPhrase(BuildContext context, PhrasesProvider provider, int index, String currentText) {
    final controller = TextEditingController(text: currentText);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '✏️ Editar Frase IA',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Edita la frase...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.purple, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.editAIPhrase(index, controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Frase editada'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteAIPhrase(BuildContext context, PhrasesProvider provider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '¿Eliminar frase IA?',
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
              provider.deleteAIPhrase(index);
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
  }

  void _deleteCustomPhrase(BuildContext context, PhrasesProvider provider, int index) {
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
              provider.deletePhrase(index);
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
  }
}
