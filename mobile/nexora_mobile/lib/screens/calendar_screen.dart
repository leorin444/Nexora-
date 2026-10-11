import 'package:flutter/material.dart';
import '../models/calendar_event_model.dart';
import '../services/calendar_service.dart';

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
      setState(() {
        _events = events;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    int visibility = 0; // 0 = Private, 1 = Shared

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Calendar Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location (optional)'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: visibility,
                  decoration: const InputDecoration(labelText: 'Visibility'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Private (Only You)')),
                    DropdownMenuItem(value: 1, child: Text('Shared (With Partner)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => visibility = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Calendar'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvents),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _events!.isEmpty
                  ? const Center(child: Text('No upcoming events. Tap + to create one.'))
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _events!.length,
                        itemBuilder: (context, index) {
                          final event = _events![index];
                          final isShared = event.visibility != 0;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                isShared ? Icons.people_alt : Icons.person,
                                color: isShared ? Colors.pink : Colors.deepPurple,
                              ),
                              title: Text(
                                event.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${event.startTimeUtc.toLocal().toString().substring(0, 16)} - ${event.endTimeUtc.toLocal().toString().substring(11, 16)}',
                                  ),
                                  if (event.location != null && event.location!.isNotEmpty)
                                    Text('📍 ${event.location!}'),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(
                                  isShared ? 'Shared' : 'Private',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: (isShared ? Colors.pink : Colors.deepPurple).withOpacity(0.1),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
