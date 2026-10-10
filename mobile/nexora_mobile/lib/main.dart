import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/couple_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const NexoraApp(),
    ),
  );
}

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexora',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          switch (auth.status) {
            case AuthStatus.uninitialized:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case AuthStatus.authenticated:
              return HomeScreen(user: auth.user!);
            case AuthStatus.unauthenticated:
              return const LoginScreen();
          }
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final dynamic user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexora Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.fullName}!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Email: ${user.email}'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.note_alt_outlined),
              label: const Text('My Notes'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotesScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade50,
                foregroundColor: Colors.pink,
              ),
              icon: const Icon(Icons.favorite),
              label: const Text('Couple Space'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CoupleScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
