import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calendar_event_model.dart';
import '../services/calendar_service.dart';
import '../theme/nexora_theme.dart';
import '../widgets/bento_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarService _calendarService = CalendarService();
  List<CalendarEventModel>? _events;
  bool _isLoading = true;
  String? _error;

  int _selectedFilter = 0; // 0 = All, 1 = Private, 2 = Shared
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _calendarService.getEvents();
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddEventBottomSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    int visibility = 0; // 0 = Private, 1 = Shared

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final tokens = NexoraTheme.of(context);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: tokens.cardSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(NexoraRadius.lg)),
                border: Border.all(color: tokens.strokeSubtle),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: tokens.strokeSubtle,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Schedule New Event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: tokens.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        hintText: 'e.g. Anniversary Dinner, Flight',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      style: TextStyle(color: tokens.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        hintText: 'e.g. Bella Italia Bistro',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: TextStyle(color: tokens.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Notes, confirmation code, etc.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Segmented Visibility Toggle: 🔒 Private (Only You) vs 💖 Shared (With Partner)
                    Text(
                      'Privacy & Visibility',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: tokens.strokeSubtle,
                        borderRadius: NexoraRadius.borderSm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setSheetState(() => visibility = 0);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: visibility == 0 ? tokens.cardSurface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '🔒 Private (Only You)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: visibility == 0
                                          ? tokens.brandPrimary
                                          : tokens.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setSheetState(() => visibility = 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: visibility == 1 ? tokens.cardSurface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '💖 Shared (With Partner)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: visibility == 1
                                          ? tokens.coupleAccent
                                          : tokens.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: visibility == 1 ? tokens.coupleAccent : tokens.brandPrimary,
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          final start = DateTime.now().toUtc();
                          final end = start.add(const Duration(hours: 1));

                          try {
                            await _calendarService.createEvent(
                              title: title,
                              description: descController.text.trim(),
                              location: locationController.text.trim(),
                              startTimeUtc: start,
                              endTimeUtc: end,
                              visibility: visibility,
                            );
                            if (mounted) Navigator.of(ctx).pop();
                            await _loadEvents();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Save Event', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);

    final filteredEvents = (_events ?? []).where((event) {
      if (_selectedFilter == 1) return event.visibility == 0;
      if (_selectedFilter == 2) return event.visibility != 0;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        title: const Text('Shared Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadEvents,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: tokens.brandPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
        onPressed: _showAddEventBottomSheet,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Horizontal 7-day scroll strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: tokens.cardSurface,
              border: Border(bottom: BorderSide(color: tokens.strokeSubtle)),
            ),
            child: SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 14,
                itemBuilder: (context, index) {
                  final day = DateTime.now().add(Duration(days: index - 2));
                  final isSelected = day.day == _selectedDay.day &&
                      day.month == _selectedDay.month &&
                      day.year == _selectedDay.year;

                  final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final weekdayLabel = weekdays[day.weekday - 1];

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedDay = day);
                    },
                    child: Container(
                      width: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.brandPrimary : tokens.strokeSubtle.withOpacity(0.5),
                        borderRadius: NexoraRadius.borderSm,
                        border: Border.all(
                          color: isSelected ? tokens.brandPrimary : tokens.strokeSubtle,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weekdayLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white70 : tokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : tokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Category Filter Chips (All, 🔒 Private Only, 💖 Shared Duo)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('All', 0, tokens),
                const SizedBox(width: 8),
                _buildFilterChip('🔒 Private Only', 1, tokens),
                const SizedBox(width: 8),
                _buildFilterChip('💖 Shared Duo', 2, tokens),
              ],
            ),
          ),

          // Schedule Timeline
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error', style: TextStyle(color: tokens.vaultAccent)))
                    : filteredEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_available_rounded, size: 48, color: tokens.textSecondary.withOpacity(0.4)),
                                const SizedBox(height: 12),
                                Text(
                                  'No events found for this filter.\nTap + to schedule an event!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: tokens.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadEvents,
                            color: tokens.brandPrimary,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filteredEvents.length,
                              itemBuilder: (context, index) {
                                final event = filteredEvents[index];
                                final isShared = event.visibility != 0;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: BentoCard(
                                    border: Border.all(
                                      color: isShared
                                          ? tokens.coupleAccent.withOpacity(0.5)
                                          : tokens.strokeSubtle,
                                      width: isShared ? 1.4 : 1.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: (isShared ? tokens.coupleAccent : tokens.brandPrimary)
                                                .withOpacity(0.12),
                                            borderRadius: NexoraRadius.borderSm,
                                          ),
                                          child: Icon(
                                            isShared ? Icons.favorite_rounded : Icons.lock_rounded,
                                            color: isShared ? tokens.coupleAccent : tokens.brandPrimary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      event.title,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                        color: tokens.textPrimary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: (isShared ? tokens.coupleAccent : tokens.brandPrimary)
                                                          .withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      isShared ? '💖 Shared' : '🔒 Private',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w700,
                                                        color: isShared ? tokens.coupleAccent : tokens.brandPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${event.startTimeUtc.toLocal().toString().substring(0, 16)} - ${event.endTimeUtc.toLocal().toString().substring(11, 16)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: tokens.textSecondary,
                                                ),
                                              ),
                                              if (event.location != null && event.location!.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  '📍 ${event.location}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: tokens.brandPrimary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, NexoraThemeExtension tokens) {
    final isSelected = _selectedFilter == index;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.selectionClick();
          setState(() => _selectedFilter = index);
        }
      },
      selectedColor: tokens.brandPrimary.withOpacity(0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? tokens.brandPrimary : tokens.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? tokens.brandPrimary : tokens.strokeSubtle,
      ),
      backgroundColor: tokens.cardSurface,
    );
  }
}
