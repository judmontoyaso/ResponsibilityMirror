import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/personal_note.dart';

class NotesProvider extends ChangeNotifier {
  List<PersonalNote> _notes = [];
  late Box<PersonalNote> _notesBox;

  List<PersonalNote> get notes => _notes;

  Future<void> init() async {
    _notesBox = await Hive.openBox<PersonalNote>('personal_notes');
    await loadNotes();
  }

  Future<void> loadNotes() async {
    _notes = _notesBox.values.toList();
    // Ordenar por fecha de creación, más reciente primero
    _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> addNote(String content, {int colorIndex = 0}) async {
    final note = PersonalNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: DateTime.now(),
      colorIndex: colorIndex,
    );
    await _notesBox.add(note);
    await loadNotes();
  }

  Future<void> updateNote(PersonalNote note) async {
    await note.save();
    await loadNotes();
  }

  Future<void> deleteNote(PersonalNote note) async {
    await note.delete();
    await loadNotes();
  }
}
