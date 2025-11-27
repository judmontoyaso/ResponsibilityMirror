import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/custom_phrase.dart';
import '../models/ai_generated_phrase.dart';
import '../utils/quotes.dart';

class PhrasesProvider extends ChangeNotifier {
  List<CustomPhrase> _customPhrases = [];
  List<AIGeneratedPhrase> _aiPhrases = [];
  late Box<CustomPhrase> _phrasesBox;
  late Box<AIGeneratedPhrase> _aiPhrasesBox;

  List<CustomPhrase> get customPhrases => _customPhrases;
  List<AIGeneratedPhrase> get aiPhrases => _aiPhrases;
  
  List<String> get allActivePhrases {
    List<String> all = [];
    
    // Agregar frases de David Goggins
    all.addAll(MotivationalQuotes.gogginsBrutal);
    
    // Agregar frases personalizadas activas
    all.addAll(_customPhrases
        .where((p) => p.isActive)
        .map((p) => p.text)
        .toList());
    
    // Agregar frases generadas por IA activas
    all.addAll(_aiPhrases
        .where((p) => p.isActive)
        .map((p) => p.text)
        .toList());
    
    return all;
  }

  Future<void> init() async {
    _phrasesBox = await Hive.openBox<CustomPhrase>('custom_phrases');
    _aiPhrasesBox = await Hive.openBox<AIGeneratedPhrase>('ai_phrases');
    await loadPhrases();
  }

  // Migrar frases que tienen título a ID
  Future<void> migratePhrasesToUseGoalIds(List<dynamic> goals) async {
    bool needsMigration = false;
    
    for (final phrase in _aiPhrases) {
      if (phrase.relatedGoal != null) {
        // Buscar si relatedGoal es un título (no un ID)
        final matchingGoal = goals.cast<dynamic>().firstWhere(
          (g) => g?.title == phrase.relatedGoal,
          orElse: () => null,
        );
        
        if (matchingGoal != null) {
          // Actualizar a usar ID
          phrase.relatedGoal = matchingGoal.id;
          await phrase.save();
          needsMigration = true;
        }
      }
    }
    
    if (needsMigration) {
      await loadPhrases();
      print('✅ Frases migradas a usar IDs de metas');
    }
  }

  Future<void> loadPhrases() async {
    _customPhrases = _phrasesBox.values.toList();
    _aiPhrases = _aiPhrasesBox.values.toList();
    notifyListeners();
  }

  Future<void> addPhrase(String text) async {
    final phrase = CustomPhrase(
      text: text,
      createdAt: DateTime.now(),
      isActive: true,
    );
    await _phrasesBox.add(phrase);
    await loadPhrases();
  }

  Future<void> addAIPhrase(String text, {String? relatedGoal}) async {
    final phrase = AIGeneratedPhrase(
      text: text,
      createdAt: DateTime.now(),
      isActive: true,
      relatedGoal: relatedGoal,
    );
    await _aiPhrasesBox.add(phrase);
    await loadPhrases();
  }

  Future<void> editAIPhrase(int index, String newText) async {
    if (index >= 0 && index < _aiPhrases.length) {
      final phrase = _aiPhrases[index];
      if (phrase.originalText == null) {
        phrase.originalText = phrase.text; // Guardar original
      }
      phrase.text = newText;
      phrase.isEdited = true;
      await phrase.save();
      notifyListeners();
    }
  }

  Future<void> togglePhrase(int index) async {
    if (index >= 0 && index < _customPhrases.length) {
      _customPhrases[index].isActive = !_customPhrases[index].isActive;
      await _customPhrases[index].save();
      notifyListeners();
    }
  }

  Future<void> toggleAIPhrase(int index) async {
    if (index >= 0 && index < _aiPhrases.length) {
      _aiPhrases[index].isActive = !_aiPhrases[index].isActive;
      await _aiPhrases[index].save();
      notifyListeners();
    }
  }

  Future<void> deletePhrase(int index) async {
    if (index >= 0 && index < _customPhrases.length) {
      await _customPhrases[index].delete();
      await loadPhrases();
    }
  }

  Future<void> deleteAIPhrase(int index) async {
    if (index >= 0 && index < _aiPhrases.length) {
      await _aiPhrases[index].delete();
      await loadPhrases();
    }
  }

  // Estadísticas
  int get totalActivePhrases => allActivePhrases.length;
  int get aiPhrasesCount => _aiPhrases.where((p) => p.isActive).length;
  int get customPhrasesCount => _customPhrases.where((p) => p.isActive).length;
  int get defaultPhrasesCount => MotivationalQuotes.gogginsBrutal.length;
}
