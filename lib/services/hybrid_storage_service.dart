import 'dart:io';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';
import '../models/bible_book.dart';

// Importar Firebase solo para web
import 'firebase_service.dart'
    if (dart.library.io) 'firebase_service_stub.dart';

class HybridStorageService {
  static final FirebaseService _firebaseService = FirebaseService();
  static bool _isWeb = kIsWeb;
  static bool _isWindows = !kIsWeb && Platform.isWindows;

  // Inicializar el servicio
  static Future<void> initialize() async {
    if (_isWeb) {
      await FirebaseService.initialize();
    }
    // Para Windows, no necesitamos inicialización especial
  }

  // Verificar si está autenticado
  bool get isAuthenticated {
    if (_isWeb) {
      return _firebaseService.isAuthenticated;
    }
    // Para Windows, siempre consideramos "autenticado" con almacenamiento local
    return true;
  }

  // Stream de cambios de autenticación
  Stream get authStateChanges {
    if (_isWeb) {
      return _firebaseService.authStateChanges;
    }
    // Para Windows, devolver un stream que siempre emite true
    return Stream.value(true);
  }

  // Guardar estadísticas del usuario
  Future<void> saveUserStats({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastCompletedDate,
  }) async {
    if (_isWeb) {
      await _firebaseService.saveUserStats(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastCompletedDate: lastCompletedDate,
      );
    } else {
      await LocalStorageService.saveUserStats(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastCompletedDate: lastCompletedDate,
      );
    }
  }

  // Cargar estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats() async {
    if (_isWeb) {
      return await _firebaseService.getUserStats();
    } else {
      return await LocalStorageService.getUserStats();
    }
  }

  // Guardar progreso de lectura
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    if (_isWeb) {
      await _firebaseService.saveReadingProgress(progress);
    } else {
      await LocalStorageService.saveReadingProgress(progress);
    }
  }

  // Cargar progreso de lectura
  Future<List<ReadingProgress>> getReadingProgress() async {
    if (_isWeb) {
      return await _firebaseService.getReadingProgress();
    } else {
      return await LocalStorageService.getReadingProgress();
    }
  }

  // Eliminar progreso de lectura
  Future<void> deleteReadingProgress(ReadingProgress progress) async {
    if (_isWeb) {
      await _firebaseService.deleteReadingProgress(progress);
    } else {
      await LocalStorageService.deleteReadingProgress(progress);
    }
  }

  // Sincronizar todos los datos
  Future<void> syncAllData({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastCompletedDate,
    required List<ReadingProgress> readingProgress,
  }) async {
    if (_isWeb) {
      await _firebaseService.syncAllData(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastCompletedDate: lastCompletedDate,
        readingProgress: readingProgress,
      );
    } else {
      await LocalStorageService.syncAllData(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastCompletedDate: lastCompletedDate,
        readingProgress: readingProgress,
      );
    }
  }

  // Cerrar sesión (solo para web)
  Future<void> signOut() async {
    if (_isWeb) {
      await _firebaseService.signOut();
    }
    // Para Windows, no hay sesión que cerrar
  }

  // Limpiar todos los datos
  Future<void> clearAllData() async {
    if (_isWeb) {
      // Para web, usar Firebase
      await _firebaseService.syncAllData(
        currentStreak: 0,
        longestStreak: 0,
        lastCompletedDate: null,
        readingProgress: [],
      );
    } else {
      // Para Windows, usar almacenamiento local
      await LocalStorageService.clearAllData();
    }
  }
}
