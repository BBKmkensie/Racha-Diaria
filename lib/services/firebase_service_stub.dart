import '../models/bible_book.dart';

// Stub para Firebase en Windows - no hace nada
class FirebaseService {
  static Future<void> initialize() async {
    // No hacer nada en Windows
  }

  bool get isAuthenticated => true;

  Stream get authStateChanges => Stream.value(true);

  Future<void> saveUserStats({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastCompletedDate,
  }) async {
    // No hacer nada en Windows
  }

  Future<Map<String, dynamic>> getUserStats() async {
    return {};
  }

  Future<void> saveReadingProgress(ReadingProgress progress) async {
    // No hacer nada en Windows
  }

  Future<List<ReadingProgress>> getReadingProgress() async {
    return [];
  }

  Future<void> deleteReadingProgress(ReadingProgress progress) async {
    // No hacer nada en Windows
  }

  Future<void> syncAllData({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastCompletedDate,
    required List<ReadingProgress> readingProgress,
  }) async {
    // No hacer nada en Windows
  }

  Future<void> signOut() async {
    // No hacer nada en Windows
  }
}
