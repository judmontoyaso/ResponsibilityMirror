import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phrases_provider.dart';
import '../providers/goals_provider.dart';
import '../services/gemma_phrases_service.dart';
import '../models/goal.dart';

class AIPhrasesGeneratorScreen extends StatefulWidget {
  const AIPhrasesGeneratorScreen({super.key});

  @override
  State<AIPhrasesGeneratorScreen> createState() => _AIPhrasesGeneratorScreenState();
}

class _AIPhrasesGeneratorScreenState extends State<AIPhrasesGeneratorScreen> {
  final _gemmaService = GemmaPhrasesService();
  bool _isLoading = false;
  List<String> _generatedPhrases = [];
  final List<bool> _selectedPhrases = [];
  String? _selectedGoalId;
  bool _brutalMode = true;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      await _gemmaService.initialize();
      if (!_gemmaService.isReady()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showModelNotFoundDialog();
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showModelNotFoundDialog();
      });
    }
  }

  void _showModelNotFoundDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('📦 Modelo Gemma 3 270M no encontrado'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para usar generación de frases con IA local, necesitas descargar el modelo Gemma 3 270M.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Pasos:'),
              SizedBox(height: 8),
              Text('1. Descarga el modelo INT4 (~70MB):'),
              Text(
                'https://huggingface.co/litert-community/gemma-3-270m-it',
                style: TextStyle(fontSize: 11, color: Colors.blue),
              ),
              SizedBox(height: 8),
              Text('2. Coloca el archivo .tflite en:'),
              Text(
                'assets/models/gemma3_270m_int4.tflite',
                style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
              SizedBox(height: 8),
              Text('3. Agrega en pubspec.yaml:'),
              Text(
                'flutter:\n  assets:\n    - assets/models/',
                style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
              SizedBox(height: 8),
              Text('4. Recompila la app'),
              SizedBox(height: 16),
              Text(
                '⚠️ Mientras tanto, la app usará frases predefinidas personalizadas.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
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
  }

  Future<void> _generatePhrases() async {
    if (!_gemmaService.isReady()) {
      _showModelNotFoundDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedPhrases = [];
      _selectedPhrases.clear();
    });

    try {
      List<String> phrases;
      
      if (_selectedGoalId != null) {
        // Generar frases para una meta específica
        final goalsProvider = context.read<GoalsProvider>();
        final goal = goalsProvider.goals.firstWhere((g) => g.id == _selectedGoalId);
        
        phrases = await _gemmaService.generatePhrasesForGoal(
          goalTitle: goal.title,
          goalDescription: goal.description ?? '',
          count: 10,
          brutalMode: _brutalMode,
        );
      } else {
        // Generar frases genéricas
        phrases = await _gemmaService.generateGenericPhrases(
          count: 10,
          brutalMode: _brutalMode,
        );
      }

      setState(() {
        _generatedPhrases = phrases;
        _selectedPhrases.addAll(List.filled(phrases.length, true)); // Todas seleccionadas por defecto
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generando frases: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePhrases() async {
    final phrasesProvider = context.read<PhrasesProvider>();
    
    int saved = 0;
    for (int i = 0; i < _generatedPhrases.length; i++) {
      if (_selectedPhrases[i]) {
        await phrasesProvider.addAIPhrase(
          _generatedPhrases[i],
          relatedGoal: _selectedGoalId,
        );
        saved++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $saved frases guardadas correctamente'),
          backgroundColor: const Color(0xFF51CF66),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsProvider = context.watch<GoalsProvider>();
    final activeGoals = goalsProvider.goals.where((g) => g.isCompleted == false).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '🤖 Generar Frases con IA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2D3142),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con explicación
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.psychology, size: 40, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Genera frases motivacionales personalizadas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Powered by Llama 3.3 70B (DigitalOcean AI)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Selector de meta
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎯 Meta relacionada (opcional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      value: _selectedGoalId,
                      decoration: InputDecoration(
                        hintText: 'Frases genéricas',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sin meta específica (genérica)'),
                        ),
                        ...activeGoals.map((goal) => DropdownMenuItem(
                          value: goal.id,
                          child: Text(
                            goal.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedGoalId = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modo brutal/suave
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💪 Estilo de frases',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyleButton(
                            label: 'Brutal',
                            subtitle: 'Estilo Goggins',
                            icon: Icons.local_fire_department,
                            color: const Color(0xFFFF6B6B),
                            isSelected: _brutalMode,
                            onTap: () => setState(() => _brutalMode = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStyleButton(
                            label: 'Suave',
                            subtitle: 'Motivador',
                            icon: Icons.favorite,
                            color: const Color(0xFF51CF66),
                            isSelected: !_brutalMode,
                            onTap: () => setState(() => _brutalMode = false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón generar
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generatePhrases,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'Generando...' : 'Generar Frases'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Lista de frases generadas
            if (_generatedPhrases.isNotEmpty) ...[
              Text(
                '✨ Frases generadas (${_selectedPhrases.where((s) => s).length}/${_generatedPhrases.length} seleccionadas)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_generatedPhrases.length, (index) {
                return _buildPhraseCard(index);
              }),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _selectedPhrases.any((s) => s) ? _savePhrases : null,
                icon: const Icon(Icons.save),
                label: Text('Guardar ${_selectedPhrases.where((s) => s).length} frases'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF51CF66),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStyleButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhraseCard(int index) {
    final phrase = _generatedPhrases[index];
    final isSelected = _selectedPhrases[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF667EEA) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() => _selectedPhrases[index] = value ?? false);
              },
              activeColor: const Color(0xFF667EEA),
            ),
            Expanded(
              child: Text(
                phrase,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editPhrase(index),
              tooltip: 'Editar frase',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editPhrase(int index) async {
    final controller = TextEditingController(text: _generatedPhrases[index]);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✏️ Editar Frase'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escribe tu frase...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _generatedPhrases[index] = result.trim();
      });
    }
  }
}
