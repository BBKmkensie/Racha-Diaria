import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bible_book.dart';

class LocalStorageService {
  static const String _currentStreakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';
  static const String _lastCompletedDateKey = 'last_completed_date';
  static const String _readingProgressKey = 'reading_progress';

  // Guardar estadísticas del usuario
  static Future<void> saveUserStats({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastCompletedDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_currentStreakKey, currentStreak);
    await prefs.setInt(_longestStreakKey, longestStreak);

    if (lastCompletedDate != null) {
      await prefs.setString(
          _lastCompletedDateKey, lastCompletedDate.toIso8601String());
    } else {
      await prefs.remove(_lastCompletedDateKey);
    }
  }

  // Cargar estadísticas del usuario
  static Future<Map<String, dynamic>> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'currentStreak': prefs.getInt(_currentStreakKey) ?? 0,
      'longestStreak': prefs.getInt(_longestStreakKey) ?? 0,
      'lastCompletedDate': prefs.getString(_lastCompletedDateKey),
    };
  }

  // Guardar progreso de lectura
  static Future<void> saveReadingProgress(ReadingProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> progressList =
        prefs.getStringList(_readingProgressKey) ?? [];

    // Convertir ReadingProgress a JSON
    final progressJson = {
      'bookName': progress.bookName,
      'chapter': progress.chapter,
      'date': progress.date.toIso8601String(),
      'isCompleted': progress.isCompleted,
    };

    // Verificar si ya existe este progreso
    final existingIndex = progressList.indexWhere((item) {
      final existing = jsonDecode(item);
      return existing['bookName'] == progress.bookName &&
          existing['chapter'] == progress.chapter &&
          existing['date'] == progress.date.toIso8601String();
    });

    if (existingIndex >= 0) {
      // Actualizar existente
      progressList[existingIndex] = jsonEncode(progressJson);
    } else {
      // Agregar nuevo
      progressList.add(jsonEncode(progressJson));
    }

    await prefs.setStringList(_readingProgressKey, progressList);
  }

  // Cargar progreso de lectura
  static Future<List<ReadingProgress>> getReadingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> progressList =
        prefs.getStringList(_readingProgressKey) ?? [];

    return progressList.map((item) {
      final json = jsonDecode(item);
      return ReadingProgress(
        bookName: json['bookName'],
        chapter: json['chapter'],
        date: DateTime.parse(json['date']),
        isCompleted: json['isCompleted'],
      );
    }).toList();
  }

  // Eliminar progreso de lectura
  static Future<void> deleteReadingProgress(ReadingProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> progressList =
        prefs.getStringList(_readingProgressKey) ?? [];

    progressList.removeWhere((item) {
      final existing = jsonDecode(item);
      return existing['bookName'] == progress.bookName &&
          existing['chapter'] == progress.chapter &&
          existing['date'] == progress.date.toIso8601String();
    });

    await prefs.setStringList(_readingProgressKey, progressList);
  }

  // Sincronizar todos los datos
  static Future<void> syncAllData({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastCompletedDate,
    required List<ReadingProgress> readingProgress,
  }) async {
    await saveUserStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastCompletedDate: lastCompletedDate,
    );

    // Limpiar progreso existente y guardar el nuevo
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_readingProgressKey);

    for (final progress in readingProgress) {
      await saveReadingProgress(progress);
    }
  }

  // Limpiar todos los datos
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentStreakKey);
    await prefs.remove(_longestStreakKey);
    await prefs.remove(_lastCompletedDateKey);
    await prefs.remove(_readingProgressKey);
  }
}
