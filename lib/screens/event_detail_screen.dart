import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/event.dart';
import '../services/registration_service.dart';
import '../services/bookmark_service.dart';
import '../services/user_service.dart';
import '../services/firestore_service.dart';
import 'edit_event_screen.dart';
import '../utils/date_formatter.dart';
class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final RegistrationService _registrationService = RegistrationService();
  final UserService _userService = UserService();
  final FirestoreService _firestoreService = FirestoreService();

  bool isRegistered = false;
  bool isLoading = true;
  bool isAdmin = false;

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
    final admin = await _userService.isAdmin();

    if (mounted) {
      setState(() {
        isRegistered = registered;
        isBookmarked = bookmarked;
        isAdmin = admin;
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
    
    setState(() {
      isRegistered = true;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully registered for the event')),
    );
  }

  Future<void> _launchMap() async {
    final query = Uri.encodeComponent(widget.event.location);
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    final appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$query');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl);
    } else {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps.')),
        );
      }
    }
  }

  void _shareEvent() {
    Share.share(
      'Check out this event: ${widget.event.title} at ${widget.event.location} on ${widget.event.date}. \n\n${widget.event.description}',
    );
  }

  Future<void> _deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteEvent(widget.event.id);
      if (mounted) {
        Navigator.pop(context); // Go back to Home
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditEventScreen(event: event),
                  ),
                );
                
                // If updated, pop back to refresh list (or listen to stream)
                // But DetailScreen needs updated data. 
                // Since we pass Event object, we probably need to refetch or assume Home refreshes.
                // Simpler: Pop back to Home if major change, or just stay.
                // Ideally we should use a Stream for Event Detail too.
                // For now, if result is true, pop.
                if (result == true && mounted) {
                   Navigator.pop(context);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteEvent,
            ),
          ],
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () async {
              await _bookmarkService.toggleBookmark(event.id, isBookmarked);

              setState(() {
                isBookmarked = !isBookmarked;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareEvent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Category Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5)),
              ),
              child: Text(
                event.category.isEmpty ? 'General' : event.category,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Title
            Text(
              event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // 🔹 Location
            InkWell(
              onTap: _launchMap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.location,
                      style: const TextStyle(
                        color: Colors.blue,
                        // decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 🔹 Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 6),
                Text(DateFormatter.format(event.date)),
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
