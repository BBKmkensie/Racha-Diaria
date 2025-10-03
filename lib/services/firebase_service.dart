import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/bible_book.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '167495836511-5flfhreboaeeoe0f4icn4958h4t5f2cc.apps.googleusercontent.com',
  );

  // Inicializar Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Verificar si hay usuario autenticado
  bool get isAuthenticated => _auth.currentUser != null;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Iniciar sesión anónima
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Error al iniciar sesión anónima: $e');
      return null;
    }
  }

  // Iniciar sesión con correo y contraseña
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print('Error al iniciar sesión con correo: $e');
      return null;
    }
  }

  // Crear cuenta con correo y contraseña
  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print('Error al crear cuenta: $e');
      return null;
    }
  }

  // Enviar correo de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error al enviar correo de restablecimiento: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Iniciar sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Iniciando proceso de Google Sign-In...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('Google Sign-In result: ${googleUser?.email}');

      if (googleUser == null) {
        // User cancelled the login
        print('Usuario canceló el login con Google');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          'Google Auth tokens obtenidos: accessToken=${googleAuth.accessToken != null}, idToken=${googleAuth.idToken != null}');

      // Verificar que tenemos los tokens necesarios
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print(
            'Error: Tokens de Google no disponibles - accessToken: ${googleAuth.accessToken}, idToken: ${googleAuth.idToken}');
        return null;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Credencial de Firebase creada exitosamente');

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      print('Login con Google exitoso: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      print('Error detallado al iniciar sesión con Google: $e');
      print('Tipo de error: ${e.runtimeType}');

      // Proporcionar mensajes de error más específicos
      if (e.toString().contains('popup_closed_by_user')) {
        print('Usuario cerró la ventana de Google');
      } else if (e.toString().contains('network_error')) {
        print('Error de red al conectar con Google');
      } else if (e.toString().contains('access_denied')) {
        print('Acceso denegado por Google');
      } else if (e.toString().contains('invalid_client')) {
        print('Cliente OAuth inválido - verificar configuración');
      } else if (e.toString().contains('redirect_uri_mismatch')) {
        print('URI de redirección no coincide - verificar configuración');
      } else if (e.toString().contains('unauthorized_client')) {
        print('Cliente no autorizado - verificar configuración OAuth');
      }
      return null;
    }
  }

  // Obtener progreso de lectura del usuario
  Future<List<ReadingProgress>> getReadingProgress() async {
    if (!isAuthenticated) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('readingProgress')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReadingProgress.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error al obtener progreso de lectura: $e');
      return [];
    }
  }

  // Guardar progreso de lectura
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    if (!isAuthenticated) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('readingProgress')
          .doc(
              '${progress.bookName}_${progress.chapter}_${progress.date.millisecondsSinceEpoch}')
          .set(progress.toFirestore());
    } catch (e) {
      print('Error al guardar progreso de lectura: $e');
    }
  }

  // Eliminar progreso de lectura
  Future<void> deleteReadingProgress(ReadingProgress progress) async {
    if (!isAuthenticated) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('readingProgress')
          .doc(
              '${progress.bookName}_${progress.chapter}_${progress.date.millisecondsSinceEpoch}')
          .delete();
    } catch (e) {
      print('Error al eliminar progreso de lectura: $e');
    }
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats() async {
    if (!isAuthenticated) return {};

    try {
      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {};
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {};
    }
  }

  // Guardar estadísticas del usuario
  Future<void> saveUserStats({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastCompletedDate,
  }) async {
    if (!isAuthenticated) return;

    try {
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error al guardar estadísticas: $e');
    }
  }

  // Sincronizar todos los datos
  Future<void> syncAllData({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastCompletedDate,
    required List<ReadingProgress> readingProgress,
  }) async {
    if (!isAuthenticated) return;

    try {
      // Guardar estadísticas
      await saveUserStats(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastCompletedDate: lastCompletedDate,
      );

      // Guardar progreso de lectura
      for (final progress in readingProgress) {
        await saveReadingProgress(progress);
      }
    } catch (e) {
      print('Error al sincronizar datos: $e');
    }
  }
}
