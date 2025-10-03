import '../models/bible_book.dart';

class BibleData {
  static List<BibleBook> get oldTestamentBooks => [

    // Pentateuco (5 libros)
    BibleBook(name: 'Génesis', testament: 'old', chapters: 50, description: 'El libro del principio'),
    BibleBook(name: 'Éxodo', testament: 'old', chapters: 40, description: 'La salida de Egipto'),
    BibleBook(name: 'Levítico', testament: 'old', chapters: 27, description: 'Leyes y rituales'),
    BibleBook(name: 'Números', testament: 'old', chapters: 36, description: 'El censo en el desierto'),
    BibleBook(name: 'Deuteronomio', testament: 'old', chapters: 34, description: 'Segunda Ley'),

    // Libros históricos (12 libros)
    BibleBook(name: 'Josué', testament: 'old', chapters: 24, description: 'La conquista de Canaán'),
    BibleBook(name: 'Jueces', testament: 'old', chapters: 21, description: 'Los jueces de Israel'),
    BibleBook(name: 'Rut', testament: 'old', chapters: 4, description: 'La historia de Rut'),
    BibleBook(name: '1 Samuel', testament: 'old', chapters: 31, description: 'El reino de Saúl'),
    BibleBook(name: '2 Samuel', testament: 'old', chapters: 24, description: 'El reino de David'),
    BibleBook(name: '1 Reyes', testament: 'old', chapters: 22, description: 'El reino de Salomón'),
    BibleBook(name: '2 Reyes', testament: 'old', chapters: 25, description: 'El exilio de Babilonia'),
    BibleBook(name: '1 Crónicas', testament: 'old', chapters: 29, description: 'La genealogía de David'),
    BibleBook(name: '2 Crónicas', testament: 'old', chapters: 36, description: 'La genealogía de David'),
    BibleBook(name: 'Esdras', testament: 'old', chapters: 10, description: 'El regreso de los judíos'),
    BibleBook(name: 'Nehemías', testament: 'old', chapters: 13, description: 'El regreso de los judíos'),
    BibleBook(name: 'Ester', testament: 'old', chapters: 10, description: 'La historia de Ester'),

    // Libros poéticos (5 libros)
    BibleBook(name: 'job', testament: 'old', chapters: 42, description:  'El sifrimiento de Job'),
    BibleBook(name: 'Salmos', testament: 'old', chapters: 150, description: 'Los Salmos de David'),
    BibleBook(name: 'Proverbios', testament: 'old', chapters: 31, description: 'Sabiduría práctica'),
    BibleBook(name: 'Eclesiastés', testament: 'old', chapters: 12, description: 'EEl Predicador'),
    BibleBook(name: 'Cantar de los Cantares', testament: 'old', chapters: 8, description: 'El cantar de los cantares'),

    // Libros proféticos (12 libros) Profetas mayores
    BibleBook(name: 'Isaías', testament: 'old', chapters: 66, description: 'La profecía de Isaías'),
    BibleBook(name: 'Jeremías', testament: 'old', chapters: 52, description: 'La profecía de Jeremías'),
    BibleBook(name: 'Ezequiel', testament: 'old', chapters: 48, description: 'La profecía de Ezequiel'),
    BibleBook(name: 'Daniel', testament: 'old', chapters: 12, description: 'La profecía de Daniel'),

    // Libros proféticos (12 libros) Profetas menores
    BibleBook(name: 'Oseas', testament: 'old', chapters: 14, description: 'La profecía de Oseas'),
    BibleBook(name: 'Joel', testament: 'old', chapters: 3, description: 'La profecía de Joel'),
    BibleBook(name: 'Amós', testament: 'old', chapters: 9, description: 'La profecía de Amós'),
    BibleBook(name: 'Obadías', testament: 'old', chapters: 1, description: 'La profecía de Obadías'),
    BibleBook(name: 'Jonás', testament: 'old', chapters: 4, description: 'La profecía de Jonás'),
    BibleBook(name: 'Miqueas', testament: 'old', chapters: 7, description: 'La profecía de Miqueas'),
    BibleBook(name: 'Nahum', testament: 'old', chapters: 3, description: 'La profecía de Nahum'),
    BibleBook(name: 'Habacuc', testament: 'old', chapters: 3, description: 'La profecía de Habacuc'),
    BibleBook(name: 'Sofonías', testament: 'old', chapters: 3, description: 'La profecía de Sofonías'),
    BibleBook(name: 'Ageo', testament: 'old', chapters: 2, description: 'La profecía de Ageo'),
    BibleBook(name: 'Zacarías', testament: 'old', chapters: 14, description: 'La profecía de Zacarías'),
    BibleBook(name: 'Malaquías', testament: 'old', chapters: 4, description: 'La profecía de Malaquías'),

                   
  ];

static List<BibleBook> get newTestamentBooks =>   [
  // Evangelios (4 libros)
  BibleBook(name: 'Mateo', testament: 'new', chapters: 28, description: 'El evangelio de Mateo'),
  BibleBook(name: 'Marcos', testament: 'new', chapters: 16, description: 'El evangelio de Marcos'),
  BibleBook(name: 'Lucas', testament: 'new', chapters: 24, description: 'El evangelio de Lucas'),
  BibleBook(name: 'Juan', testament: 'new', chapters: 21, description: 'El evangelio de Juan'),
  
  // Libro histórico (1 libro)
  BibleBook(name: 'Hechos', testament: 'new', chapters: 28, description: 'Los Hechos de los Apostoles'),

  //Epístolas paulinas 'Pablo' (13 libros)
  BibleBook(name: 'Romanos', testament: 'new', chapters: 16, description: 'Carta a los romanos'),
  BibleBook(name: '1 Corintios', testament: 'new', chapters: 16, description: 'Primera carta a los corintios'),
  BibleBook(name: '2 Corintios', testament: 'new', chapters: 13, description: 'Segunda carta a los corintios'),
  BibleBook(name: 'Gálatas', testament: 'new', chapters: 6, description: 'Carta a los gálatas'),
  BibleBook(name: 'Efesios', testament: 'new', chapters: 6, description: 'Carta a los efesios'),
  BibleBook(name: 'Filipenses', testament: 'new', chapters: 4, description: 'Carta a los filipenses'),
  BibleBook(name: 'Colosenses', testament: 'new', chapters: 4, description: 'Carta a los colosenses'),
  BibleBook(name: '1 Tesalonicenses', testament: 'new', chapters: 5, description: 'Primeracarta a los tesalonicenses'),
  BibleBook(name: '2 Tesalonicenses', testament: 'new', chapters: 3, description: 'Segunda carta a los tesalonicenses'),
  BibleBook(name: '1 Timoteo', testament: 'new', chapters: 6, description: 'Primera carta a Timoteo'),
  BibleBook(name: '2 Timoteo', testament: 'new', chapters: 4, description: 'Segunda carta a Timoteo'),
  BibleBook(name: 'Tito', testament: 'new', chapters: 3, description: 'Carta a Tito'),
  BibleBook(name: 'Filemón', testament: 'new', chapters: 1, description: 'Carta a Filemón'),


  //Epístolas generales (8 libro)
  BibleBook(name: 'Hebreos', testament: 'new', chapters: 13, description: 'Carta a los hebreos'),
  BibleBook(name: 'Santiago', testament: 'new', chapters: 5, description: 'Carta de Santiago'),
  BibleBook(name: '1 Pedro', testament: 'new', chapters: 5, description: 'Primera carta de Pedro'),
  BibleBook(name: '2 Pedro', testament: 'new', chapters: 3, description: 'Segunda carta de Pedro'),
  BibleBook(name: '1 Juan', testament: 'new', chapters: 5, description: 'Primera carta de Juan'),
  BibleBook(name: '2 Juan', testament: 'new', chapters: 1, description: 'Segunda carta de Juan'),
  BibleBook(name: '3 Juan', testament: 'new', chapters: 1, description: 'Tercera carta de Juan'),
  BibleBook(name: 'Judas', testament: 'new', chapters: 1, description: 'Carta de Judas'),

  //Libros de Apocalipsis (1 libro)
  BibleBook(name: 'Apocalípsis', testament: 'new', chapters: 22, description: 'El Apocalipsís de Juan')


];
}

                