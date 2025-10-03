import 'package:cloud_firestore/cloud_firestore.dart';

class BibleBook {
  final String name;
  final String testament;
  final int chapters;
  final String description;

  BibleBook({
    required this.name,
    required this.testament,
    required this.chapters,
    required this.description,
  });
}

class ReadingProgress {
  final String bookName;
  final int chapter;
  final DateTime date;
  final bool isCompleted;

  ReadingProgress({
    required this.bookName,
    required this.chapter,
    required this.date,
    required this.isCompleted,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'bookName': bookName,
      'chapter': chapter,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Crear desde documento de Firestore
  factory ReadingProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReadingProgress(
      bookName: data['bookName'] ?? '',
      chapter: data['chapter'] ?? 0,
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  // Crear desde Map
  factory ReadingProgress.fromMap(Map<String, dynamic> data) {
    return ReadingProgress(
      bookName: data['bookName'] ?? '',
      chapter: data['chapter'] ?? 0,
      date: data['date'] is DateTime
          ? data['date']
          : DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'bookName': bookName,
      'chapter': chapter,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Crear copia con cambios
  ReadingProgress copyWith({
    String? bookName,
    int? chapter,
    DateTime? date,
    bool? isCompleted,
  }) {
    return ReadingProgress(
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingProgress &&
        other.bookName == bookName &&
        other.chapter == chapter &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return bookName.hashCode ^
        chapter.hashCode ^
        date.hashCode ^
        isCompleted.hashCode;
  }
}
