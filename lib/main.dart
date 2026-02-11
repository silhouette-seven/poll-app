import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poll_app/features/polls/data/local_poll_storage.dart';
import 'package:poll_app/features/polls/providers/poll_providers.dart';
import 'package:poll_app/router.dart';
import 'package:poll_app/firebase_options.dart'; // Will exist after configuration

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase if options exist, otherwise skip (dev mode)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Sign in anonymously to allow Firestore writes
    await FirebaseAuth.instance.signInAnonymously();
    debugPrint(
      "Signed in anonymously: ${FirebaseAuth.instance.currentUser?.uid}",
    );
  } catch (e) {
    debugPrint("Firebase initialization or Auth failed: $e");
  }

  final localPollStorage = LocalPollStorage();
  await localPollStorage.init();

  runApp(
    ProviderScope(
      overrides: [localPollStorageProvider.overrideWithValue(localPollStorage)],
      child: const PollApp(),
    ),
  );
}

class PollApp extends ConsumerWidget {
  const PollApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Poll App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4EFF), // Elegant purple/blue
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
          displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4EFF),
          brightness: Brightness.dark,
          surface: const Color(0xFF121212),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
