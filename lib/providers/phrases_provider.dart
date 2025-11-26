import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/custom_phrase.dart';
import '../utils/quotes.dart';

class PhrasesProvider extends ChangeNotifier {
  List<CustomPhrase> _customPhrases = [];
  late Box<CustomPhrase> _phrasesBox;

  List<CustomPhrase> get customPhrases => _customPhrases;
  
  List<String> get allActivePhrases {
    List<String> all = [];
    
    // Agregar frases de David Goggins
    all.addAll(MotivationalQuotes.gogginsBrutal);
    
    // Agregar frases personalizadas activas
    all.addAll(_customPhrases
        .where((p) => p.isActive)
        .map((p) => p.text)
        .toList());
    
    return all;
  }

  Future<void> init() async {
    _phrasesBox = await Hive.openBox<CustomPhrase>('custom_phrases');
    await loadPhrases();
  }

  Future<void> loadPhrases() async {
    _customPhrases = _phrasesBox.values.toList();
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

  Future<void> togglePhrase(int index) async {
    if (index >= 0 && index < _customPhrases.length) {
      _customPhrases[index].isActive = !_customPhrases[index].isActive;
      await _customPhrases[index].save();
      notifyListeners();
    }
  }

  Future<void> deletePhrase(int index) async {
    if (index >= 0 && index < _customPhrases.length) {
      await _customPhrases[index].delete();
      await loadPhrases();
    }
  }
}
