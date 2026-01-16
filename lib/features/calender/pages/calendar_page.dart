import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:studysphere_app/features/auth/providers/user_provider.dart';
import 'package:studysphere_app/features/calender/providers/calendar_provider.dart';
import 'package:studysphere_app/features/home/data/models/summary_model.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Local state for sessions detail (lazy loaded)
  List<Map<String, dynamic>> _selectedDaySessions = [];
  bool _isLoadingSessions = false;

  final List<String> _motivationalQuotes = [
    'Mulai belajar hari ini! Setiap langkah kecil membawa perubahan besar.',
    'Jangan tunda sampai besok, apa yang bisa kamu pelajari hari ini!',
    'Konsistensi adalah kunci kesuksesan. Ayo mulai sekarang!',
    'Investasi terbaik adalah investasi pada diri sendiri. Yuk belajar!',
    'Hari ini adalah kesempatan sempurna untuk memulai!',
    'Pengetahuan adalah kekuatan. Saatnya belajar!',
    'Satu jam belajar hari ini, lebih baik dari tidak sama sekali!',
    'Kesuksesan dimulai dari kebiasaan belajar yang konsisten.',
    'Jangan biarkan hari ini berlalu tanpa belajar sesuatu yang baru!',
    'Masa depan cemerlangmu dimulai dari belajar hari ini!',
  ];

  String _getRandomMotivation() {
    final random =
        DateTime.now().millisecondsSinceEpoch % _motivationalQuotes.length;
    return _motivationalQuotes[random];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthData();
    });
  }

  /// Load month data from CalendarProvider (with caching)
  Future<void> _loadMonthData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final calendarProvider = Provider.of<CalendarProvider>(
      context,
      listen: false,
    );

    if (userProvider.user == null) return;

    // Load current month summaries (uses cache if available)
    await calendarProvider.getMonthSummaries(
      userProvider.user!.uid,
      _focusedDay,
    );

    // Load sessions for selected day
    if (_selectedDay != null) {
      _loadSessionsForDay(_selectedDay!);
    }
  }

  Future<void> _loadSessionsForDay(DateTime day) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final calendarProvider = Provider.of<CalendarProvider>(
      context,
      listen: false,
    );

    if (userProvider.user == null) return;

    setState(() => _isLoadingSessions = true);

    try {
      final sessions = await calendarProvider.getSessionsForDate(
        userProvider.user!.uid,
        day,
      );
      setState(() {
        _selectedDaySessions = sessions;
        _isLoadingSessions = false;
      });
    } catch (e) {
      setState(() => _isLoadingSessions = false);
      debugPrint("Error loading sessions: $e");
    }
  }

  /// Get summary for a day from CalendarProvider cache (no API call)
  SummaryModel? _getSummaryForDay(DateTime day) {
    final calendarProvider = Provider.of<CalendarProvider>(
      context,
      listen: false,
    );
    return calendarProvider.getSummaryForDay(day);
  }

  bool _hasStudySession(DateTime day) {
    final summary = _getSummaryForDay(day);
    return summary != null && summary.dailyTotal > 0;
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';

    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Study Calendar',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: calendarProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    final userProvider = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    );
                    if (userProvider.user != null) {
                      await calendarProvider.forceRefresh(
                        userProvider.user!.uid,
                      );
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Calendar Widget
                        _buildCalendar(),

                        // Selected Day Info
                        if (_selectedDay != null) ...[
                          const SizedBox(height: 16),
                          _buildSelectedDayCard(),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _loadSessionsForDay(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          // Load new month data when user swipes (uses cache if available)
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          if (userProvider.user != null) {
            context.read<CalendarProvider>().getMonthSummaries(
              userProvider.user!.uid,
              focusedDay,
            );
          }
        },
        eventLoader: (day) {
          return _hasStudySession(day) ? [true] : [];
        },
        calendarStyle: CalendarStyle(
          todayDecoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.blue.shade400,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.orange.shade400,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          outsideDaysVisible: true,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              final summary = _getSummaryForDay(date);
              return Positioned(
                bottom: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getColorForDuration(summary?.dailyTotal ?? 0),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDayCard() {
    final summary = _getSummaryForDay(_selectedDay!);
    final hasStudied = summary != null && summary.dailyTotal > 0;

    if (hasStudied) {
      return _buildStudyCompletedCard(summary);
    } else {
      return _buildNoStudyCard();
    }
  }

  Widget _buildStudyCompletedCard(SummaryModel summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                _formatDate(_selectedDay!),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          const Row(
            children: [
              Text(
                'Study Session Completed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.emoji_events, color: Colors.amber, size: 24),
            ],
          ),
          const SizedBox(height: 16),

          // Stats
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildStatRow(
                  Icons.timer,
                  'Focus Time',
                  _formatDuration(summary.dailyFocus),
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  Icons.coffee,
                  'Break Time',
                  _formatDuration(summary.dailyBreak),
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  Icons.access_time_filled,
                  'Total',
                  _formatDuration(summary.dailyTotal),
                ),
                if (summary.labelsStudied.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildStatRow(
                    Icons.label,
                    'Subjects',
                    summary.labelsStudied.join(', '),
                  ),
                ],
              ],
            ),
          ),

          // Sessions detail button
          if (_selectedDaySessions.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showSessionsDetail(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View ${_selectedDaySessions.length} Session(s)',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.green.shade700,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (_isLoadingSessions)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNoStudyCard() {
    final bool isFuture = _selectedDay!.isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFuture
              ? [Colors.blue.shade400, Colors.indigo.shade400]
              : [Colors.orange.shade400, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isFuture ? Colors.blue.shade200 : Colors.orange.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFuture ? Icons.event : Icons.calendar_today,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                _formatDate(_selectedDay!),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                isFuture ? 'Upcoming Day' : 'No Study Session',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isFuture ? Icons.schedule : Icons.sentiment_neutral,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getRandomMotivation(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionsDetail() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Session History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(_selectedDay!),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Sessions List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _selectedDaySessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session = _selectedDaySessions[index];
                  return _buildSessionCard(session, index + 1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, int index) {
    final focusDuration = session['focusDuration'] as int? ?? 0;
    final breakDuration = session['breakDuration'] as int? ?? 0;
    final label = session['label'] as String? ?? 'Unknown';
    final description = session['description'] as String? ?? '';
    final title = session['title'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.isNotEmpty ? title : 'Session #$index',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat(
                Icons.timer,
                'Focus',
                _formatDuration(focusDuration),
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                Icons.coffee,
                'Break',
                _formatDuration(breakDuration),
                Colors.orange,
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Color _getColorForDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    if (minutes == 0) return Colors.grey;
    if (minutes < 30) return Colors.orange[300]!;
    if (minutes < 60) return Colors.orange[400]!;
    if (minutes < 120) return Colors.orange[600]!;
    return Colors.orange[800]!;
  }
}
