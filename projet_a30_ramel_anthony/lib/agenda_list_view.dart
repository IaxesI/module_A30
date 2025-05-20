import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'login_screen.dart';
import 'auth_service.dart';

class AgendaListView extends StatefulWidget {
  final String username;
  final AuthService authService;

  const AgendaListView({
    Key? key,
    required this.username,
    required this.authService,
  }) : super(key: key);

  @override
  _AgendaListViewState createState() => _AgendaListViewState();
}

class _AgendaListViewState extends State<AgendaListView> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 10, minute: 0);

  late String _username;

  final List<AgendaItem> _agendaItems = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _username = widget.username;
    _generateDemoData();
  }

  void _generateDemoData() {
    final now = DateTime.now();
    for (int i = 0; i < 14; i++) {
      final date = now.add(Duration(days: i));
      final eventCount = i % 3 + 1;
      for (int j = 0; j < eventCount; j++) {
        final startHour = 8 + (j * 2);
        _agendaItems.add(
          AgendaItem(
            title: 'Événement ${j + 1}',
            description: 'Description de l\'événement ${j + 1}',
            date: date,
            startTime: TimeOfDay(hour: startHour, minute: 0),
            endTime: TimeOfDay(hour: startHour + 1, minute: 30),
            color: _getRandomColor(j),
          ),
        );
      }
    }

    _agendaItems.sort((a, b) => a.date.compareTo(b.date));
  }

  Color _getRandomColor(int seed) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.amber,
      Colors.teal,
    ];
    return colors[seed % colors.length];
  }

  void _logout() {
    widget.authService.logout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => LoginScreen(
              authService: widget.authService,
              onLogin: (username) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AgendaListView(
                          username: username,
                          authService: widget.authService,
                        ),
                  ),
                );
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mon Agenda'),
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.indigo.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    'Agenda personnel de $_username',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildAgendaList()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddEventDialog();
          },
          backgroundColor: Colors.indigo,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddEventDialog() {
    final _titleController = TextEditingController();
    final _descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Nouvel événement'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Titre'),
                    ),
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: const Text('Date'),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                      ),
                      onTap: () async {
                        final picked = await showDialog<DateTime>(
                          context: context,
                          builder:
                              (context) => DatePickerDialog(
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              ),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Heure de début'),
                      subtitle: Text(_selectedStartTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedStartTime,
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            _selectedStartTime = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Heure de fin'),
                      subtitle: Text(_selectedEndTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedEndTime,
                        );
                        if (picked != null &&
                            picked.hour > _selectedStartTime.hour) {
                          setStateDialog(() {
                            _selectedEndTime = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Ajouter'),
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      setState(() {
                        _agendaItems.add(
                          AgendaItem(
                            title: _titleController.text,
                            description: _descController.text,
                            date: _selectedDate,
                            startTime: _selectedStartTime,
                            endTime: _selectedEndTime,
                            color: _getRandomColor(_agendaItems.length),
                          ),
                        );
                        _agendaItems.sort((a, b) => a.date.compareTo(b.date));
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAgendaList() {
    Map<DateTime, List<AgendaItem>> groupedEvents = {};
    for (var item in _agendaItems) {
      final date = DateTime(item.date.year, item.date.month, item.date.day);
      if (!groupedEvents.containsKey(date)) {
        groupedEvents[date] = [];
      }
      groupedEvents[date]!.add(item);
    }

    final sortedDates =
        groupedEvents.keys.toList()..sort((a, b) => a.compareTo(b));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events = groupedEvents[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date),
            ...events.map((event) => _buildEventCard(event)),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    String headerText;
    if (date.isAtSameMomentAs(today)) {
      headerText = "Aujourd'hui";
    } else if (date.isAtSameMomentAs(tomorrow)) {
      headerText = "Demain";
    } else {
      try {
        headerText = DateFormat('EEEE d MMMM', 'fr_FR').format(date);
        headerText = headerText[0].toUpperCase() + headerText.substring(1);
      } catch (_) {
        final weekdays = [
          'Lundi',
          'Mardi',
          'Mercredi',
          'Jeudi',
          'Vendredi',
          'Samedi',
          'Dimanche',
        ];
        final months = [
          'janvier',
          'février',
          'mars',
          'avril',
          'mai',
          'juin',
          'juillet',
          'août',
          'septembre',
          'octobre',
          'novembre',
          'décembre',
        ];

        headerText =
            '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              headerText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(AgendaItem event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 4,
          height: 50,
          decoration: BoxDecoration(
            color: event.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(event.description),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_formatTimeOfDay(event.startTime)} - ${_formatTimeOfDay(event.endTime)}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Supprimer l\'événement ?'),
                  content: Text(
                    'Voulez-vous vraiment supprimer "${event.title}" ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Supprimer'),
                    ),
                  ],
                );
              },
            );

            if (shouldDelete == true) {
              setState(() {
                _agendaItems.remove(event);
              });
            }
          },
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class AgendaItem {
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;

  AgendaItem({
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}
