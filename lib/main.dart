import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'data/bible_data.dart';
import 'models/bible_book.dart';
import 'services/hybrid_storage_service.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HybridStorageService.initialize();
  runApp(const RachaDiariaApp());
}

class RachaDiariaApp extends StatelessWidget {
  const RachaDiariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Racha Diaria',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:
              const Color(0xFF2E7D32), // Verde para representar crecimiento
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: HybridStorageService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Usuario autenticado, mostrar la aplicación principal
          return const HomePage();
        } else {
          // Usuario no autenticado, mostrar pantalla de login
          return const AuthScreen();
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastCompletedDate;
  final List<ReadingProgress> _readingProgress = [];
  final HybridStorageService _storageService = HybridStorageService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Verificar si ya hay un usuario autenticado
      if (_storageService.isAuthenticated) {
        setState(() {
          _isAuthenticated = true;
        });
        await _loadUserData();
      }
    } catch (e) {
      print('Error al inicializar almacenamiento: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Cargar estadísticas del usuario
      final stats = await _storageService.getUserStats();
      if (stats.isNotEmpty) {
        setState(() {
          _currentStreak = stats['currentStreak'] ?? 0;
          _longestStreak = stats['longestStreak'] ?? 0;
          if (stats['lastCompletedDate'] != null) {
            _lastCompletedDate = DateTime.parse(stats['lastCompletedDate']);
          }
        });
      }

      // Cargar progreso de lectura
      final progress = await _storageService.getReadingProgress();
      setState(() {
        _readingProgress.clear();
        _readingProgress.addAll(progress);
      });
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    }
  }

  Future<void> _saveToStorage() async {
    if (!_isAuthenticated) return;

    try {
      await _storageService.syncAllData(
        currentStreak: _currentStreak,
        longestStreak: _longestStreak,
        lastCompletedDate: _lastCompletedDate,
        readingProgress: _readingProgress,
      );
    } catch (e) {
      print('Error al guardar datos: $e');
    }
  }

  void _resetStreak() async {
    setState(() {
      _currentStreak = 0;
      _longestStreak = 0;
      _lastCompletedDate = null;
      _readingProgress.clear();
    });

    // Sincronizar con almacenamiento
    if (_isAuthenticated) {
      await _storageService.syncAllData(
        currentStreak: _currentStreak,
        longestStreak: _longestStreak,
        lastCompletedDate: _lastCompletedDate,
        readingProgress: _readingProgress,
      );
    }
  }

  void _completeReading(String bookName, int chapter,
      [DateTime? savedDate]) async {
    setState(() {
      final dateToUse = savedDate ?? DateTime.now();
      final targetDate =
          DateTime(dateToUse.year, dateToUse.month, dateToUse.day);

      print(
          'DEBUG: Marcando capítulo $chapter de $bookName para fecha $targetDate');
      print('DEBUG: Total progresos antes: ${_readingProgress.length}');

      // Verificar si ya se completó la lectura de ese día
      final dayReading = _readingProgress
          .where((progress) =>
              progress.bookName == bookName &&
              progress.chapter == chapter &&
              progress.date.year == targetDate.year &&
              progress.date.month == targetDate.month &&
              progress.date.day == targetDate.day)
          .firstOrNull;

      if (dayReading == null) {
        // Agregar como completado
        final newProgress = ReadingProgress(
            bookName: bookName,
            chapter: chapter,
            date: targetDate,
            isCompleted: true);
        _readingProgress.add(newProgress);

        print(
            'DEBUG: Capítulo agregado. Total progresos después: ${_readingProgress.length}');

        // Actualizar racha
        if (_lastCompletedDate == null ||
            _lastCompletedDate!.isBefore(targetDate)) {
          _currentStreak++;
          if (_currentStreak > _longestStreak) {
            _longestStreak = _currentStreak;
          }
          _lastCompletedDate = targetDate;
        }

        // Guardar en almacenamiento
        if (_isAuthenticated) {
          print('DEBUG: Guardando en almacenamiento...');
          _storageService.saveReadingProgress(newProgress);
          _storageService.saveUserStats(
            currentStreak: _currentStreak,
            longestStreak: _longestStreak,
            lastCompletedDate: _lastCompletedDate,
          );
        } else {
          print('DEBUG: No autenticado, guardando solo localmente');
        }
      } else {
        // si ya existe, removerlo (desmarcar)
        _readingProgress.remove(dayReading);
        print(
            'DEBUG: Capítulo removido. Total progresos después: ${_readingProgress.length}');

        // Eliminar de almacenamiento
        if (_isAuthenticated) {
          _storageService.deleteReadingProgress(dayReading);
        }

        // Recalcular racha
        _recalculateStreak();

        // Guardar estadísticas actualizadas en almacenamiento
        if (_isAuthenticated) {
          _storageService.saveUserStats(
            currentStreak: _currentStreak,
            longestStreak: _longestStreak,
            lastCompletedDate: _lastCompletedDate,
          );
        }
      }
    });
  }

  void _recalculateStreak() {
    if (_readingProgress.isEmpty) {
      _currentStreak = 0;
      _longestStreak = 0;
      _lastCompletedDate = null;
      return;
    }

    // Obtener días únicos donde se leyó (sin duplicados por fecha)
    final uniqueDates = _readingProgress
        .map((progress) => DateTime(
            progress.date.year, progress.date.month, progress.date.day))
        .toSet()
        .toList();

    uniqueDates.sort();

    if (uniqueDates.isEmpty) {
      _currentStreak = 0;
      _longestStreak = 0;
      _lastCompletedDate = null;
      return;
    }

    _currentStreak = 1;
    _longestStreak = 1;
    _lastCompletedDate = uniqueDates.first;

    // Calcular racha consecutiva basada en días únicos
    for (int i = 1; i < uniqueDates.length; i++) {
      final currentDate = uniqueDates[i];
      final previousDate = uniqueDates[i - 1];

      // Si la fecha actual es exactamente 1 día después de la anterior
      if (currentDate.difference(previousDate).inDays == 1) {
        _currentStreak++;
        if (_currentStreak > _longestStreak) {
          _longestStreak = _currentStreak;
        }
      } else {
        // Si hay un gap, reiniciar la racha actual
        _currentStreak = 1;
      }
    }
  }

  // Obtener fechas con capítulos marcados
  Set<DateTime> _getDatesWithReadings() {
    Set<DateTime> datesWithReadings = {};
    for (final progress in _readingProgress) {
      // Normalizar la fecha (solo año, mes, día)
      final normalizedDate = DateTime(
        progress.date.year,
        progress.date.month,
        progress.date.day,
      );
      datesWithReadings.add(normalizedDate);
    }
    return datesWithReadings;
  }

  void _showDatePicker(BibleBook book) async {
    final Set<DateTime> datesWithReadings = _getDatesWithReadings();
    DateTime? selectedDate;

    // Debug: imprimir las fechas con lecturas
    print('DEBUG: Fechas con lecturas: $datesWithReadings');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Text('Seleccionar Fecha'),
              const Spacer(),
              if (datesWithReadings.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${datesWithReadings.length} días con lecturas',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          content: SizedBox(
            width: 350,
            child: TableCalendar<dynamic>(
              firstDay: DateTime(2020),
              lastDay: DateTime.now(),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mes',
                CalendarFormat.twoWeeks: '2 Semanas',
                CalendarFormat.week: 'Semana',
              },
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              eventLoader: (day) {
                // Normalizar la fecha para comparar solo año, mes y día
                final normalizedDay = DateTime(day.year, day.month, day.day);
                final hasReading = datesWithReadings.any((date) =>
                    date.year == normalizedDay.year &&
                    date.month == normalizedDay.month &&
                    date.day == normalizedDay.day);
                return hasReading ? ['reading'] : [];
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: Colors.green[600],
                  shape: BoxShape.circle,
                ),
                markerSize: 8,
                markerMargin:
                    const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue[300],
                  shape: BoxShape.circle,
                ),
                defaultDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                weekendDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                holidayDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                outsideDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                // Estilo especial para días con lecturas
                markersAlignment: Alignment.bottomCenter,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Colors.white,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(selectedDate, selectedDay)) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedDate != null
                  ? () {
                      Navigator.pop(context);
                      _showBookDetailsWithDate(book, selectedDate!);
                    }
                  : null,
              child: const Text('Seleccionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookDetailsWithDate(BibleBook book, DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                book.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fecha seleccionada: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              // Leyenda de colores
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 10),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Marcado en esta fecha',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.orange[400],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange[600]!, width: 1),
                    ),
                    child: const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 10),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Marcado en otra fecha',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Capítulos (${book.chapters})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: book.chapters,
                  itemBuilder: (context, index) {
                    final chapterNumber = index + 1;

                    // Verificar si el capítulo está completado para la fecha seleccionada
                    // Verificar si el capítulo está completado en CUALQUIER fecha
                    final isCompleted = _readingProgress.any((progress) =>
                        progress.bookName == book.name &&
                        progress.chapter == chapterNumber &&
                        progress.isCompleted);

                    // Verificar si está completado específicamente en la fecha seleccionada
                    final isCompletedForSelectedDate = _readingProgress.any(
                        (progress) =>
                            progress.bookName == book.name &&
                            progress.chapter == chapterNumber &&
                            progress.date.year == selectedDate.year &&
                            progress.date.month == selectedDate.month &&
                            progress.date.day == selectedDate.day &&
                            progress.isCompleted);

                    if (chapterNumber <= 5) {
                      // Solo debug para los primeros 5 capítulos
                      print(
                          'DEBUG: Capítulo $chapterNumber - Completado: $isCompleted');
                    }

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _completeReading(
                            book.name, chapterNumber, selectedDate),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? (isCompletedForSelectedDate
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary // Verde para fecha seleccionada
                                    : Colors.orange[
                                        400]) // Naranja para otras fechas
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                            border: isCompleted && !isCompletedForSelectedDate
                                ? Border.all(
                                    color: Colors.orange[600]!, width: 1)
                                : null,
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(
                                    isCompletedForSelectedDate
                                        ? Icons.check
                                        : Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 16)
                                : Text(
                                    '$chapterNumber',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Racha Diaria',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isAuthenticated ? Icons.storage : Icons.storage),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isAuthenticated
                      ? 'Datos guardados correctamente'
                      : 'Modo offline - los datos se guardarán localmente'),
                  backgroundColor:
                      _isAuthenticated ? Colors.green : Colors.orange,
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await _storageService.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Tarjeta de Racha
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(children: [
                  const Text(
                    'Tu Racha Actual',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_currentStreak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('Racha Más Larga', '$_longestStreak'),
                      _buildStatItem('Lecturas hoy',
                          '${_readingProgress.where((p) => p.date.day == DateTime.now().day).length}'),
                    ],
                  )
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // Antiguo Testamento
            _buildTestamentSection(
                'Antiguo Testamento', BibleData.oldTestamentBooks),

            const SizedBox(height: 24),

            // Nuevo Testamento
            _buildTestamentSection(
                'Nuevo Testamento', BibleData.newTestamentBooks),

            const SizedBox(height: 24),

            // Botón de reset
            Center(
              child: ElevatedButton.icon(
                onPressed: _resetStreak,
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar Racha'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestamentSection(String title, List<BibleBook> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Todos los libros del $title',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 12,
            childAspectRatio: 1.0,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return _buildBookCard(book);
          },
        ),
      ],
    );
  }

  Widget _buildBookCard(BibleBook book) {
    // Calcular progreso para este libro
    final bookProgress = _readingProgress
        .where((progress) =>
            progress.bookName == book.name && progress.isCompleted)
        .length;
    final progressPercentage = bookProgress / book.chapters;
    final isCompleted = progressPercentage == 1.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () => _showBookDetails(book),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: isCompleted
                  ? LinearGradient(
                      colors: [
                        Colors.green[400]!,
                        Colors.green[600]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                      color: isCompleted ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${book.chapters}',
                    style: TextStyle(
                      fontSize: 8,
                      color: isCompleted ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  if (bookProgress > 0) ...[
                    const SizedBox(height: 2),
                    Container(
                      height: 3,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.white30 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressPercentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '${(progressPercentage * 100).round()}%',
                      style: TextStyle(
                        fontSize: 6,
                        color: isCompleted ? Colors.white70 : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBookDetails(BibleBook book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                book.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // Barra de progreso del libro
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso Completado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${_getBookProgress(book).round()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _getBookProgress(book) / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getBookProgress(book) > 0
                            ? Colors.green[400]!
                            : Colors.grey[400]!,
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_getCompletedChapters(book)} de ${book.chapters} capítulos completados',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                'Capítulos (${book.chapters})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showDatePicker(book),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Seleccionar Fecha'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: book.chapters,
                  itemBuilder: (context, index) {
                    final chapterNumber = index + 1;
                    final isCompleted = _readingProgress.any((progress) =>
                        progress.bookName == book.name &&
                        progress.chapter == chapterNumber &&
                        progress.isCompleted);

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _completeReading(book.name, chapterNumber),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  )
                                : Text(
                                    '$chapterNumber',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Métodos auxiliares para calcular progreso
  double _getBookProgress(BibleBook book) {
    final completedChapters = _readingProgress
        .where((progress) =>
            progress.bookName == book.name && progress.isCompleted)
        .length;
    // Retornar el porcentaje de lo que falta para completar (100% - completado)
    return (completedChapters / book.chapters) * 100;
  }

  List<int> _getCompletedChapters(BibleBook book) {
    return _readingProgress
        .where((progress) =>
            progress.bookName == book.name && progress.isCompleted)
        .map((p) => p.chapter)
        .toList()
      ..sort();
  }
}
