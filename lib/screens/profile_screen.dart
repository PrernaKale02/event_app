import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../services/registration_service.dart';
import '../services/bookmark_service.dart';
import '../models/event.dart';
import 'event_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userService = UserService();
    final registrationService = RegistrationService();
    final bookmarkService = BookmarkService();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 👤 USER INFO
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(user.email ?? 'No email'),
                subtitle: FutureBuilder<bool>(
                  future: userService.isAdmin(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text('Loading...');
                    return Text(snapshot.data! ? 'Admin' : 'User');
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🎟️ REGISTRATIONS
            const Text(
              'My Registrations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            StreamBuilder<List<Event>>(
              stream: registrationService.getRegisteredEvents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('No registrations yet'),
                  );
                }

                return Column(
                  children: snapshot.data!.map((event) {
                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text(event.date),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(event: event),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // ⭐ BOOKMARKS
            const Text(
              'Bookmarked Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            StreamBuilder<List<Event>>(
              stream: bookmarkService.getBookmarkedEvents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('No bookmarks yet'),
                  );
                }

                return Column(
                  children: snapshot.data!.map((event) {
                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text(event.date),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(event: event),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            // 🚪 LOGOUT
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
