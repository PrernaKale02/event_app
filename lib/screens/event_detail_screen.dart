import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/registration_service.dart';
import '../services/bookmark_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final RegistrationService _registrationService = RegistrationService();

  bool isRegistered = false;
  bool isLoading = true;

  final BookmarkService _bookmarkService = BookmarkService();
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    final registered = await _registrationService.isRegistered(widget.event.id);
    final bookmarked = await _bookmarkService.isBookmarked(widget.event.id);

    setState(() {
      isRegistered = registered;
      isBookmarked = bookmarked;
      isLoading = false;
    });

    if (mounted) {
      setState(() {
        isRegistered = registered;
        isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });

    await _registrationService.register(widget.event.id);
    if (!mounted) return;
    if (mounted) {
      setState(() {
        isRegistered = true;
        isLoading = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully registered for the event')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () async {
              await _bookmarkService.toggleBookmark(event.id, isBookmarked);

              setState(() {
                isBookmarked = !isBookmarked;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Title
            Text(
              event.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // 🔹 Location
            Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 6),
                Text(event.location),
              ],
            ),

            const SizedBox(height: 8),

            // 🔹 Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 6),
                Text(event.date),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Description header
            const Text(
              'About this event',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            // 🔹 Description text
            SelectableText(
              event.description,
              style: const TextStyle(fontSize: 15),
            ),

            const Spacer(),

            // 🔹 Register button
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: isRegistered ? null : _register,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      isRegistered ? 'Registered ✅' : 'Register for Event',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
