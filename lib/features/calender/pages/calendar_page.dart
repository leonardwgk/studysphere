import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ActivityEvent {
  final String title;
  final Color color;
  final String duration;
  final String topic;
  final String notes;

  ActivityEvent({
    required this.title,
    required this.color,
    required this.duration,
    required this.topic,
    required this.notes,
  });
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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

  final Map<DateTime, List<ActivityEvent>> _events = {
    DateTime.utc(2025, 11, 1): [
      ActivityEvent(
        title: 'Flutter Development',
        color: Colors.blue.shade100,
        duration: '2 hours 30 minutes',
        topic: 'State Management dengan Provider',
        notes:
            'Mempelajari konsep state management, implementasi Provider, dan best practices dalam Flutter development.',
      ),
    ],
    DateTime.utc(2025, 11, 3): [
      ActivityEvent(
        title: 'Mathematics - Calculus',
        color: Colors.green.shade100,
        duration: '1 hour 45 minutes',
        topic: 'Integral dan Aplikasinya',
        notes:
            'Memahami konsep integral tentu dan tak tentu, serta aplikasinya dalam menghitung luas dan volume.',
      ),
    ],
    DateTime.utc(2025, 11, 5): [
      ActivityEvent(
        title: 'English Grammar',
        color: Colors.orange.shade100,
        duration: '1 hour 30 minutes',
        topic: 'Tenses dan Passive Voice',
        notes:
            'Review semua tenses, penggunaan passive voice dalam berbagai konteks, dan latihan soal.',
      ),
    ],
    DateTime.utc(2025, 11, 7): [
      ActivityEvent(
        title: 'Data Structures',
        color: Colors.purple.shade100,
        duration: '3 hours',
        topic: 'Binary Trees dan Traversal',
        notes:
            'Implementasi binary tree, berbagai metode traversal (inorder, preorder, postorder), dan aplikasinya.',
      ),
    ],
    DateTime.utc(2025, 11, 10): [
      ActivityEvent(
        title: 'UI/UX Design',
        color: Colors.pink.shade100,
        duration: '2 hours',
        topic: 'Design Thinking Process',
        notes:
            'Mempelajari 5 tahap design thinking: empathize, define, ideate, prototype, dan test.',
      ),
    ],
    DateTime.utc(2025, 11, 12): [
      ActivityEvent(
        title: 'Algorithm Analysis',
        color: Colors.indigo.shade100,
        duration: '2 hours 15 minutes',
        topic: 'Time Complexity dan Big O Notation',
        notes:
            'Analisis kompleksitas algoritma, memahami Big O, Big Theta, dan Big Omega notation.',
      ),
    ],
    DateTime.utc(2025, 11, 15): [
      ActivityEvent(
        title: 'Database Management',
        color: Colors.teal.shade100,
        duration: '1 hour 50 minutes',
        topic: 'SQL Queries dan Joins',
        notes:
            'Praktek berbagai jenis JOIN (INNER, LEFT, RIGHT, FULL), subqueries, dan optimization.',
      ),
    ],
    DateTime.utc(2025, 11, 18): [
      ActivityEvent(
        title: 'Physics - Mechanics',
        color: Colors.amber.shade100,
        duration: '2 hours 20 minutes',
        topic: 'Hukum Newton dan Dinamika',
        notes:
            'Memahami tiga hukum Newton, aplikasi dalam kasus nyata, dan penyelesaian soal dinamika.',
      ),
    ],
    DateTime.utc(2025, 11, 20): [
      ActivityEvent(
        title: 'Web Development',
        color: Colors.cyan.shade100,
        duration: '3 hours 30 minutes',
        topic: 'React Hooks dan Context API',
        notes:
            'Deep dive ke React Hooks (useState, useEffect, useContext), dan state management dengan Context API.',
      ),
    ],
    DateTime.utc(2025, 11, 22): [
      ActivityEvent(
        title: 'Machine Learning Basics',
        color: Colors.deepPurple.shade100,
        duration: '2 hours 40 minutes',
        topic: 'Supervised Learning - Linear Regression',
        notes:
            'Konsep supervised learning, implementasi linear regression, dan evaluasi model.',
      ),
    ],
    DateTime.utc(2025, 11, 25): [
      ActivityEvent(
        title: 'Software Engineering',
        color: Colors.red.shade100,
        duration: '1 hour 55 minutes',
        topic: 'Agile Methodology dan Scrum',
        notes:
            'Memahami prinsip Agile, framework Scrum, sprint planning, dan daily standup.',
      ),
    ],
    DateTime.utc(2025, 11, 27): [
      ActivityEvent(
        title: 'Mobile App Development',
        color: Colors.lightBlue.shade100,
        duration: '4 hours',
        topic: 'Firebase Integration',
        notes:
            'Integrasi Firebase Authentication, Firestore Database, dan Cloud Storage dalam aplikasi mobile.',
      ),
    ],
    DateTime.utc(2025, 11, 28): [
      ActivityEvent(
        title: 'Cloud Computing',
        color: Colors.blueGrey.shade100,
        duration: '2 hours 10 minutes',
        topic: 'AWS Services Overview',
        notes:
            'Pengenalan AWS EC2, S3, Lambda, dan basic deployment menggunakan cloud services.',
      ),
    ],
  };

  List<ActivityEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar Widget
            Container(
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
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  // Navigate ke detail aktivitas
                  List<ActivityEvent> events = _getEventsForDay(selectedDay);
                  if (events.isNotEmpty) {
                    _showActivityDetail(selectedDay, events);
                  }
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _getEventsForDay,
                // Styling
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
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
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                  ),
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
                      final event = events.first as ActivityEvent;
                      return Positioned(
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: event.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),

            // Selected Day Info Card - Study Session Summary
            if (_selectedDay != null &&
                _getEventsForDay(_selectedDay!).isNotEmpty)
              Container(
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
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedDay!.day} November 2025',
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
                        const Text(
                          'Study Session Completed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.emoji_events,
                          color: Colors.amber.shade300,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.book, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getEventsForDay(_selectedDay!).first.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getEventsForDay(_selectedDay!).first.duration,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.topic,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _getEventsForDay(_selectedDay!).first.topic,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _showActivityDetail(
                        _selectedDay!,
                        _getEventsForDay(_selectedDay!),
                      ),
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
                              'View Full Details',
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
                ),
              ),

            // Selected Day Info Card - No Study Session
            if (_selectedDay != null && _getEventsForDay(_selectedDay!).isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade400,
                      Colors.deepOrange.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade200,
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
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedDay!.day} November 2025',
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
                        const Text(
                          'No Study Session',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.sentiment_neutral,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
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
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showActivityDetail(DateTime date, List<ActivityEvent> events) {
    final event = events.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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
                    color: event.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.school, color: Colors.black87, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${date.day} November 2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Duration
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Study Duration',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.duration,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Topic
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.topic, color: Colors.purple.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Topic Covered',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.topic,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notes,
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Study Notes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.notes,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
