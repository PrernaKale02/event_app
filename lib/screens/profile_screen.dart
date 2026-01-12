import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../services/user_service.dart';
import '../services/registration_service.dart';
import '../services/bookmark_service.dart';
import '../models/event.dart';
import 'event_detail_screen.dart';
import '../utils/date_formatter.dart';
import 'edit_profile_screen.dart'; // Import EditProfileScreen
import '../providers/theme_provider.dart'; // Import ThemeProvider

class ProfileScreen extends StatefulWidget { // Convert to StatefulWidget for local UI updates if needed, though Provider handles theme.
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userService = UserService();
    final registrationService = RegistrationService();
    final bookmarkService = BookmarkService();
    // Access ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile'),
          actions: [
             IconButton(
               icon: const Icon(Icons.edit),
               tooltip: 'Edit Profile',
               onPressed: () async {
                 await Navigator.push(
                   context,
                   MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                 );
                 setState(() {}); // Refresh to show new name
               },
             ),
          ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 👤 USER INFO
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.account_circle, size: 60, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      user.displayName ?? 'No Name', 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(user.email ?? 'No email', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                     FutureBuilder<bool>(
                      future: userService.isAdmin(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                             color: snapshot.data! ? Colors.redAccent : Colors.blueAccent,
                             borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                             snapshot.data! ? 'Admin' : 'User',
                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            
            // 🌓 DARK MODE SWITCH
            SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
             const Divider(),
             const SizedBox(height: 10),

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
                      subtitle: Text(DateFormatter.format(event.date)),
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
                      subtitle: Text(DateFormatter.format(event.date)),
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
